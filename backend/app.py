import os
import sys
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity, unset_jwt_cookies
from flask_migrate import Migrate
import openai
from datetime import datetime
import logging
from logging.handlers import RotatingFileHandler

# Import our modules
from config import get_config
from models import db, bcrypt, User, DreamAnalysis, APIUsage
from auth import auth_bp

def create_app(config_name=None):
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Load configuration
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    config_class = get_config()
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    bcrypt.init_app(app)
    jwt = JWTManager(app)
    migrate = Migrate(app, db)
    
    # Configure CORS - Allow mobile apps and web clients
    if app.config.get('FLASK_ENV') == 'production':
        # In production, be more restrictive but allow mobile apps
        CORS(app, 
             origins=['*'],  # Mobile apps don't send traditional origins
             allow_headers=['Content-Type', 'Authorization'],
             methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
             supports_credentials=False)  # Mobile apps typically don't use credentials
    else:
        # Development: allow localhost
        CORS(app, 
             origins=['http://localhost:3000', 'http://localhost:3001', 'http://127.0.0.1:3000', 'http://127.0.0.1:3001'], 
             supports_credentials=True)
    
    # Register blueprints
    app.register_blueprint(auth_bp)
    
    # JWT token blacklist check
    # This is a simplified in-memory blacklist. For production, use Redis or a database.
    blacklisted_tokens = set()

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        jti = jwt_payload['jti']
        return jti in blacklisted_tokens
    
    # Root endpoint
    @app.route('/', methods=['GET'])
    def root():
        """Root endpoint"""
        return jsonify({
            'message': 'Dream Analyzer API',
            'status': 'running',
            'version': '2.0.0',
            'health_check': '/api/health'
        }), 200
    
    # Health check endpoint
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """Health check endpoint"""
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'version': '2.0.0'
        }), 200
    
    # Test login page
    @app.route('/test', methods=['GET'])
    def test_page():
        """Test login page"""
        return send_from_directory('.', 'test_login.html')
    
    # Dream analysis endpoint
    @app.route('/api/dreams/analyze', methods=['POST'])
    @jwt_required()
    def analyze_dream():
        """Analyze a dream with AI"""
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        data = request.get_json()
        if not data or 'dreamText' not in data:
            return jsonify({'message': 'Dream text is required'}), 400
        
        dream_text = data['dreamText'].strip()
        if not dream_text:
            return jsonify({'message': 'Dream text cannot be empty'}), 400
        
        if len(dream_text) > 5000:
            return jsonify({'message': 'Dream text is too long (max 5000 characters)'}), 400

        # This variable must be declared *before* the try block
        # so it's accessible in the `finally` clause.
        original_proxies = (
            os.environ.get('https_proxy'),
            os.environ.get('http_proxy')
        )

        try:
            # Check for OpenAI API key. If not present, fallback to basic analysis.
            if not app.config.get('OPENAI_API_KEY'):
                app.logger.warning("OPENAI_API_KEY not set. Falling back to basic analysis.")
                raise ValueError("OpenAI API Key not configured.")

            # To solve proxy issues, we explicitly create an httpx client
            # with proxies disabled and pass it to the OpenAI client.
            import httpx
            from openai import OpenAI

            http_client_no_proxy = httpx.Client(trust_env=False)

            client = OpenAI(
                api_key=app.config['OPENAI_API_KEY'],
                http_client=http_client_no_proxy
            )

            prompt = f"""
أنت محلل أحلام خبير ومتخصص في علم النفس. حلل الحلم التالي وقدم رؤى عميقة ومفيدة:
الحلم: {dream_text}
يرجى تقديم:
1. تحليل شامل للحلم مع تفسير الرموز والمعاني
2. الرسائل النفسية والعاطفية
3. الدلالات المحتملة في الحياة الواقعية
4. نصائح شخصية للاستفادة من هذا الحلم
أجب باللغة العربية فقط.
"""
            
            response = client.chat.completions.create(
                model=app.config['OPENAI_MODEL'],
                messages=[
                    {"role": "system", "content": "أنت محلل أحلام خبير ومتخصص في علم النفس. تجيب باللغة العربية فقط."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=app.config['OPENAI_MAX_TOKENS'],
                temperature=app.config['OPENAI_TEMPERATURE']
            )
            ai_response = response.choices[0].message.content.strip()
            tokens_used = response.usage.total_tokens
            
            # Extract analysis and advice from AI response
            if "نصائح:" in ai_response or "النصائح:" in ai_response:
                parts = ai_response.split("نصائح:" if "نصائح:" in ai_response else "النصائح:")
                analysis = parts[0].strip()
                advice = parts[1].strip() if len(parts) > 1 else "استمر في تدوين أحلامك لفهم أفضل لذاتك."
            else:
                analysis = ai_response
                advice = "استمر في تدوين أحلامك لفهم أفضل لذاتك."

            # Save successful analysis to database
            dream_analysis = DreamAnalysis(
                user_id=user.id, dream_text=dream_text, analysis=analysis, advice=advice,
                mood_before=data.get('mood_before'), mood_after=data.get('mood_after'), tags=data.get('tags', [])
            )
            db.session.add(dream_analysis)

            # Track API usage
            api_usage = APIUsage(
                user_id=user.id, endpoint='analyze_dream', tokens_used=tokens_used,
                cost=tokens_used * 0.000002
            )
            db.session.add(api_usage)
            
            db.session.commit()
            
            return jsonify({
                'success': True, 'dream_id': dream_analysis.id, 'dream_text': dream_analysis.dream_text,
                'analysis': dream_analysis.analysis, 'advice': dream_analysis.advice,
                'timestamp': dream_analysis.created_at.isoformat()
            }), 200
            
        except Exception as e:
            db.session.rollback()
            app.logger.error(f"Dream analysis error: {str(e)}")
            return jsonify({'message': 'Analysis failed', 'error': str(e)}), 500
        
        finally:
            # ALWAYS restore original proxy settings
            https_proxy, http_proxy = original_proxies
            if https_proxy:
                os.environ['https_proxy'] = https_proxy
            if http_proxy:
                os.environ['http_proxy'] = http_proxy

    # Get user's dreams
    @app.route('/api/dreams', methods=['GET'])
    @jwt_required()
    def get_dreams():
        """Get user's dream history"""
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        page = request.args.get('page', 1, type=int)
        per_page = min(request.args.get('per_page', 20, type=int), 100)
        
        dreams = DreamAnalysis.query.filter_by(user_id=user.id)\
            .order_by(DreamAnalysis.created_at.desc())\
            .paginate(page=page, per_page=per_page, error_out=False)
        
        return jsonify({
            'success': True,
            'dreams': [dream.to_dict() for dream in dreams.items],
            'total': dreams.total, 'pages': dreams.pages, 'current_page': page, 'per_page': per_page
        }), 200
            
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'message': 'Resource not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({'message': 'Internal server error'}), 500
    
    return app

if __name__ == '__main__':
    app = create_app()
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)