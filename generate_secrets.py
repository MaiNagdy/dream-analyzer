#!/usr/bin/env python3
"""
Generate secure secret keys for deployment
Run this script and copy the output to your cloud service environment variables
"""

import secrets

def generate_secret_key():
    """Generate a secure secret key"""
    return secrets.token_hex(32)

if __name__ == "__main__":
    print("🔐 Generated Secret Keys for Deployment")
    print("=" * 50)
    print(f"SECRET_KEY={generate_secret_key()}")
    print(f"JWT_SECRET_KEY={generate_secret_key()}")
    print("=" * 50)
    print("\n📋 Copy these values to your cloud service environment variables")
    print("💡 Also set: FLASK_ENV=production")
    print("🤖 And add your: OPENAI_API_KEY=your-openai-key-here")
    print("\n🚀 Deployment Steps:")
    print("1. Choose a service: Railway (recommended), Render, or Heroku")
    print("2. Set all environment variables above")
    print("3. Deploy your backend")
    print("4. Update lib/config/app_config.dart with your deployment URL")
    print("5. Rebuild your APK: flutter build apk --release") 