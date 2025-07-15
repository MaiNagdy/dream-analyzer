# Google Play API Service Account Setup

## Step 1: Create Google Cloud Project
1. Go to: https://console.cloud.google.com
2. Create a new project or select existing one
3. Note your Project ID

## Step 2: Enable Google Play Developer API
1. Go to: APIs & Services → Library
2. Search for: "Google Play Developer API"
3. Click: Enable

## Step 3: Create Service Account
1. Go to: APIs & Services → Credentials
2. Click: Create Credentials → Service Account
3. Fill in details:
   - **Name**: `dream-app-subscription-service`
   - **Service account ID**: `dream-app-subscription`
   - **Description**: `Service account for subscription verification`
4. Click: Create and Continue
5. Skip role assignment for now
6. Click: Done

## Step 4: Generate Service Account Key
1. Click on the created service account
2. Go to: Keys tab
3. Click: Add Key → Create New Key
4. Select: JSON
5. Click: Create
6. **Download and save the JSON file securely**

## Step 5: Grant Permissions in Play Console
1. Go to: https://play.google.com/console
2. Go to: Users and Permissions
3. Click: Invite New Users
4. Enter the service account email (from JSON file)
5. Select permissions:
   - ✅ View app information and download bulk reports
   - ✅ View financial data, orders, and cancellation survey responses
   - ✅ Manage orders and subscriptions
6. Click: Send Invitation

## Step 6: Accept Invitation
1. The service account will receive an email invitation
2. You need to accept it (check the email associated with your Google account)

## Step 7: Test the Setup
Run the test script to verify everything is working:
```bash
cd backend
python setup_google_service_account.py
```

## Important Files:
- Save the JSON file as `service-account-key.json` in your backend directory
- Add this file to your `.gitignore` (never commit it to version control)
- Set environment variable: `GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json`

## Troubleshooting:
- If you get "Service account not found" errors, check the email invitation
- If you get "Permission denied" errors, verify the permissions in Play Console
- Make sure the service account has access to your specific app 