#!/usr/bin/env python3
"""
Railway Deployment Setup Script
This script helps you configure Railway deployment for your Flask app
"""

import os
import json
import secrets
import string
from urllib.parse import urlparse

def generate_secret_key(length=32):
    """Generate a secure secret key"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def check_railway_env():
    """Check if Railway environment is properly configured"""
    print("🔧 Checking Railway Environment Configuration")
    print("=" * 50)
    
    required_vars = {
        'FLASK_ENV': 'production',
        'SECRET_KEY': 'Flask secret key for sessions',
        'JWT_SECRET_KEY': 'JWT secret key for authentication',
        'DATABASE_URL': 'PostgreSQL database URL (auto-provided by Railway)',
        'OPENAI_API_KEY': 'OpenAI API key for dream analysis',
        'GOOGLE_APPLICATION_CREDENTIALS': 'Path to Google service account JSON',
        'GOOGLE_PLAY_DEVELOPER_EMAIL': 'Your Google Play Console email',
        'ALLOWED_ORIGINS': 'CORS allowed origins',
        'CORS_ORIGINS': 'CORS origins configuration'
    }
    
    missing_vars = []
    for var, description in required_vars.items():
        value = os.environ.get(var)
        if value:
            if var in ['SECRET_KEY', 'JWT_SECRET_KEY', 'OPENAI_API_KEY']:
                print(f"✅ {var}: {'*' * min(len(value), 20)}...")
            else:
                print(f"✅ {var}: {value}")
        else:
            print(f"❌ {var}: Missing - {description}")
            missing_vars.append(var)
    
    if missing_vars:
        print(f"\n⚠️  Missing {len(missing_vars)} required environment variables")
        generate_env_config()
    else:
        print("\n✅ All required environment variables are set!")
    
    return len(missing_vars) == 0

def generate_env_config():
    """Generate environment configuration for Railway"""
    print("\n📋 **Railway Environment Variables Configuration**")
    print("=" * 50)
    
    print("Copy these environment variables to your Railway project:")
    print("(Go to your Railway project → Variables → Add each variable)")
    print()
    
    # Generate secure keys
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
    
    for var, value in env_vars.items():
        print(f"{var}={value}")
    
    print("\n📝 **Additional Notes:**")
    print("- DATABASE_URL will be automatically provided by Railway when you add PostgreSQL")
    print("- Replace 'your-openai-api-key-here' with your actual OpenAI API key")
    print("- Replace 'your-play-console-email@gmail.com' with your Google Play Console email")
    print("- Upload your Google service account JSON file to Railway as 'service-account-key.json'")

def check_database_connection():
    """Check database connection"""
    database_url = os.environ.get('DATABASE_URL')
    if not database_url:
        print("❌ DATABASE_URL not set")
        return False
    
    try:
        # Parse database URL
        parsed = urlparse(database_url)
        print(f"✅ Database URL configured:")
        print(f"   Host: {parsed.hostname}")
        print(f"   Port: {parsed.port}")
        print(f"   Database: {parsed.path[1:]}")  # Remove leading slash
        print(f"   User: {parsed.username}")
        
        # Try to connect
        import psycopg2
        conn = psycopg2.connect(database_url)
        conn.close()
        print("✅ Database connection successful!")
        return True
        
    except ImportError:
        print("⚠️  psycopg2 not installed. Install with: pip install psycopg2-binary")
        return False
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def create_railway_deployment_guide():
    """Create deployment guide"""
    print("""
🚀 **Railway Deployment Guide**

1. **Create Railway Project**:
   - Go to: https://railway.app
   - Sign up/Login with GitHub
   - Click: New Project
   - Select: Deploy from GitHub repo
   - Choose your repository
   - Select: backend folder as root directory

2. **Add PostgreSQL Database**:
   - In your Railway project: Click New → Database → PostgreSQL
   - Railway will automatically create the database
   - DATABASE_URL will be automatically set

3. **Configure Environment Variables**:
   - Go to: Variables tab in your Railway project
   - Add all the environment variables shown above

4. **Upload Service Account Key**:
   - Create a file named 'service-account-key.json' in your backend directory
   - Copy your Google service account JSON content into this file
   - Commit and push to GitHub

5. **Deploy**:
   - Railway will automatically deploy when you push to main branch
   - Check deployment logs in Railway dashboard
   - Your app will be available at: https://your-project-name.railway.app

6. **Run Database Migrations**:
   - In Railway: Go to your service → Terminal
   - Run: flask db upgrade
   - Or use: railway run flask db upgrade (from local terminal)

7. **Test Deployment**:
   - Visit: https://your-project-name.railway.app/api/health
   - Should return: {"status": "healthy"}
""")

def main():
    print("🚀 Railway Deployment Setup Checker")
    print("=" * 50)
    
    # Check environment variables
    env_ok = check_railway_env()
    
    if env_ok:
        print("\n🔍 Checking database connection...")
        db_ok = check_database_connection()
        
        if db_ok:
            print("\n✅ Railway setup is complete!")
            print("Your app should be ready to deploy.")
        else:
            print("\n⚠️  Database connection issues detected.")
            print("Make sure PostgreSQL is added to your Railway project.")
    
    print("\n" + "=" * 50)
    create_railway_deployment_guide()

if __name__ == "__main__":
    main() 