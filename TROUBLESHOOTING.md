# Dream Analysis App Troubleshooting Guide

This guide helps you troubleshoot common issues with the Dream Analysis app.

## Authentication Issues

### "Missing Authorization Header" Error

This error occurs when you try to access an endpoint that requires authentication without providing a valid JWT token.

**Solution:**

1. Make sure you're logged in before making API requests
2. Check that the token is being stored correctly after login
3. Verify the token is included in your request headers:
   ```
   Authorization: Bearer your_token_here
   ```
4. Check if your token has expired (default expiration is 1 hour)

### Testing Authentication

Run the test script to verify your authentication flow:

```
python backend/test_auth.py
```

Or use the web test page:

```
http://localhost:5000/test
```

## OpenAI API Issues

### Basic Dream Analysis Instead of AI Analysis

If you're getting basic dream analysis instead of AI-powered analysis, it means the OpenAI API call is failing.

**Solution:**

1. Run the environment check script:
   ```
   python backend/check_env.py
   ```

2. Check that your `.env` file exists in the backend directory with:
   ```
   OPENAI_API_KEY=your_actual_api_key_here
   ```

3. Make sure your OpenAI API key is valid and has sufficient credits

4. Update your OpenAI package to the correct version:
   ```
   pip install openai==1.14.3
   ```

5. Restart your Flask server after making changes

### Testing OpenAI API

Test your OpenAI API key directly:

```
python backend/test_openai.py
```

## Server Connection Issues

### Flutter App Can't Connect to Backend

If your Flutter app can't connect to the backend server:

**Solution:**

1. Make sure the Flask server is running on port 5000:
   ```
   python backend/start_server.py
   ```

2. Check that the baseUrl in your Flutter app is correct:
   - For web: `http://localhost:5000`
   - For Android emulator: `http://10.0.2.2:5000`

3. Verify CORS is properly configured in the backend:
   ```python
   CORS(app, origins=['http://localhost:3000', 'http://localhost:3001', 'http://127.0.0.1:3000', 'http://127.0.0.1:3001'], 
        supports_credentials=True)
   ```

## Database Issues

If you're having database-related issues:

**Solution:**

1. Check that your database file exists:
   - Development: `backend/dreams_dev.db`
   - Production: Check your DATABASE_URL environment variable

2. Try recreating the database:
   ```
   flask db upgrade
   ```

## Common Flutter Errors

### setState() Called After Dispose

If you see errors about calling setState() after dispose:

**Solution:**

Add mounted checks before setState calls:

```dart
if (mounted) {
  setState(() {
    // Your state updates here
  });
}
```

### Network Connection Issues

If you see network connection errors:

**Solution:**

1. Check that your backend server is running
2. Verify the correct URL is being used
3. Add proper error handling to your network requests:

```dart
try {
  final response = await http.get(url);
  // Handle response
} catch (e) {
  // Handle error
  print('Network error: $e');
}
```

## Need More Help?

If you're still experiencing issues:

1. Check the server logs for more detailed error information
2. Use the browser developer tools to inspect network requests
3. Add more logging to your code to identify where the problem is occurring 