from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from datetime import datetime
import uuid

db = SQLAlchemy()
bcrypt = Bcrypt()

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    username = db.Column(db.String(100), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(100), nullable=True)
    last_name = db.Column(db.String(100), nullable=True)
    phone_number = db.Column(db.String(20), nullable=True, unique=True)
    date_of_birth = db.Column(db.Date, nullable=True)
    gender = db.Column(db.String(20), nullable=True)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    email_verified = db.Column(db.Boolean, default=False, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_login = db.Column(db.DateTime, nullable=True)
    credits = db.Column(db.Integer, default=0, nullable=False)
    
    # Subscription fields
    subscription_status = db.Column(db.String(20), default='none', nullable=False)  # none, active, expired, cancelled
    subscription_type = db.Column(db.String(50), nullable=True)  # pack_10_dreams, pack_30_dreams
    subscription_start_date = db.Column(db.DateTime, nullable=True)
    subscription_end_date = db.Column(db.DateTime, nullable=True)
    subscription_auto_renew = db.Column(db.Boolean, default=True, nullable=False)
    
    # Relationships
    dreams = db.relationship('DreamAnalysis', backref='user', lazy=True, cascade='all, delete-orphan')
    sessions = db.relationship('UserSession', backref='user', lazy=True, cascade='all, delete-orphan')
    purchases = db.relationship('Purchase', backref='user', lazy=True, cascade='all, delete-orphan')
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')
    
    def check_password(self, password):
        """Check if password matches hash"""
        return bcrypt.check_password_hash(self.password_hash, password)
    
    def get_full_name(self):
        """Get user's full name"""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.username
    
    def get_dream_count(self):
        """Get total number of dreams analyzed"""
        return DreamAnalysis.query.filter_by(user_id=self.id).count()
    
    def to_dict(self):
        """Convert user to dictionary (excluding sensitive data)"""
        return {
            'id': str(self.id),
            'email': self.email,
            'username': self.username,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'full_name': self.get_full_name(),
            'is_active': self.is_active,
            'email_verified': self.email_verified,
            'created_at': self.created_at.isoformat(),
            'last_login': self.last_login.isoformat() if self.last_login else None,
            'dream_count': self.get_dream_count(),
            'credits': getattr(self, 'credits', 0),
            'subscription_status': getattr(self, 'subscription_status', 'none'),
            'subscription_type': getattr(self, 'subscription_type', None),
            'subscription_start_date': self.subscription_start_date.isoformat() if getattr(self, 'subscription_start_date', None) else None,
            'subscription_end_date': self.subscription_end_date.isoformat() if getattr(self, 'subscription_end_date', None) else None,
            'subscription_auto_renew': getattr(self, 'subscription_auto_renew', True)
        }

class UserSession(db.Model):
    __tablename__ = 'user_sessions'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    jti = db.Column(db.String(255), unique=True, nullable=False, index=True)  # JWT ID for token blacklisting
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    ip_address = db.Column(db.String(45), nullable=True)  # Support IPv6
    user_agent = db.Column(db.Text, nullable=True)

class DreamAnalysis(db.Model):
    __tablename__ = 'dream_analyses'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False, index=True)
    dream_text = db.Column(db.Text, nullable=False)
    analysis = db.Column(db.Text, nullable=False)
    advice = db.Column(db.Text, nullable=False)
    mood_before = db.Column(db.String(50), nullable=True)  # Optional mood tracking
    mood_after = db.Column(db.String(50), nullable=True)
    tags = db.Column(db.JSON, nullable=True)  # Store dream themes/tags
    is_private = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def to_dict(self):
        """Convert dream analysis to dictionary"""
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'dream_text': self.dream_text,
            'analysis': self.analysis,
            'advice': self.advice,
            'mood_before': self.mood_before,
            'mood_after': self.mood_after,
            'tags': self.tags or [],
            'is_private': self.is_private,
            'created_at': self.created_at.isoformat(),
            'timestamp': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

class Purchase(db.Model):
    __tablename__ = 'purchases'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False, index=True)
    product_id = db.Column(db.String(100), nullable=False)  # pack_10_dreams, pack_30_dreams
    purchase_token = db.Column(db.String(500), nullable=False, unique=True)
    order_id = db.Column(db.String(100), nullable=True)
    purchase_time = db.Column(db.DateTime, nullable=False)
    purchase_state = db.Column(db.Integer, nullable=False)  # 0=purchased, 1=cancelled
    consumption_state = db.Column(db.Integer, nullable=False)  # 0=not consumed, 1=consumed
    acknowledgement_state = db.Column(db.Integer, nullable=False)  # 0=not acknowledged, 1=acknowledged
    credits_granted = db.Column(db.Integer, default=0, nullable=False)
    is_subscription = db.Column(db.Boolean, default=True, nullable=False)
    subscription_period_start = db.Column(db.DateTime, nullable=True)
    subscription_period_end = db.Column(db.DateTime, nullable=True)
    auto_renewing = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def to_dict(self):
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'product_id': self.product_id,
            'purchase_token': self.purchase_token,
            'order_id': self.order_id,
            'purchase_time': self.purchase_time.isoformat(),
            'purchase_state': self.purchase_state,
            'consumption_state': self.consumption_state,
            'acknowledgement_state': self.acknowledgement_state,
            'credits_granted': self.credits_granted,
            'is_subscription': self.is_subscription,
            'subscription_period_start': self.subscription_period_start.isoformat() if self.subscription_period_start else None,
            'subscription_period_end': self.subscription_period_end.isoformat() if self.subscription_period_end else None,
            'auto_renewing': self.auto_renewing,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

class APIUsage(db.Model):
    __tablename__ = 'api_usage'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False, index=True)
    endpoint = db.Column(db.String(100), nullable=False)
    tokens_used = db.Column(db.Integer, default=0)
    cost = db.Column(db.Numeric(10, 6), default=0.0)  # Track API costs
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    user = db.relationship('User', backref='api_usage') 