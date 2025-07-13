from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
import os, json, requests
import google.oauth2.service_account as service_account
import google.auth.transport.requests as google_requests
from models import db, User

purchases_bp = Blueprint('purchases', __name__)

# Config constants
PACKAGE_NAME = os.getenv('ANDROID_PACKAGE_NAME', 'com.example.dream_app')
SERVICE_JSON_PATH = os.getenv('GOOGLE_SERVICE_ACCOUNT_JSON', 'service-account.json')
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']

PRODUCT_CREDITS = {
    'pack_10_dreams': 10,
    'pack_40_dreams': 40,
}

def _verify_purchase_google(product_id: str, purchase_token: str):
    """Return True if purchase is valid and completed"""
    if not os.path.isfile(SERVICE_JSON_PATH):
        current_app.logger.error('Service account JSON not found')
        return False, {'error': 'service_account_missing'}

    creds = service_account.Credentials.from_service_account_file(
        SERVICE_JSON_PATH, scopes=SCOPES
    )
    creds.refresh(google_requests.Request())

    url = (
        'https://androidpublisher.googleapis.com/androidpublisher/v3'
        f'/applications/{PACKAGE_NAME}/purchases/products/{product_id}/tokens/{purchase_token}'
    )
    resp = requests.get(url, headers={'Authorization': f'Bearer {creds.token}'}).json()
    # purchaseState == 0 => purchased
    return resp.get('purchaseState') == 0, resp

@purchases_bp.route('/api/purchases/verify', methods=['POST'])
@jwt_required()
def verify_purchase():
    data = request.get_json() or {}
    product_id = data.get('productId')
    token = data.get('purchaseToken')

    if not product_id or not token:
        return jsonify({'message': 'Invalid payload'}), 400

    valid, google_resp = _verify_purchase_google(product_id, token)
    if not valid:
        return jsonify({'message': 'Purchase invalid', 'google': google_resp}), 400

    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404

    credits = PRODUCT_CREDITS.get(product_id, 0)
    if credits == 0:
        return jsonify({'message': 'Unknown product'}), 400

    # Add credits; create attribute if not exist
    current = getattr(user, 'credits', 0) or 0
    user.credits = current + credits
    user.updated_at = datetime.utcnow()
    db.session.commit()

    return jsonify({'success': True, 'creditsAdded': credits, 'totalCredits': user.credits}), 200 