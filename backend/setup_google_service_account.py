#!/usr/bin/env python3
"""
Google Play API Service Account Setup Script
This script helps you set up and test your Google Play API service account
"""

import os
import json
import sys
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

def check_service_account_file():
    """Check if service account file exists and is valid"""
    service_account_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if not service_account_file:
        print("❌ GOOGLE_APPLICATION_CREDENTIALS environment variable not set")
        return False
    
    if not os.path.exists(service_account_file):
        print(f"❌ Service account file not found: {service_account_file}")
        return False
    
    try:
        with open(service_account_file, 'r') as f:
            service_account_data = json.load(f)
        
        required_fields = ['type', 'project_id', 'private_key_id', 'private_key', 'client_email']
        missing_fields = [field for field in required_fields if field not in service_account_data]
        
        if missing_fields:
            print(f"❌ Service account file missing required fields: {missing_fields}")
            return False
        
        print("✅ Service account file is valid")
        print(f"   Client email: {service_account_data['client_email']}")
        print(f"   Project ID: {service_account_data['project_id']}")
        return True
        
    except json.JSONDecodeError:
        print("❌ Service account file is not valid JSON")
        return False
    except Exception as e:
        print(f"❌ Error reading service account file: {e}")
        return False

def test_google_play_api():
    """Test Google Play API access"""
    try:
        # Load service account credentials
        service_account_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
        credentials = service_account.Credentials.from_service_account_file(
            service_account_file,
            scopes=['https://www.googleapis.com/auth/androidpublisher']
        )
        
        # Build the service
        service = build('androidpublisher', 'v3', credentials=credentials)
        
        print("✅ Google Play API service created successfully")
        return service
        
    except Exception as e:
        print(f"❌ Error creating Google Play API service: {e}")
        return None

def test_app_access(service, package_name):
    """Test access to specific app"""
    try:
        # Try to get app details
        app_details = service.edits().get(
            packageName=package_name,
            editId='0'  # This will fail but shows if we have access
        ).execute()
        
        print(f"✅ Access to app {package_name} confirmed")
        return True
        
    except HttpError as e:
        if e.resp.status == 404:
            print(f"⚠️  App {package_name} not found or no access")
            print("   Make sure the service account has access to this app in Play Console")
        else:
            print(f"❌ Error accessing app {package_name}: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def create_service_account_instructions():
    """Print instructions for creating service account"""
    print("""
📋 **Google Play API Service Account Setup Instructions**

1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Select or create a project**
3. **Enable Google Play Developer API**:
   - Go to: APIs & Services → Library
   - Search for: "Google Play Developer API"
   - Click: Enable

4. **Create Service Account**:
   - Go to: APIs & Services → Credentials
   - Click: Create Credentials → Service Account
   - Name: dream-app-subscription-service
   - Description: Service account for subscription verification
   - Role: Service Account User

5. **Generate Service Account Key**:
   - Click on the created service account
   - Go to: Keys → Add Key → Create New Key
   - Type: JSON
   - Download and save the JSON file securely

6. **Grant Permissions in Play Console**:
   - Go to: Play Console → Users and Permissions
   - Click: Invite New Users
   - Email: Use the service account email from the JSON file
   - Permissions: Select "View app information and download bulk reports"
   - Click: Send Invitation

7. **Set Environment Variable**:
   - Set GOOGLE_APPLICATION_CREDENTIALS to the path of your JSON file
   - Example: export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"

8. **Test the setup** by running this script again
""")

def main():
    print("🔧 Google Play API Service Account Setup Checker")
    print("=" * 50)
    
    # Check if service account file exists and is valid
    if not check_service_account_file():
        print("\n" + "=" * 50)
        create_service_account_instructions()
        return
    
    # Test Google Play API access
    service = test_google_play_api()
    if not service:
        return
    
    # Test app access (you'll need to provide your package name)
    package_name = input("\nEnter your app's package name (e.g., com.example.dreamapp): ").strip()
    if package_name:
        test_app_access(service, package_name)
    
    print("\n✅ Setup check completed!")
    print("If all tests passed, your Google Play API service account is ready to use.")

if __name__ == "__main__":
    main() 