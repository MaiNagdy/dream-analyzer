import os
import sys
from dotenv import load_dotenv
import requests
import json

def check_env_file():
    """Check if .env file exists and has required variables"""
    print("Checking .env file...")
    
    # Check if .env file exists
    if not os.path.exists('.env'):
        print("❌ .env file not found in current directory!")
        print("Creating a sample .env file...")
        
        with open('.env', 'w') as f:
            f.write("""# Flask settings
SECRET_KEY=your_secret_key_here
JWT_SECRET_KEY=your_jwt_secret_key_here
FLASK_ENV=development

# OpenAI settings
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=1000
OPENAI_TEMPERATURE=0.7
""")
        print("✅ Sample .env file created. Please edit it with your actual values.")
        return False
    
    print("✅ .env file found")
    
    # Load environment variables
    load_dotenv()
    
    # Check required variables
    required_vars = [
        'SECRET_KEY',
        'JWT_SECRET_KEY',
        'OPENAI_API_KEY'
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.environ.get(var):
            missing_vars.append(var)
    
    if missing_vars:
        print(f"❌ Missing required environment variables: {', '.join(missing_vars)}")
        return False
    
    print("✅ All required environment variables found")
    
    # Check OpenAI API key format
    openai_key = os.environ.get('OPENAI_API_KEY')
    if not openai_key.startswith('sk-'):
        print("⚠️ Warning: OpenAI API key doesn't start with 'sk-'. This might not be a valid key.")
    
    # Mask the API key for display
    masked_key = f"{openai_key[:5]}...{openai_key[-4:]}" if len(openai_key) > 10 else "***masked***"
    print(f"OpenAI API key: {masked_key}")
    
    return True

def test_openai_api():
    """Test if OpenAI API key works"""
    print("\nTesting OpenAI API key...")
    
    openai_key = os.environ.get('OPENAI_API_KEY')
    if not openai_key:
        print("❌ No OpenAI API key found in environment variables")
        return False
    
    try:
        response = requests.get(
            "https://api.openai.com/v1/models",
            headers={"Authorization": f"Bearer {openai_key}"}
        )
        
        if response.status_code == 200:
            models = response.json()
            print("✅ OpenAI API key is valid!")
            print(f"Available models: {len(models['data'])}")
            print("First few models:")
            for model in models['data'][:3]:
                print(f"- {model['id']}")
            return True
        else:
            print(f"❌ OpenAI API key validation failed: {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"❌ Error testing OpenAI API: {e}")
        return False

def check_openai_package():
    """Check OpenAI package version"""
    print("\nChecking OpenAI package...")
    
    try:
        import openai
        print(f"✅ OpenAI package installed, version: {openai.__version__}")
        
        # Check if version is compatible
        version = openai.__version__
        major_version = int(version.split('.')[0])
        
        if major_version >= 1:
            print("✅ Using OpenAI v1+ client format")
            
            # Check if we can import the new client
            try:
                from openai import OpenAI
                print("✅ OpenAI client can be imported")
            except ImportError:
                print("❌ Cannot import OpenAI client. Try reinstalling the package.")
        else:
            print("⚠️ Using legacy OpenAI client format (v0.x)")
            print("   Consider upgrading to v1.0+ with: pip install openai==1.14.3")
        
        return True
    except ImportError:
        print("❌ OpenAI package not installed")
        print("   Install it with: pip install openai==1.14.3")
        return False

def main():
    """Main function"""
    print("=" * 50)
    print("Dream Analysis App Environment Check")
    print("=" * 50)
    
    env_ok = check_env_file()
    openai_pkg_ok = check_openai_package()
    
    if env_ok:
        api_ok = test_openai_api()
    else:
        api_ok = False
    
    print("\n" + "=" * 50)
    print("Summary:")
    print(f"- Environment file: {'✅ OK' if env_ok else '❌ Issues found'}")
    print(f"- OpenAI package: {'✅ OK' if openai_pkg_ok else '❌ Issues found'}")
    print(f"- OpenAI API key: {'✅ Valid' if api_ok else '❌ Invalid or not tested'}")
    print("=" * 50)
    
    if not (env_ok and openai_pkg_ok and api_ok):
        print("\nRecommended actions:")
        if not env_ok:
            print("1. Create or update your .env file with the required variables")
        if not openai_pkg_ok:
            print("2. Install the OpenAI package: pip install openai==1.14.3")
        if not api_ok:
            print("3. Get a valid OpenAI API key from https://platform.openai.com/api-keys")
    else:
        print("\n✅ All checks passed! Your environment is properly configured.")

if __name__ == "__main__":
    main() 