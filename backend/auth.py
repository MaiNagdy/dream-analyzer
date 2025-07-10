from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import (
    create_access_token, create_refresh_token, jwt_required, 
    get_jwt_identity, get_jwt, verify_jwt_in_request
)
from datetime import datetime, timedelta
from email_validator import validate_email, EmailNotValidError
import re
from models import db, User, UserSession, DreamAnalysis
from functools import wraps
import traceback

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

# Token blacklist for logout functionality
blacklisted_tokens = set()

def token_required(f):
    """Decorator to require valid JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        try:
            verify_jwt_in_request()
            return f(*args, **kwargs)
        except Exception as e:
            return jsonify({'message': 'Token required', 'error': str(e)}), 401
    return decorated

def validate_password(password):
    """Validate password strength - simplified"""
    if len(password) < 6:
        return False, "Password must be at least 6 characters long"
    
    return True, "Password is valid"

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        # Required fields
        email = data.get('email', '').strip().lower()
        username = data.get('username', '').strip()
        password = data.get('password', '')
        
        # Get optional fields
        first_name = (data.get('first_name') or '').strip()
        last_name = (data.get('last_name') or '').strip()
        phone_number = (data.get('phone_number') or '').strip()
        gender = (data.get('gender') or '').strip()
        
        date_of_birth_str = (data.get('date_of_birth') or '').strip()
        date_of_birth = None
        if date_of_birth_str:
            try:
                date_of_birth = datetime.strptime(date_of_birth_str, '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'message': 'Invalid date format for date_of_birth'}), 400
        
        # Validation
        if not email or not username or not password:
            return jsonify({'message': 'Email, username, and password are required'}), 400
        
        # Validate email (simple check)
        if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', email):
            return jsonify({'message': 'Invalid email format'}), 400
        
        # Validate username
        if len(username) < 3 or len(username) > 50:
            return jsonify({'message': 'Username must be between 3 and 50 characters'}), 400
        
        if not re.match(r'^[a-zA-Z0-9_]+$', username):
            return jsonify({'message': 'Username can only contain letters, numbers, and underscores'}), 400
        
        # Validate password
        is_valid, password_message = validate_password(password)
        if not is_valid:
            return jsonify({'message': password_message}), 400
        
        # Check if user already exists
        if User.query.filter_by(email=email).first():
            return jsonify({'message': 'Email already registered'}), 409
        
        if User.query.filter_by(username=username).first():
            return jsonify({'message': 'Username already taken'}), 409
        
        # Create new user
        user = User(
            email=email,
            username=username,
            first_name=first_name or None,
            last_name=last_name or None,
            phone_number=phone_number or None,
            gender=gender or None,
            date_of_birth=date_of_birth or None
        )
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        # Create tokens
        access_token = create_access_token(identity=str(user.id))
        refresh_token = create_refresh_token(identity=str(user.id))
        
        # Create session record (simplified without JTI for now)
        session = UserSession(
            user_id=user.id,
            jti='session-' + str(user.id) + '-' + datetime.utcnow().strftime('%Y%m%d%H%M%S'),
            expires_at=datetime.utcnow() + timedelta(hours=24),
            ip_address=request.remote_addr,
            user_agent=request.headers.get('User-Agent', '')
        )
        db.session.add(session)
        db.session.commit()
        
        return jsonify({
            'message': 'User registered successfully',
            'user': user.to_dict(),
            'access_token': access_token,
            'refresh_token': refresh_token
        }), 201
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Registration error: {str(e)}")
        # Log the full traceback for detailed debugging
        tb_str = traceback.format_exc()
        current_app.logger.error(tb_str)
        return jsonify({'message': 'Registration failed', 'error': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login user"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        # Accept multiple field name formats
        login_field = (data.get('login', '') or 
                      data.get('email_or_username', '') or 
                      data.get('email', '') or 
                      data.get('username', '')).strip()
        password = data.get('password', '')
        
        if not login_field or not password:
            return jsonify({'message': 'Email/username and password are required'}), 400
        
        # Find user by email or username
        user = None
        if '@' in login_field:
            user = User.query.filter_by(email=login_field.lower()).first()
        else:
            user = User.query.filter_by(username=login_field).first()

        # Distinguish error cases for better UX
        if not user:
            return jsonify({'message': 'User not found'}), 404

        if not user.check_password(password):
            return jsonify({'message': 'Incorrect password'}), 401
        
        if not user.is_active:
            return jsonify({'message': 'Account is deactivated'}), 401
        
        # Update last login
        user.last_login = datetime.utcnow()
        
        # Create tokens
        access_token = create_access_token(identity=str(user.id))
        refresh_token = create_refresh_token(identity=str(user.id))
        
        # Create session record
        session = UserSession(
            user_id=user.id,
            jti='login-' + str(user.id) + '-' + datetime.utcnow().strftime('%Y%m%d%H%M%S'),
            expires_at=datetime.utcnow() + timedelta(hours=24),
            ip_address=request.remote_addr,
            user_agent=request.headers.get('User-Agent', '')
        )
        db.session.add(session)
        db.session.commit()
        
        return jsonify({
            'message': 'Login successful',
            'user': user.to_dict(),
            'access_token': access_token,
            'refresh_token': refresh_token
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Login error: {str(e)}")
        return jsonify({'message': 'Login failed', 'error': str(e)}), 500

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """Logout user and blacklist token"""
    try:
        jti = get_jwt()['jti']
        user_id = get_jwt_identity()
        
        # Add token to blacklist
        blacklisted_tokens.add(jti)
        
        # Deactivate session
        session = UserSession.query.filter_by(
            user_id=user_id, 
            jti=jti, 
            is_active=True
        ).first()
        
        if session:
            session.is_active = False
            db.session.commit()
        
        return jsonify({'message': 'Logout successful'}), 200
        
    except Exception as e:
        current_app.logger.error(f"Logout error: {str(e)}")
        return jsonify({'message': 'Logout failed', 'error': str(e)}), 500

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """Refresh access token"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user or not user.is_active:
            return jsonify({'message': 'User not found or inactive'}), 404
        
        new_token = create_access_token(identity=current_user_id)
        
        return jsonify({
            'access_token': new_token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Token refresh error: {str(e)}")
        return jsonify({'message': 'Token refresh failed', 'error': str(e)}), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """Get user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        return jsonify({
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Get profile error: {str(e)}")
        return jsonify({'message': 'Failed to get profile', 'error': str(e)}), 500

@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    """Update user profile"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        data = request.get_json()
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        # Update allowed fields
        if 'first_name' in data:
            user.first_name = data['first_name'].strip() or None
        
        if 'last_name' in data:
            user.last_name = data['last_name'].strip() or None
        
        if 'email' in data:
            new_email = data['email'].strip().lower()
            try:
                valid_email = validate_email(new_email)
                new_email = valid_email.email
                
                # Check if email is already taken by another user
                existing_user = User.query.filter_by(email=new_email).first()
                if existing_user and existing_user.id != user.id:
                    return jsonify({'message': 'Email already taken'}), 409
                
                user.email = new_email
                user.email_verified = False  # Re-verify email
                
            except EmailNotValidError:
                return jsonify({'message': 'Invalid email address'}), 400
        
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Update profile error: {str(e)}")
        return jsonify({'message': 'Failed to update profile', 'error': str(e)}), 500

@auth_bp.route('/change-password', methods=['POST'])
@jwt_required()
def change_password():
    """Change user password"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        data = request.get_json()
        if not data:
            return jsonify({'message': 'No data provided'}), 400
        
        current_password = data.get('current_password', '')
        new_password = data.get('new_password', '')
        
        if not current_password or not new_password:
            return jsonify({'message': 'Current and new passwords are required'}), 400
        
        # Verify current password
        if not user.check_password(current_password):
            return jsonify({'message': 'Current password is incorrect'}), 401
        
        # Validate new password
        is_valid, password_message = validate_password(new_password)
        if not is_valid:
            return jsonify({'message': password_message}), 400
        
        # Set new password
        user.set_password(new_password)
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({'message': 'Password changed successfully'}), 200
        
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Change password error: {str(e)}")
        return jsonify({'message': 'Failed to change password', 'error': str(e)}), 500

@auth_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_user_stats():
    """Get user statistics"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        # Get dream statistics
        total_dreams = DreamAnalysis.query.filter_by(user_id=user.id).count()
        recent_dreams = DreamAnalysis.query.filter_by(user_id=user.id).filter(
            DreamAnalysis.created_at >= datetime.utcnow() - timedelta(days=30)
        ).count()
        
        return jsonify({
            'total_dreams': total_dreams,
            'recent_dreams': recent_dreams,
            'member_since': user.created_at.isoformat(),
            'last_login': user.last_login.isoformat() if user.last_login else None
        }), 200
        
    except Exception as e:
        current_app.logger.error(f"Get user stats error: {str(e)}")
        return jsonify({'message': 'Failed to get statistics', 'error': str(e)}), 500

# Token blacklist check
@auth_bp.before_app_request
def check_if_token_revoked():
    """Check if token is blacklisted"""
    try:
        verify_jwt_in_request(optional=True)
        jti = get_jwt().get('jti')
        if jti in blacklisted_tokens:
            return jsonify({'message': 'Token has been revoked'}), 401
    except:
        pass 