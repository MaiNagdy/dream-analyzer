import os
import json
import base64
import logging
from datetime import datetime, timedelta
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from models import db, User, Purchase

# Create blueprint
subscriptions_bp = Blueprint('subscriptions', __name__, url_prefix='/api/subscriptions')

# Configure logging
logger = logging.getLogger(__name__)

def get_google_play_service():
    """Initialize Google Play Developer API service"""
    try:
        # Get service account JSON from environment variable
        service_account_json = os.getenv('GOOGLE_SERVICE_ACCOUNT_JSON_BASE64')
        if not service_account_json:
            raise ValueError("GOOGLE_SERVICE_ACCOUNT_JSON_BASE64 environment variable not set")
        
        # Decode base64 JSON
        service_account_info = json.loads(base64.b64decode(service_account_json))
        
        # Create credentials
        credentials = Credentials.from_service_account_info(
            service_account_info,
            scopes=['https://www.googleapis.com/auth/androidpublisher']
        )
        
        # Build service
        service = build('androidpublisher', 'v3', credentials=credentials)
        return service
        
    except Exception as e:
        logger.error(f"Failed to initialize Google Play service: {str(e)}")
        raise

@subscriptions_bp.route('/verify', methods=['POST'])
@jwt_required()
def verify_subscription():
    """Verify subscription purchase with Google Play"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        product_id = data.get('productId')
        purchase_token = data.get('purchaseToken')
        
        if not product_id or not purchase_token:
            return jsonify({'error': 'Product ID and purchase token are required'}), 400
        
        # Validate product ID
        valid_products = ['pack_10_dreams', 'pack_30_dreams']
        if product_id not in valid_products:
            return jsonify({'error': 'Invalid product ID'}), 400
        
        # Check if purchase already exists
        existing_purchase = Purchase.query.filter_by(purchase_token=purchase_token).first()
        if existing_purchase:
            return jsonify({
                'status': 'already_processed',
                'subscription_status': user.subscription_status,
                'message': 'Purchase already processed'
            }), 200
        
        # Initialize Google Play service
        service = get_google_play_service()
        package_name = os.getenv('ANDROID_PACKAGE_NAME')
        
        if not package_name:
            return jsonify({'error': 'Android package name not configured'}), 500
        
        # Verify subscription with Google Play
        try:
            result = service.purchases().subscriptions().get(
                packageName=package_name,
                subscriptionId=product_id,
                token=purchase_token
            ).execute()
            
            logger.info(f"Google Play verification result: {result}")
            
        except HttpError as e:
            logger.error(f"Google Play API error: {str(e)}")
            return jsonify({'error': 'Failed to verify purchase with Google Play'}), 400
        
        # Parse subscription data
        start_time_millis = int(result.get('startTimeMillis', 0))
        expiry_time_millis = int(result.get('expiryTimeMillis', 0))
        auto_renewing = result.get('autoRenewing', False)
        purchase_state = result.get('purchaseState', 1)  # 0=purchased, 1=cancelled
        
        # Convert timestamps
        start_time = datetime.fromtimestamp(start_time_millis / 1000) if start_time_millis else datetime.utcnow()
        expiry_time = datetime.fromtimestamp(expiry_time_millis / 1000) if expiry_time_millis else (datetime.utcnow() + timedelta(days=30))
        
        # Determine credits based on product
        credits_to_add = {
            'pack_10_dreams': 10,
            'pack_30_dreams': 30
        }.get(product_id, 0)
        
        # Create purchase record
        purchase = Purchase(
            user_id=user.id,
            product_id=product_id,
            purchase_token=purchase_token,
            order_id=result.get('orderId'),
            purchase_time=start_time,
            purchase_state=purchase_state,
            consumption_state=0,  # Not consumed yet
            acknowledgement_state=1,  # Acknowledged
            credits_granted=credits_to_add,
            is_subscription=True,
            subscription_period_start=start_time,
            subscription_period_end=expiry_time,
            auto_renewing=auto_renewing
        )
        
        # Update user subscription status
        user.subscription_status = 'active' if purchase_state == 0 and expiry_time > datetime.utcnow() else 'expired'
        user.subscription_type = product_id
        user.subscription_start_date = start_time
        user.subscription_end_date = expiry_time
        user.subscription_auto_renew = auto_renewing
        user.credits += credits_to_add
        
        # Save to database
        db.session.add(purchase)
        db.session.commit()
        
        # Acknowledge purchase with Google Play
        try:
            service.purchases().subscriptions().acknowledge(
                packageName=package_name,
                subscriptionId=product_id,
                token=purchase_token,
                body={}
            ).execute()
            logger.info(f"Acknowledged subscription: {product_id}")
        except HttpError as e:
            logger.warning(f"Failed to acknowledge subscription: {str(e)}")
        
        return jsonify({
            'status': 'success',
            'message': 'Subscription verified and activated',
            'credits_added': credits_to_add,
            'total_credits': user.credits,
            'subscription_status': user.subscription_status,
            'subscription_type': user.subscription_type,
            'subscription_end_date': user.subscription_end_date.isoformat() if user.subscription_end_date else None
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Subscription verification error: {str(e)}")
        return jsonify({'error': 'Internal server error', 'details': str(e)}), 500

@subscriptions_bp.route('/status', methods=['GET'])
@jwt_required()
def get_subscription_status():
    """Get current user's subscription status"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Check if subscription is still valid
        now = datetime.utcnow()
        if user.subscription_end_date and user.subscription_end_date < now:
            user.subscription_status = 'expired'
            db.session.commit()
        
        return jsonify({
            'subscription_status': user.subscription_status,
            'subscription_type': user.subscription_type,
            'subscription_start_date': user.subscription_start_date.isoformat() if user.subscription_start_date else None,
            'subscription_end_date': user.subscription_end_date.isoformat() if user.subscription_end_date else None,
            'subscription_auto_renew': user.subscription_auto_renew,
            'credits': user.credits
        }), 200
        
    except Exception as e:
        logger.error(f"Get subscription status error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@subscriptions_bp.route('/cancel', methods=['POST'])
@jwt_required()
def cancel_subscription():
    """Cancel user's subscription"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Update subscription status
        user.subscription_auto_renew = False
        db.session.commit()
        
        return jsonify({
            'status': 'success',
            'message': 'Subscription will not auto-renew',
            'subscription_status': user.subscription_status
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.error(f"Cancel subscription error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500 