# Backend Deployment Guide

Your APK needs a globally accessible backend to work properly. Here are several free options to deploy your Flask backend:

## Option 1: Railway (Recommended - Free)

1. **Sign up for Railway**: Go to [railway.app](https://railway.app) and sign up with GitHub
2. **Deploy from GitHub**:
   - Connect your GitHub repository
   - Railway will auto-detect the Python app
   - It will use the `railway.json` configuration I created

3. **Set Environment Variables** in Railway dashboard:
   ```
   FLASK_ENV=production
   SECRET_KEY=your-secret-key-here
   JWT_SECRET_KEY=your-jwt-secret-here
   OPENAI_API_KEY=your-openai-api-key
   DATABASE_URL=postgresql://... (Railway provides this automatically)
   ```

4. **Get your deployment URL**: Railway will give you a URL like `https://your-app-name.railway.app`

## Option 2: Render (Free)

1. **Sign up for Render**: Go to [render.com](https://render.com)
2. **Create a new Web Service**:
   - Connect your GitHub repository
   - Use the `render.yaml` configuration I created
   - Set the same environment variables as above

## Option 3: Heroku (Free tier discontinued but still available)

1. **Sign up for Heroku**: Go to [heroku.com](https://heroku.com)
2. **Install Heroku CLI** and deploy:
   ```bash
   heroku login
   heroku create your-app-name
   heroku addons:create heroku-postgresql:hobby-dev
   heroku config:set FLASK_ENV=production
   heroku config:set SECRET_KEY=your-secret-key
   heroku config:set JWT_SECRET_KEY=your-jwt-secret
   heroku config:set OPENAI_API_KEY=your-openai-key
   git push heroku main
   ```

## After Deployment

1. **Update Flutter App Configuration**:
   - Open `lib/config/app_config.dart`
   - Replace `'https://your-app-name.railway.app'` with your actual deployment URL
   - Make sure `useProductionBackend = true`

2. **Test the Backend**:
   - Visit `https://your-deployment-url.com/api/health`
   - You should see: `{"status": "healthy", "timestamp": "...", "version": "2.0.0"}`

3. **Rebuild Your APK**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## Environment Variables You Need

Make sure to set these in your cloud service dashboard:

```
FLASK_ENV=production
SECRET_KEY=generate-a-random-secret-key
JWT_SECRET_KEY=generate-another-random-secret-key
OPENAI_API_KEY=your-openai-api-key-from-openai-platform
DATABASE_URL=postgresql://... (usually auto-provided)
```

## Troubleshooting

### Backend Issues:
- Check the deployment logs in your cloud service dashboard
- Ensure all environment variables are set correctly
- Verify the database is connected properly

### Flutter App Issues:
- Make sure `app_config.dart` has the correct URL
- Ensure `useProductionBackend = true`
- Clear app data and try again
- Check network connectivity

### CORS Issues:
If you get CORS errors, the backend is already configured to handle them. If issues persist, you may need to add your domain to the CORS origins in `app.py`.

## Quick Test Commands

Test your deployed backend:
```bash
# Health check
curl https://your-deployment-url.com/api/health

# Test registration (replace with your URL)
curl -X POST https://your-deployment-url.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"testuser","password":"testpass123"}'
```

## Next Steps

1. Choose a deployment service (Railway recommended)
2. Deploy the backend and get the URL
3. Update `lib/config/app_config.dart` with your URL
4. Rebuild and test your APK

Your dream analysis app will then work on any device with internet connection! 