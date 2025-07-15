#!/usr/bin/env python3
"""
Railway Environment Variables Generator
This script generates all the environment variables needed for Railway deployment
"""

import secrets
import json

def generate_railway_env_vars():
    """Generate all environment variables for Railway"""
    
    print("🚀 Railway Environment Variables Generator")
    print("=" * 60)
    
    # Use the previously generated keys
    secret_key = "c507ebf4b19a753fef5362eb16169efc31fff5d607c3f8abc06db19a6856fa73"
    jwt_secret = "a0eb58803234413db9b5ec46dc4d42f9d82a65362ddb8f45792fad547df3f0fb"
    
    # Environment variables for Railway
    env_vars = {
        "FLASK_ENV": "production",
        "SECRET_KEY": secret_key,
        "JWT_SECRET_KEY": jwt_secret,
        "OPENAI_API_KEY": "your-openai-api-key-here",
        "GOOGLE_APPLICATION_CREDENTIALS": "/app/service-account-key.json",
        "GOOGLE_PLAY_DEVELOPER_EMAIL": "your-email@gmail.com",
        "ALLOWED_ORIGINS": "*",
        "CORS_ORIGINS": "*"
    }
    
    print("📋 **Copy these environment variables to your Railway project:**")
    print("(Go to your Railway project → Variables → Add each variable)")
    print()
    
    for key, value in env_vars.items():
        print(f"{key}={value}")
    
    print("\n" + "=" * 60)
    print("📝 **Important Notes:**")
    print("- DATABASE_URL will be automatically provided by Railway when you add PostgreSQL")
    print("- Replace 'your-openai-api-key-here' with your actual OpenAI API key")
    print("- Replace 'your-email@gmail.com' with your Google Play Console email")
    print("- The service-account-key.json file should be in your backend directory")
    print()
    
    return env_vars

def create_railway_instructions():
    """Create detailed Railway deployment instructions"""
    
    instructions = """
🚀 **Railway Deployment Instructions**

**Step 1: Create Railway Project**
1. Go to: https://railway.app
2. Sign up with GitHub account
3. Click: New Project
4. Select: Deploy from GitHub repo
5. Choose your repository: dinning
6. Set root directory: backend
7. Railway will detect Python Flask app

**Step 2: Add PostgreSQL Database**
1. In Railway dashboard: Click New → Database → PostgreSQL
2. Railway will automatically create DATABASE_URL environment variable

**Step 3: Configure Environment Variables**
1. Go to: Variables tab in your Railway project
2. Add each environment variable shown above
3. Make sure to replace placeholder values with actual values

**Step 4: Upload Service Account Key**
1. Make sure service-account-key.json is in your backend directory
2. Commit and push to GitHub:
   ```bash
   git add backend/service-account-key.json
   git commit -m "Add Google service account key"
   git push origin main
   ```

**Step 5: Deploy**
1. Railway will automatically deploy when you push to main
2. Monitor deployment in Railway dashboard
3. Check logs for any errors

**Step 6: Run Database Migrations**
After successful deployment:
1. Go to Railway project → Service → Terminal
2. Run: flask db upgrade
3. This will create all database tables

**Step 7: Test Deployment**
1. Get your Railway app URL (e.g., https://your-app.railway.app)
2. Test health endpoint: https://your-app.railway.app/api/health
3. Should return: {"status": "healthy"}

**Step 8: Update Flutter App**
Update lib/config/app_config.dart:
```dart
class AppConfig {
  static const String baseUrl = 'https://your-app.railway.app';
  // ... rest of config
}
```
"""
    
    print(instructions)

def main():
    """Main function"""
    env_vars = generate_railway_env_vars()
    create_railway_instructions()
    
    print("\n🎯 **Ready for Railway Deployment!**")
    print("Follow the instructions above to deploy your app to Railway.")

if __name__ == "__main__":
    main() 