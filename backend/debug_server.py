import os
import sys
from dotenv import load_dotenv

# Print Python version and path
print(f"Python version: {sys.version}")
print(f"Python executable: {sys.executable}")
print(f"Current directory: {os.getcwd()}")

# Check if .env file exists
print(f"\n.env file exists: {os.path.exists('.env')}")
if os.path.exists('.env'):
    try:
        with open('.env', 'r') as f:
            content = f.read()
            print(f".env file content preview: {content[:50]}...")
            print(f"Total lines in .env: {len(content.split('\\n'))}")
    except Exception as e:
        print(f"Error reading .env file: {e}")

# Load environment variables from .env file
print("\nLoading environment variables...")
load_dotenv(verbose=True)

# Check OpenAI API key
openai_key = os.environ.get('OPENAI_API_KEY')
print(f"OPENAI_API_KEY exists: {bool(openai_key)}")
if openai_key:
    masked_key = f"{openai_key[:5]}...{openai_key[-4:]}" if len(openai_key) > 10 else "***masked***"
    print(f"OPENAI_API_KEY value: {masked_key}")

# Import and run the Flask app
print("\nStarting Flask server with debug mode...")
try:
    from app import create_app
    app = create_app()
    app.config['DEBUG'] = True
    app.run(host='0.0.0.0', port=5000, debug=True)
except Exception as e:
    print(f"Error starting Flask server: {e}")
    import traceback
    traceback.print_exc() 