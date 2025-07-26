# 🚀 Complete Subscription System Setup Checklist

## 📋 **Your Generated Keys** (Keep these secure!)
```env
SECRET_KEY=c507ebf4b19a753fef5362eb16169efc31fff5d607c3f8abc06db19a6856fa73
JWT_SECRET_KEY=a0eb58803234413db9b5ec46dc4d42f9d82a65362ddb8f45792fad547df3f0fb
```

---

## ✅ **Step 0: Google Play Developer Account Setup**

### 0.1 Create Google Play Developer Account
1. **Go to Google Play Console**: https://play.google.com/console
2. **Sign in** with your Google account
3. **Accept Terms of Service**
4. **Pay the one-time registration fee**: $25 USD (one-time payment)
5. **Complete account setup**:
   - Fill in developer name (this will be visible to users)
   - Add contact email
   - Complete payment information
   - Verify your identity if required

### 0.2 Account Verification (if required)
- Google may require identity verification
- Follow the verification process (usually takes 1-2 business days)
- You'll receive email confirmation when approved

### 0.3 Create Your First App
1. In Play Console, click **"Create app"**
2. **App name**: "Dream Analysis" (or your preferred name)
3. **Default language**: English
4. **App or game**: App
5. **Free or paid**: Free (with in-app purchases)
6. Click **"Create"**

---

## ✅ **Step 1: Google Play Console Setup**

### 1.1 Create Subscription Products
1. In your app dashboard, navigate to: **Monetize → Products → Subscriptions**
2. Click **"Create subscription"**

**Product 1: Basic Plan**
- **Product ID**: `pack_10_dreams`
- **Name**: `10 Dreams Monthly`
- **Description**: `Get 10 dream analyses per month`
- **Price**: `$10.00 USD`
- **Billing period**: Monthly
- **Free trial**: None (or add if desired)
- **Grace period**: 3 days
- Click **"Save"**

**Product 2: Premium Plan**
- **Product ID**: `pack_30_dreams`
- **Name**: `30 Dreams Monthly`
- **Description**: `Get 30 dream analyses per month`
- **Price**: `$20.00 USD`
- **Billing period**: Monthly
- **Free trial**: None (or add if desired)
- **Grace period**: 3 days
- Click **"Save"**

### 1.2 Activate Products
1. For each subscription, click **"Activate"**
2. Products must be active before testing

### 1.3 Set up Test Accounts
1. Go to: **Setup → License Testing**
2. Click **"Add test account"**
3. Add your Gmail address and any other test emails
4. These accounts can test purchases without being charged
5. **Important**: Test accounts must be added before testing

### 1.4 Upload App Bundle (Required for Testing)
1. Go to: **Release → Production**
2. Click **"Create new release"**
3. **Upload your app bundle** (we'll build this later)
4. **Release notes**: "Initial release with subscription features"
5. **Save** (don't publish to production yet)

---

## ✅ **Step 2: Google Play API Service Account**

### 2.1 Create Google Cloud Project
1. Go to: https://console.cloud.google.com
2. Click **"Select a project"** → **"New Project"**
3. **Project name**: `dream-analysis-app`
4. Click **"Create"**

### 2.2 Enable Google Play Developer API
1. In your project, go to: **APIs & Services → Library**
2. Search for **"Google Play Developer API"**
3. Click on it and click **"Enable"**

### 2.3 Create Service Account
1. Go to: **APIs & Services → Credentials**
2. Click **"Create Credentials"** → **"Service Account"**
3. **Service account name**: `dream-app-subscription-service`
4. **Description**: `Service account for dream analysis app subscriptions`
5. Click **"Create and Continue"**
6. **Role**: Select **"Project"** → **"Editor"**
7. Click **"Continue"** → **"Done"**

### 2.4 Generate Service Account Key
1. Click on your service account name
2. Go to **"Keys"** tab
3. Click **"Add Key"** → **"Create new key"**
4. **Key type**: JSON
5. Click **"Create"**
6. **Download the JSON file** (this is your service account key)

### 2.5 Grant Play Console Permissions
1. Go back to Play Console → **Users and Permissions**
2. Click **"Invite new users"**
3. **Email address**: Use the service account email (found in the JSON file)
4. **Permissions**:
   - ✅ **View app information**
   - ✅ **View financial data**
   - ✅ **Manage orders and subscriptions**
5. Click **"Invite user"**

### 2.6 Save Service Account Key
1. Rename the downloaded JSON file to `service-account-key.json`
2. Save it in your `backend` directory
3. **⚠️ CRITICAL**: Add this file to `.gitignore` to keep it secure
4. **Never commit this file to git!**

---

## ✅ **Step 3: Railway Deployment**

### 3.1 Create Railway Account
1. Go to: https://railway.app
2. Click **"Start a New Project"**
3. **Sign up with GitHub** (recommended)
4. Authorize Railway to access your GitHub repositories

### 3.2 Create Railway Project
1. Click **"Deploy from GitHub repo"**
2. Select your repository
3. **Root Directory**: `backend`
4. Click **"Deploy"**

### 3.3 Add PostgreSQL Database
1. In your Railway project, click **"New"**
2. Select **"Database"** → **"PostgreSQL"**
3. Railway will automatically create a PostgreSQL database
4. The `DATABASE_URL` environment variable will be auto-generated

### 3.4 Configure Environment Variables
In your Railway project, go to **"Variables"** and add:

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

### 3.5 Upload Service Account Key
1. In Railway project, go to **"Files"**
2. Upload your `service-account-key.json` file
3. This will be available at `/app/service-account-key.json`

### 3.6 Deploy
1. Commit and push your code:
   ```bash
   git add .
   git commit -m "Add subscription system"
   git push origin main
   ```
2. Railway will automatically deploy
3. Monitor deployment in Railway dashboard

### 3.7 Run Database Migrations
After deployment:
1. Go to Railway project → Your service → **"Deployments"**
2. Click on the latest deployment → **"View Logs"**
3. Look for migration logs or run manually:
   ```bash
   railway run python run_migrations.py
   ```

---

## ✅ **Step 4: Build and Upload App Bundle**

### 4.1 Build App Bundle
1. In your Flutter project root, run:
   ```bash
   flutter build appbundle --release
   ```
2. This creates: `build/app/outputs/bundle/release/app-release.aab`

### 4.2 Upload to Play Console
1. Go to Play Console → **Release → Production**
2. Click **"Create new release"**
3. **Upload** your `app-release.aab` file
4. **Release notes**: "Initial release with subscription features"
5. **Save** (don't publish to production yet)

### 4.3 Create Internal Testing Track
1. Go to **Release → Testing → Internal testing**
2. Click **"Create new release"**
3. Upload the same app bundle
4. **Add testers**: Add your email and any test accounts
5. **Save and review release**

---

## ✅ **Step 5: Update Flutter App**

### 5.1 Update App Configuration
Edit `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String baseUrl = 'https://your-railway-app.railway.app';
  
  // Subscription product IDs (must match Play Console exactly)
  static const String basicSubscriptionId = 'pack_10_dreams';
  static const String premiumSubscriptionId = 'pack_30_dreams';
  
  // Subscription limits
  static const int basicDreamLimit = 10;
  static const int premiumDreamLimit = 30;
}
```

**Replace `your-railway-app.railway.app` with your actual Railway URL**

### 5.2 Test Flutter App
1. Build and run on test device:
   ```bash
   flutter run --release
   ```
2. Test subscription flow
3. Verify backend integration

---

## ✅ **Step 6: Testing**

### 6.1 Test Backend Endpoints
```bash
# Test health endpoint
curl https://your-railway-app.railway.app/api/health

# Test subscription status (requires auth)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-railway-app.railway.app/api/subscriptions/status
```

### 6.2 Test Purchase Flow
1. Install app on test device (using internal testing track)
2. Sign in with test account
3. Attempt subscription purchase
4. Verify purchase verification in backend logs

### 6.3 Test with Emulator
1. Start your emulator:
   ```bash
   C:\Users\maiel\AppData\Local\Android\sdk\emulator\emulator.exe -avd Small_Phone
   ```
2. Run your app:
   ```bash
   flutter run -d emulator-5556
   ```

---

## ✅ **Step 7: Production Deployment**

### 7.1 Final Checks
- [ ] All environment variables set in Railway
- [ ] Service account permissions granted
- [ ] Database migrations completed
- [ ] Flutter app updated with Railway URL
- [ ] App bundle uploaded to Play Console
- [ ] Test accounts can purchase subscriptions
- [ ] Backend logs show successful verification

### 7.2 Go Live
1. In Play Console → **Release → Production**
2. Click **"Review release"**
3. **Review all information**
4. Click **"Start rollout to Production"**
5. **Rollout percentage**: 100%
6. Click **"Confirm"**

### 7.3 Monitor
1. Monitor user purchases in Play Console
2. Check backend logs for verification
3. Monitor app performance and crashes

---

## 🆘 **Troubleshooting**

### Common Issues:

1. **"Service account not found"**
   - Check permissions in Play Console
   - Verify service account email is invited

2. **"Invalid purchase token"**
   - Verify product IDs match exactly
   - Check if products are activated

3. **"Database connection failed"**
   - Check DATABASE_URL in Railway
   - Verify PostgreSQL is running

4. **"CORS errors"**
   - Verify CORS_ORIGINS environment variable
   - Check if Railway URL is correct

5. **"App not found in Play Console"**
   - Make sure app bundle is uploaded
   - Check if you're in the correct account

### Debug Commands:
```bash
# Check Railway logs
railway logs

# Test database connection
railway run python -c "from models import db; print('DB OK')"

# Test Google Play API
railway run python setup_google_service_account.py

# Check emulator status
adb devices

# Run Flutter app on emulator
flutter run -d emulator-5556
```

---

## 💰 **Costs Summary**

- **Google Play Developer Account**: $25 USD (one-time)
- **Railway**: Free tier available (limited usage)
- **OpenAI API**: Pay per use (very low cost for testing)
- **Google Cloud**: Free tier available

---

## 📞 **Need Help?**

If you encounter issues:
1. Check Railway deployment logs
2. Check Flutter app logs
3. Verify Google Play Console setup
4. Test with different accounts
5. Check Play Console documentation

**Your subscription system is ready! 🎉**

---

## 🔄 **Quick Commands Reference**

```bash
# Start emulator
C:\Users\maiel\AppData\Local\Android\sdk\emulator\emulator.exe -avd Small_Phone

# Check devices
adb devices

# Run Flutter app
flutter run -d emulator-5556

# Build app bundle
flutter build appbundle --release

# Check Railway logs
railway logs
``` 