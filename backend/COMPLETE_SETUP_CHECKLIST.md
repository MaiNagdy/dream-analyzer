# 🚀 Complete Subscription System Setup Checklist

## 📋 **Your Generated Keys** (Keep these secure!)
```env
SECRET_KEY=c507ebf4b19a753fef5362eb16169efc31fff5d607c3f8abc06db19a6856fa73
JWT_SECRET_KEY=a0eb58803234413db9b5ec46dc4d42f9d82a65362ddb8f45792fad547df3f0fb
```

---

## ✅ **Step 1: Google Play Console Setup**

### 1.1 Create Subscription Products
1. Go to: https://play.google.com/console
2. Select your app
3. Navigate to: **Products → Subscriptions**
4. Create these products:

**Product 1: Basic Plan**
- Product ID: `pack_10_dreams`
- Name: `10 Dreams Monthly`
- Price: `$10.00 USD`
- Billing: Monthly

**Product 2: Premium Plan**
- Product ID: `pack_30_dreams`
- Name: `30 Dreams Monthly`
- Price: `$20.00 USD`
- Billing: Monthly

5. **Activate both products**

### 1.2 Set up Test Accounts
1. Go to: **Setup → License Testing**
2. Add test Gmail accounts
3. These accounts can test purchases without being charged

---

## ✅ **Step 2: Google Play API Service Account**

### 2.1 Create Service Account
1. Go to: https://console.cloud.google.com
2. Create/select project
3. Enable **Google Play Developer API**
4. Create service account:
   - Name: `dream-app-subscription-service`
   - Download JSON key file

### 2.2 Grant Permissions
1. Go to Play Console → **Users and Permissions**
2. Invite service account email
3. Grant permissions:
   - ✅ View app information
   - ✅ View financial data
   - ✅ Manage orders and subscriptions

### 2.3 Save Service Account Key
1. Save JSON file as `service-account-key.json` in backend directory
2. **Never commit this file to git!**

---

## ✅ **Step 3: Railway Deployment**

### 3.1 Create Railway Project
1. Go to: https://railway.app
2. Sign up with GitHub
3. Create new project from GitHub repo
4. Select `backend` as root directory

### 3.2 Add PostgreSQL Database
1. In Railway project: **New → Database → PostgreSQL**
2. Railway auto-generates `DATABASE_URL`

### 3.3 Configure Environment Variables
Add these to Railway Variables:

```env
FLASK_ENV=production
SECRET_KEY=c507ebf4b19a753fef5362eb16169efc31fff5d607c3f8abc06db19a6856fa73
JWT_SECRET_KEY=a0eb58803234413db9b5ec46dc4d42f9d82a65362ddb8f45792fad547df3f0fb
OPENAI_API_KEY=your-openai-api-key-here
GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json
GOOGLE_PLAY_DEVELOPER_EMAIL=your-email@gmail.com
ALLOWED_ORIGINS=*
CORS_ORIGINS=*
```

**Replace these values:**
- `your-openai-api-key-here` → Your actual OpenAI API key
- `your-email@gmail.com` → Your Google Play Console email

### 3.4 Deploy
1. Commit and push your code:
   ```bash
   git add .
   git commit -m "Add subscription system"
   git push origin main
   ```
2. Railway will automatically deploy
3. Monitor deployment in Railway dashboard

### 3.5 Run Database Migrations
After deployment:
1. Go to Railway project → Service → Terminal
2. Run: `flask db upgrade`

---

## ✅ **Step 4: Update Flutter App**

### 4.1 Update App Configuration
Edit `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String baseUrl = 'https://your-railway-app.railway.app';
  
  // Subscription product IDs
  static const String basicSubscriptionId = 'pack_10_dreams';
  static const String premiumSubscriptionId = 'pack_30_dreams';
  
  // Subscription limits
  static const int basicDreamLimit = 10;
  static const int premiumDreamLimit = 30;
}
```

**Replace `your-railway-app.railway.app` with your actual Railway URL**

### 4.2 Test Flutter App
1. Build and run on test device
2. Test subscription flow
3. Verify backend integration

---

## ✅ **Step 5: Testing**

### 5.1 Test Backend Endpoints
```bash
# Test health endpoint
curl https://your-railway-app.railway.app/api/health

# Test subscription status (requires auth)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-railway-app.railway.app/api/subscriptions/status
```

### 5.2 Test Purchase Flow
1. Install app on test device
2. Sign in with test account
3. Attempt subscription purchase
4. Verify purchase verification in backend logs

---

## ✅ **Step 6: Production Deployment**

### 6.1 Final Checks
- [ ] All environment variables set in Railway
- [ ] Service account permissions granted
- [ ] Database migrations completed
- [ ] Flutter app updated with Railway URL
- [ ] Test accounts can purchase subscriptions
- [ ] Backend logs show successful verification

### 6.2 Go Live
1. Submit app for review in Google Play Console
2. Activate subscription products
3. Monitor user purchases and backend logs

---

## 🆘 **Troubleshooting**

### Common Issues:
1. **"Service account not found"** → Check permissions in Play Console
2. **"Invalid purchase token"** → Verify product IDs match
3. **"Database connection failed"** → Check DATABASE_URL in Railway
4. **"CORS errors"** → Verify CORS_ORIGINS environment variable

### Debug Commands:
```bash
# Check Railway logs
railway logs

# Test database connection
railway run python -c "from models import db; print('DB OK')"

# Test Google Play API
railway run python setup_google_service_account.py
```

---

## 📞 **Need Help?**

If you encounter issues:
1. Check Railway deployment logs
2. Check Flutter app logs
3. Verify Google Play Console setup
4. Test with different accounts

**Your subscription system is ready! 🎉** 