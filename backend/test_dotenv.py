import os
from dotenv import load_dotenv

# Load environment variables from .env file
print("Attempting to load .env file...")
load_dotenv()

# Check if OPENAI_API_KEY is set
openai_key = os.environ.get('OPENAI_API_KEY')
print(f"OPENAI_API_KEY exists: {bool(openai_key)}")

if openai_key:
    # Mask the key for security
    masked_key = f"{openai_key[:5]}...{openai_key[-4:]}" if len(openai_key) > 10 else "***masked***"
    print(f"OPENAI_API_KEY value: {masked_key}")
else:
    print("OPENAI_API_KEY not found in environment variables")

# List all environment variables from .env
print("\nAll environment variables from .env:")
env_vars = ['SECRET_KEY', 'JWT_SECRET_KEY', 'FLASK_ENV', 'OPENAI_MODEL', 'OPENAI_MAX_TOKENS', 'OPENAI_TEMPERATURE']
for var in env_vars:
    value = os.environ.get(var)
    if value:
        print(f"- {var}: {value[:10]}..." if len(str(value)) > 10 else f"- {var}: {value}")
    else:
        print(f"- {var}: Not set")

# Print current directory and check if .env exists
print(f"\nCurrent directory: {os.getcwd()}")
print(f".env file exists: {os.path.exists('.env')}")

# Try to read the .env file
try:
    if os.path.exists('.env'):
        with open('.env', 'r') as f:
            content = f.read()
            print(f"\n.env file content (first line): {content.split('\\n')[0]}")
            print(f"Total lines in .env: {len(content.split('\\n'))}")
    else:
        print("\n.env file does not exist in current directory")
except Exception as e:
    print(f"Error reading .env file: {e}") 