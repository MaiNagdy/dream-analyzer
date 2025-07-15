#!/usr/bin/env python3
"""
Complete Subscription System Deployment Setup
This script guides you through the entire deployment process
"""

import os
import sys
import json
import subprocess
import secrets
import string
from urllib.parse import urlparse

def print_header(title):
    """Print a formatted header"""
    print("\n" + "=" * 60)
    print(f"🚀 {title}")
    print("=" * 60)

def print_step(step_num, title):
    """Print a step header"""
    print(f"\n📋 **Step {step_num}: {title}**")
    print("-" * 50)

def generate_secret_key(length=32):
    """Generate a secure secret key"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def check_prerequisites():
    """Check if all prerequisites are met"""
    print_step(1, "Checking Prerequisites")
    
    requirements = {
        'Python': sys.version_info >= (3, 8),
        'pip': True,
        'Git': True,
        'Railway CLI': False  # Optional
    }
    
    all_good = True
    
    # Check Python version
    if requirements['Python']:
        print(f"✅ Python {sys.version.split()[0]} - OK")
    else:
        print("❌ Python 3.8+ required")
        all_good = False
    
    # Check pip
    try:
        import pip
        print("✅ pip - OK")
    except ImportError:
        print("❌ pip not found")
        all_good = False
    
    # Check git
    try:
        subprocess.run(['git', '--version'], capture_output=True, check=True)
        print("✅ Git - OK")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Git not found")
        all_good = False
    
    # Check Railway CLI (optional)
    try:
        subprocess.run(['railway', '--version'], capture_output=True, check=True)
        print("✅ Railway CLI - OK")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("⚠️  Railway CLI not found (optional)")
        print("   Install with: npm install -g @railway/cli")
    
    if not all_good:
        print("\n❌ Please install missing prerequisites before continuing")
        return False
    
    print("\n✅ All prerequisites met!")
    return True

def google_play_console_setup():
    """Guide through Google Play Console setup"""
    print_step(2, "Google Play Console Setup")
    
    print("""
🏪 **Set up subscription products in Google Play Console**

1. Go to: https://play.google.com/console
2. Select your app (or create a new one)
3. Navigate to: Products → Subscriptions
4. Create two subscription products:

   **Product 1: Basic Plan**
   - Product ID: pack_10_dreams
   - Name: 10 Dreams Monthly
   - Description: 10 dream analyses per month
   - Price: $10.00 USD
   - Billing period: Monthly
   - Free trial: 3 days (optional)

   **Product 2: Premium Plan**
   - Product ID: pack_30_dreams
   - Name: 30 Dreams Monthly
   - Description: 30 dream analyses per month
   - Price: $20.00 USD
   - Billing period: Monthly
   - Free trial: 7 days (optional)

5. Activate both products once created

🔑 **Set up Google Play API Service Account**

1. Go to: https://console.cloud.google.com
2. Select or create a project
3. Enable Google Play Developer API:
   - Go to: APIs & Services → Library
   - Search for: "Google Play Developer API"
   - Click: Enable

4. Create Service Account:
   - Go to: APIs & Services → Credentials
   - Click: Create Credentials → Service Account
   - Name: dream-app-subscription-service
   - Description: Service account for subscription verification
   - Role: Service Account User

5. Generate Service Account Key:
   - Click on the created service account
   - Go to: Keys → Add Key → Create New Key
   - Type: JSON
   - Download and save the JSON file

6. Grant Permissions in Play Console:
   - Go to: Play Console → Users and Permissions
   - Click: Invite New Users
   - Email: Use the service account email from the JSON file
   - Permissions: Select "View app information and download bulk reports"
   - Click: Send Invitation
""")
    
    input("Press Enter when you've completed the Google Play Console setup...")

def setup_service_account():
    """Set up Google service account"""
    print_step(3, "Google Service Account Configuration")
    
    service_account_path = input("Enter the path to your service account JSON file: ").strip()
    
    if not os.path.exists(service_account_path):
        print(f"❌ File not found: {service_account_path}")
        return False
    
    try:
        with open(service_account_path, 'r') as f:
            service_account_data = json.load(f)
        
        # Validate service account file
        required_fields = ['type', 'project_id', 'private_key_id', 'private_key', 'client_email']
        missing_fields = [field for field in required_fields if field not in service_account_data]
        
        if missing_fields:
            print(f"❌ Service account file missing required fields: {missing_fields}")
            return False
        
        # Copy service account file to backend directory
        backend_service_account_path = os.path.join(os.path.dirname(__file__), 'service-account-key.json')
        with open(backend_service_account_path, 'w') as f:
            json.dump(service_account_data, f, indent=2)
        
        print("✅ Service account file configured")
        print(f"   Client email: {service_account_data['client_email']}")
        print(f"   Project ID: {service_account_data['project_id']}")
        print(f"   Saved to: {backend_service_account_path}")
        
        return True
        
    except json.JSONDecodeError:
        print("❌ Service account file is not valid JSON")
        return False
    except Exception as e:
        print(f"❌ Error processing service account file: {e}")
        return False

def railway_setup():
    """Guide through Railway setup"""
    print_step(4, "Railway Setup")
    
    print("""
🚀 **Create Railway Project**

1. Go to: https://railway.app
2. Sign up/Login with GitHub
3. Click: New Project
4. Select: Deploy from GitHub repo
5. Choose your repository
6. Select: backend folder as root directory

🗄️ **Add PostgreSQL Database**

1. In your Railway project: Click New → Database → PostgreSQL
2. Railway will automatically create the database
3. DATABASE_URL will be automatically set

📝 **Configure Environment Variables**

Go to Variables tab in your Railway project and add these variables:
""")
    
    # Generate environment variables
    secret_key = generate_secret_key(32)
    jwt_secret = generate_secret_key(32)
    
    env_vars = {
        'FLASK_ENV': 'production',
        'SECRET_KEY': secret_key,
        'JWT_SECRET_KEY': jwt_secret,
        'OPENAI_API_KEY': 'your-openai-api-key-here',
        'GOOGLE_APPLICATION_CREDENTIALS': '/app/service-account-key.json',
        'GOOGLE_PLAY_DEVELOPER_EMAIL': 'your-play-console-email@gmail.com',
        'ALLOWED_ORIGINS': '*',
        'CORS_ORIGINS': '*'
    }
    
    print("Copy these environment variables to your Railway project:")
    print("(Go to your Railway project → Variables → Add each variable)")
    print()
    
    for var, value in env_vars.items():
        print(f"{var}={value}")
    
    print("""
📝 **Important Notes:**
- DATABASE_URL will be automatically provided by Railway when you add PostgreSQL
- Replace 'your-openai-api-key-here' with your actual OpenAI API key
- Replace 'your-play-console-email@gmail.com' with your Google Play Console email
- The service-account-key.json file should be in your backend directory
""")
    
    input("Press Enter when you've completed the Railway setup...")

def test_local_setup():
    """Test local setup"""
    print_step(5, "Testing Local Setup")
    
    # Check if service account file exists
    service_account_path = os.path.join(os.path.dirname(__file__), 'service-account-key.json')
    if os.path.exists(service_account_path):
        print("✅ Service account file found")
    else:
        print("❌ Service account file not found")
        return False
    
    # Check if requirements are installed
    try:
        import flask
        import psycopg2
        import openai
        import google.auth
        print("✅ Required packages installed")
    except ImportError as e:
        print(f"❌ Missing package: {e}")
        print("Run: pip install -r requirements.txt")
        return False
    
    print("✅ Local setup looks good!")
    return True

def deployment_checklist():
    """Show deployment checklist"""
    print_step(6, "Deployment Checklist")
    
    checklist = [
        "✅ Google Play Console subscription products created",
        "✅ Google Play API service account configured",
        "✅ Railway project created with PostgreSQL database",
        "✅ Environment variables configured in Railway",
        "✅ Service account JSON file in backend directory",
        "✅ Code committed and pushed to GitHub",
    ]
    
    print("Before deploying, make sure you have:")
    for item in checklist:
        print(f"  {item}")
    
    print("""
🚀 **Deploy to Railway**

1. Push your code to GitHub (if not already done):
   git add .
   git commit -m "Add subscription system"
   git push origin main

2. Railway will automatically deploy when you push to main branch

3. Check deployment logs in Railway dashboard

4. Your app will be available at: https://your-project-name.railway.app

5. Run database migrations:
   - In Railway: Go to your service → Terminal
   - Run: flask db upgrade
   - Or use: railway run flask db upgrade (from local terminal)

6. Test deployment:
   - Visit: https://your-project-name.railway.app/api/health
   - Should return: {"status": "healthy"}
""")

def flutter_app_configuration():
    """Guide through Flutter app configuration"""
    print_step(7, "Flutter App Configuration")
    
    print("""
📱 **Update Flutter App Configuration**

1. Update lib/config/app_config.dart:

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

2. Make sure pubspec.yaml includes:
```yaml
dependencies:
  in_app_purchase: ^3.2.3
```

3. Test the app:
   - Build and run on test device
   - Test subscription flow with test accounts
   - Verify backend integration
""")

def final_testing():
    """Guide through final testing"""
    print_step(8, "Final Testing")
    
    print("""
🧪 **Testing Your Subscription System**

1. **Set up test accounts in Play Console**:
   - Go to: Play Console → Setup → License Testing
   - Add test Gmail accounts
   - These accounts can make test purchases without being charged

2. **Test subscription flow**:
   - Install app on test device
   - Sign in with test account
   - Attempt to purchase subscription
   - Verify purchase is processed correctly
   - Check backend logs for verification

3. **Test backend endpoints**:
   - GET /api/subscriptions/status
   - POST /api/subscriptions/verify
   - POST /api/subscriptions/cancel

4. **Monitor logs**:
   - Railway deployment logs
   - Flutter app logs
   - Google Play Console reports

5. **Test edge cases**:
   - Network interruptions during purchase
   - App restart during purchase
   - Subscription renewal
   - Subscription cancellation
""")

def main():
    """Main setup function"""
    print_header("Complete Subscription System Setup")
    
    print("""
This script will guide you through setting up your complete subscription system:
- Google Play Console configuration
- Google Play API service account
- Railway deployment
- Flask backend configuration
- Flutter app integration
- Testing and verification

Let's get started!
""")
    
    # Check prerequisites
    if not check_prerequisites():
        return
    
    # Google Play Console setup
    google_play_console_setup()
    
    # Service account setup
    if not setup_service_account():
        print("❌ Service account setup failed. Please try again.")
        return
    
    # Railway setup
    railway_setup()
    
    # Test local setup
    if not test_local_setup():
        print("❌ Local setup test failed. Please check your configuration.")
        return
    
    # Show deployment checklist
    deployment_checklist()
    
    # Flutter app configuration
    flutter_app_configuration()
    
    # Final testing
    final_testing()
    
    print_header("Setup Complete!")
    print("""
🎉 **Congratulations!** 

Your subscription system setup is complete. Here's what you've accomplished:

✅ Google Play Console configured with subscription products
✅ Google Play API service account set up
✅ Railway project configured with PostgreSQL database
✅ Flask backend ready for deployment
✅ Flutter app configured for subscriptions

🚀 **Next Steps:**
1. Deploy to Railway by pushing your code to GitHub
2. Run database migrations
3. Test the subscription flow with test accounts
4. Submit your app for review in Google Play Console

📞 **Need Help?**
- Check Railway logs for backend issues
- Check Flutter logs for mobile app issues
- Review Google Play Console for subscription setup issues

Good luck with your dream analysis app! 🌙✨
""")

if __name__ == "__main__":
    main() 