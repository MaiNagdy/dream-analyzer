# Complete Subscription System Setup Guide

This guide will walk you through setting up the complete subscription system with Railway deployment, Flask backend, and Google Play Store configuration.

## 🎯 Overview

Your subscription system includes:
- **Flask Backend**: Handles subscription verification and user management
- **Railway Deployment**: Cloud hosting with PostgreSQL database
- **Google Play Store**: Subscription products and API integration
- **Flutter App**: Mobile app with in-app purchases

## 📋 Prerequisites

Before starting, ensure you have:
- Google Play Console Developer Account ($25 one-time fee)
- Railway account (free tier available)
- Flutter development environment set up
- Your app built and ready for testing

---

## 🏪 Step 1: Google Play Console Setup

### 1.1 Create Subscription Products

1. **Go to Google Play Console**: https://play.google.com/console
2. **Select your app** (or create a new one)
3. **Navigate to**: Products → Subscriptions
4. **Create two subscription products**:

   **Product 1: Basic Plan**
   - Product ID: `pack_10_dreams`
   - Name: `10 Dreams Monthly`
   - Description: `10 dream analyses per month`
   - Price: `$10.00 USD`
   - Billing period: `Monthly`
   - Free trial: `3 days` (optional)

   **Product 2: Premium Plan**
   - Product ID: `pack_30_dreams`
   - Name: `30 Dreams Monthly`
   - Description: `30 dream analyses per month`
   - Price: `$20.00 USD`
   - Billing period: `Monthly`
   - Free trial: `7 days` (optional)

5. **Activate both products** once created

### 1.2 Set Up Google Play API Access

1. **Navigate to**: APIs & Services → Google Play Console API
2. **Enable** the Google Play Developer API
3. **Create Service Account**:
   - Go to: APIs & Services → Credentials
   - Click: Create Credentials → Service Account
   - Name: `dream-app-subscription-service`
   - Description: `Service account for subscription verification`
   - Role: `Service Account User`

4. **Generate Service Account Key**:
   - Click on the created service account
   - Go to: Keys → Add Key → Create New Key
   - Type: `JSON`
   - **Download and save** the JSON file securely

5. **Grant Permissions in Play Console**:
   - Go to: Play Console → Users and Permissions
   - Click: Invite New Users
   - Email: Use the service account email from the JSON file
   - Permissions: Select `View app information and download bulk reports`
   - Click: Send Invitation

---

## 🚀 Step 2: Railway Setup

### 2.1 Create Railway Project

1. **Go to Railway**: https://railway.app
2. **Sign up/Login** with GitHub
3. **Create New Project**:
   - Click: New Project
   - Select: Deploy from GitHub repo
   - Choose your repository
   - Select: `backend` folder as root directory

### 2.2 Add PostgreSQL Database

1. **In your Railway project**:
   - Click: New → Database → PostgreSQL
   - Railway will automatically create the database
   - Note the connection details

### 2.3 Configure Environment Variables

In your Railway project, go to Variables and add:

```env
# Flask Configuration
FLASK_ENV=production
SECRET_KEY=your-super-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here

# Database (Railway auto-provides these)
DATABASE_URL=postgresql://user:password@host:port/database

# OpenAI API
OPENAI_API_KEY=your-openai-api-key

# Google Play API
GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json
GOOGLE_PLAY_DEVELOPER_EMAIL=your-play-console-email@gmail.com

# App Configuration
ALLOWED_ORIGINS=*
CORS_ORIGINS=*
```

### 2.4 Upload Service Account Key

1. **Create a new file** in your backend directory: `service-account-key.json`
2. **Copy the contents** of the Google service account JSON file
3. **Add to Railway**: 
   - Go to: Settings → Environment
   - Add the JSON content as a file or encode it in base64

---

## 🔧 Step 3: Flask Backend Configuration

### 3.1 Update Backend Dependencies

Your `requirements.txt` should include:

```txt
flask==2.3.3
flask-cors==4.0.0
python-dotenv==1.0.0
flask-jwt-extended==4.5.3
flask-bcrypt==1.0.1
psycopg2-binary==2.9.7
sqlalchemy==2.0.23
flask-sqlalchemy==3.1.1
flask-migrate==4.0.5
marshmallow==3.20.1
flask-marshmallow==0.15.0
marshmallow-sqlalchemy==0.29.0
email-validator==2.1.0
openai==1.2.0
httpx==0.27.0
google-auth==2.29.0
google-auth-httplib2==0.2.0
google-auth-oauthlib==1.1.0
google-api-python-client==2.108.0
requests==2.31.0
```

### 3.2 Database Models

Your models should include subscription fields in the User model:

```python
class User(UserMixin, db.Model):
    # ... existing fields ...
    
    # Subscription fields
    subscription_status = db.Column(db.String(20), default='none')
    subscription_type = db.Column(db.String(50), nullable=True)
    subscription_start_date = db.Column(db.DateTime, nullable=True)
    subscription_end_date = db.Column(db.DateTime, nullable=True)
    subscription_auto_renew = db.Column(db.Boolean, default=True)
    
class Purchase(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.String(100), nullable=False)
    purchase_token = db.Column(db.Text, nullable=False)
    purchase_state = db.Column(db.Integer, nullable=False)
    purchase_time = db.Column(db.DateTime, nullable=False)
    # ... other fields
```

### 3.3 Subscription Endpoints

Your Flask app should have these endpoints:

```python
@app.route('/api/subscriptions/verify', methods=['POST'])
@jwt_required()
def verify_subscription():
    # Verify purchase with Google Play API
    # Update user subscription status
    # Return verification result

@app.route('/api/subscriptions/status', methods=['GET'])
@jwt_required()
def get_subscription_status():
    # Return current user's subscription status

@app.route('/api/subscriptions/cancel', methods=['POST'])
@jwt_required()
def cancel_subscription():
    # Cancel user's subscription
```

---

## 🗄️ Step 4: Database Migration

### 4.1 Initialize Database

```bash
# In your backend directory
flask db init
flask db migrate -m "Add subscription tables"
flask db upgrade
```

### 4.2 Railway Database Setup

1. **Connect to Railway database**:
   ```bash
   railway login
   railway link
   railway run flask db upgrade
   ```

2. **Or use Railway's built-in migration**:
   - Railway will automatically run migrations on deployment

---

## 📱 Step 5: Flutter App Configuration

### 5.1 Update App Configuration

In `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'https://your-railway-app.railway.app';
  
  // Subscription product IDs (must match Google Play Console)
  static const String basicSubscriptionId = 'pack_10_dreams';
  static const String premiumSubscriptionId = 'pack_30_dreams';
  
  // Subscription limits
  static const int basicDreamLimit = 10;
  static const int premiumDreamLimit = 30;
}
```

### 5.2 Update pubspec.yaml

Ensure you have the in-app purchase dependency:

```yaml
dependencies:
  in_app_purchase: ^3.2.3
```

---

## 🚀 Step 6: Deployment

### 6.1 Deploy to Railway

1. **Push your code** to GitHub
2. **Railway will automatically deploy** when you push to main branch
3. **Check deployment logs** in Railway dashboard
4. **Test your endpoints** using the Railway URL

### 6.2 Test Deployment

```bash
# Test health endpoint
curl https://your-railway-app.railway.app/health

# Test subscription status (requires auth token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-railway-app.railway.app/api/subscriptions/status
```

---

## 🧪 Step 7: Testing

### 7.1 Test Subscription Flow

1. **Build your Flutter app** for testing
2. **Install on test device**
3. **Use test Google accounts** (added in Play Console)
4. **Test subscription purchase flow**
5. **Verify backend receives and processes purchases**

### 7.2 Test Accounts Setup

1. **Go to Play Console** → Setup → License Testing
2. **Add test accounts** (Gmail addresses)
3. **These accounts can make test purchases** without being charged

---

## 🔐 Step 8: Security & Production

### 8.1 Security Checklist

- [ ] Service account key is securely stored
- [ ] Environment variables are properly set
- [ ] Database credentials are secure
- [ ] JWT secrets are strong and unique
- [ ] CORS is properly configured
- [ ] API endpoints are properly authenticated

### 8.2 Production Deployment

1. **Test thoroughly** with test accounts
2. **Submit app for review** in Play Console
3. **Activate subscriptions** after app approval
4. **Monitor logs** and user feedback

---

## 📊 Step 9: Monitoring & Analytics

### 9.1 Set Up Monitoring

- **Railway Logs**: Monitor application logs
- **Google Play Console**: Track subscription metrics
- **Database Monitoring**: Monitor database performance
- **Error Tracking**: Set up error logging

### 9.2 Key Metrics to Track

- Subscription conversion rates
- Churn rates
- Revenue metrics
- API response times
- Error rates

---

## 🆘 Troubleshooting

### Common Issues

1. **"Service account not found"**: Ensure service account is properly configured in Play Console
2. **"Invalid purchase token"**: Check that product IDs match between app and Play Console
3. **"Database connection failed"**: Verify DATABASE_URL environment variable
4. **"CORS errors"**: Check CORS configuration in Flask app

### Debug Commands

```bash
# Check Railway logs
railway logs

# Test database connection
railway run python -c "from models import db; print(db.engine.url)"

# Test Google Play API
railway run python -c "from subscriptions import verify_purchase; print('API working')"
```

---

## 📞 Support

If you encounter issues:

1. **Check Railway logs** for backend errors
2. **Check Flutter logs** for mobile app errors
3. **Review Google Play Console** for subscription setup issues
4. **Test with different accounts** to isolate issues

---

## 🎉 Next Steps

After completing this setup:

1. **Test thoroughly** with multiple scenarios
2. **Add analytics** to track user behavior
3. **Implement push notifications** for subscription events
4. **Add customer support** features
5. **Plan for scaling** as your user base grows

Your subscription system is now fully configured and ready for production! 