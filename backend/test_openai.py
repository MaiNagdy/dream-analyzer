import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Check if OpenAI API key is set
openai_api_key = os.environ.get('OPENAI_API_KEY')
print(f"OpenAI API key exists: {bool(openai_api_key)}")
if openai_api_key:
    # Hide most of the key but show first 3 and last 4 characters
    masked_key = f"{openai_api_key[:3]}...{openai_api_key[-4:]}"
    print(f"API key (masked): {masked_key}")

# Try to import OpenAI
try:
    import openai
    print(f"OpenAI version: {openai.__version__}")
    
    # Try to use the API
    try:
        # Try new OpenAI API format first
        try:
            from openai import OpenAI
            client = OpenAI(api_key=openai_api_key)
            print("Testing with new OpenAI client...")
            response = client.models.list()
            print("API test successful with new client!")
            print(f"Available models: {[model.id for model in response.data[:3]]}")
        except Exception as new_api_error:
            print(f"New OpenAI client error: {str(new_api_error)}")
            
            # Fallback to old OpenAI format
            print("Testing with legacy OpenAI client...")
            openai.api_key = openai_api_key
            response = openai.Model.list()
            print("API test successful with legacy client!")
            print(f"Available models: {[model.id for model in response['data'][:3]]}")
    except Exception as e:
        print(f"API test failed: {str(e)}")
except ImportError:
    print("OpenAI package not installed") 