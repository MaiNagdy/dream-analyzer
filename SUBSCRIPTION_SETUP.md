# Complete Subscription Setup Guide

## 1. Railway PostgreSQL Setup

### Step 1: Add PostgreSQL to Railway
1. Go to your Railway project dashboard
2. Click "New" → "PostgreSQL" 
3. Railway automatically creates `DATABASE_URL` environment variable

### Step 2: Configure Environment Variables
In your Railway backend service, add these variables:

```env
FLASK_ENV=production
SECRET_KEY=your-random-secret-key-here
JWT_SECRET_KEY=your-random-jwt-secret-here
OPENAI_API_KEY=your-openai-api-key

# Google Play Subscription Verification
GOOGLE_SERVICE_ACCOUNT_JSON_BASE64=your-base64-service-account-json
ANDROID_PACKAGE_NAME=com.example.dream_app
```

### Step 3: Database Migration
After deploying your code to Railway:
1. Go to Railway backend service → "Logs" → "Launch Console"
2. Run: `flask db upgrade`

## 2. Google Play Console Setup

### Step 1: Create Subscription Products
1. **Google Play Console** → Your App → "Monetization" → "Subscriptions"
2. Create two subscription products:
   - **Product ID**: `pack_10_dreams`
     - **Name**: "10 Dreams Monthly"
     - **Price**: $10.00/month
     - **Description**: "Analyze 10 dreams per month with AI"
   
   - **Product ID**: `pack_30_dreams`
     - **Name**: "30 Dreams Monthly" 
     - **Price**: $20.00/month
     - **Description**: "Analyze 30 dreams per month with AI"

### Step 2: Google Cloud Service Account
1. **Google Cloud Console** → "Service Accounts"
2. Create new service account for your app
3. Download JSON key file
4. Base64 encode it: `base64 -w0 service-account.json` (Linux/Mac) or `certutil -encode service-account.json encoded.txt` (Windows)
5. Copy the base64 string to `GOOGLE_SERVICE_ACCOUNT_JSON_BASE64`

### Step 3: API Access
1. **Play Console** → "Settings" → "API access"
2. Link your service account
3. Grant permissions:
   - "View financial data"
   - "Manage orders and subscriptions"

### Step 4: Testing Setup
1. Add test accounts in Play Console → "Settings" → "Account details" → "License Testing"
2. Upload your AAB to Internal Testing track
3. Share internal testing link with test accounts

## 3. Flutter App Configuration

### Update App Config
```dart
// lib/config/app_config.dart
const String productionBaseUrl = 'https://your-railway-url.railway.app';
bool useProductionBackend = true;
```

### Subscription Products
The app is configured with these product IDs:
- `pack_10_dreams` - $10/month for 10 dreams
- `pack_30_dreams` - $20/month for 30 dreams

## 4. Database Schema

### User Table (Enhanced)
```sql
- subscription_status: 'none', 'active', 'expired', 'cancelled'
- subscription_type: 'pack_10_dreams', 'pack_30_dreams'
- subscription_start_date: DateTime
- subscription_end_date: DateTime
- subscription_auto_renew: Boolean
- credits: Integer (for non-subscribers)
```

### Purchase Table (New)
```sql
- purchase_token: Unique Google Play purchase token
- product_id: Subscription product ID
- purchase_state: 0=purchased, 1=cancelled
- subscription_period_start/end: DateTime
- auto_renewing: Boolean
- credits_granted: Integer
```

## 5. API Endpoints

### Subscription Verification
- `POST /api/subscriptions/verify`
- Verifies Google Play purchase token
- Updates user subscription status
- Grants credits based on subscription type

### Subscription Status
- `GET /api/subscriptions/status`
- Returns current user's subscription details

### Cancel Subscription
- `POST /api/subscriptions/cancel`
- Disables auto-renewal (cancellation handled by Google Play)

## 6. Testing Flow

### Local Testing
1. Use Railway's PostgreSQL URL for local development
2. Set environment variables in your IDE
3. Test with Google Play's test purchase tokens

### Production Testing
1. Deploy to Railway
2. Upload AAB to Google Play Internal Testing
3. Test with real Google Play accounts
4. Verify subscription verification works end-to-end

## 7. Security Considerations

### Environment Variables
- Never commit API keys to Git
- Use Railway's environment variables for secrets
- Rotate keys regularly

### Purchase Verification
- Always verify purchase tokens server-side
- Store purchase tokens to prevent replay attacks
- Handle subscription renewals and cancellations

### Database Security
- Use PostgreSQL for production (never SQLite)
- Enable Railway's automatic backups
- Monitor for unusual subscription activity

## 8. Monitoring & Analytics

### Key Metrics to Track
- Subscription conversion rates
- Monthly recurring revenue (MRR)
- Churn rate
- Dream analysis usage per subscriber

### Logging
- Log all subscription verifications
- Monitor failed purchase attempts
- Track subscription lifecycle events

## 9. Deployment Checklist

### Before Going Live
- [ ] PostgreSQL database configured in Railway
- [ ] All environment variables set
- [ ] Database migrations applied
- [ ] Google Play Console products created
- [ ] Service account configured with proper permissions
- [ ] Internal testing completed
- [ ] Purchase verification tested
- [ ] Subscription renewal tested
- [ ] Cancellation flow tested

### Launch Day
- [ ] Deploy to Railway
- [ ] Upload AAB to Google Play production
- [ ] Monitor subscription verifications
- [ ] Check error logs
- [ ] Verify user subscription status updates

## 10. Troubleshooting

### Common Issues
1. **Purchase verification fails**: Check service account permissions
2. **Database connection errors**: Verify PostgreSQL URL
3. **Migration failures**: Check column constraints and defaults
4. **Subscription not recognized**: Verify product IDs match exactly

### Debug Commands
```bash
# Check Railway logs
railway logs

# Test subscription endpoint
curl -X POST https://your-app.railway.app/api/subscriptions/verify \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productId":"pack_10_dreams","purchaseToken":"TEST_TOKEN"}'
```

This setup provides a robust, scalable subscription system ready for production use with Google Play Store. 