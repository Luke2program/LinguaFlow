# Resend Setup Guide for QuestFlow

## Step 1: Create Account
1. Go to **https://resend.com**
2. Click "Sign up"
3. Use your email: **lukas.koprolin@gmail.com**
4. Set a password

## Step 2: Add Domain
1. After login → Click "Domains" → "Add Domain"
2. Enter: **lukaskoprolin.com**
3. Click "Add"

## Step 3: DNS Records
Add these records at your domain provider (World4You):

### TXT Records:
```
Type: TXT
Name: _dmarc.lukaskoprolin.com
Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@resend.dev

Type: TXT
Name: lukaskoprolin.com
Value: v=spf1 include:_spf.resend.com ~all

Type: TXT
Name: resend._domainkey.lukaskoprolin.com
Value: [Resend will give you this DKIM key]
```

## Step 4: Get API Key
1. Go to "API Keys" → "Create API Key"
2. Name: "QuestFlow App"
3. Copy the key (starts with `re_`)

## Step 5: Add to App
Add this to your app (e.g., in AppStore init or Settings):

```swift
UserDefaults.standard.set("re_YOUR_KEY_HERE", forKey: "resend_api_key")
```

## Step 6: Test
Build the app and test:
1. Sign up with email
2. Check if welcome email arrives
3. Test password reset

## Done! 🎉

**Sender Email:** linguaflow@lukaskoprolin.com
**DNS Provider:** World4You (where you manage lukaskoprolin.com)
