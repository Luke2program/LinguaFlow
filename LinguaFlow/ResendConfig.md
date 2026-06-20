# Resend Email Setup for QuestFlow

## 1. Create Account
- Go to https://resend.com
- Sign up with your email

## 2. Add Domain
- Add domain: `lukaskoprolin.com` (or subdomain like `linguaflow.lukaskoprolin.com`)
- Verify domain with DNS records (Resend provides TXT + SPF + DKIM records)
- DNS setup at your domain registrar

## 3. Get API Key
- Go to API Keys → Create API Key
- Copy the key

## 4. Configure in App
Add API key to UserDefaults or Keychain:
```swift
UserDefaults.standard.set("your-resend-api-key", forKey: "resend_api_key")
```

Or store securely in Keychain (recommended for production).

## 5. Sender Email
Default: `QuestFlow <linguaflow@lukaskoprolin.com>`

## DNS Records Needed (Resend provides these):
Type | Name | Value
-----|------|------
TXT | _dmarc | v=DMARC1; p=quarantine; rua=mailto:dmarc@resend.dev
TXT | @ | v=spf1 include:mailgun.org include:amazonses.com include:_spf.resend.com ~all
TXT | resend._domainkey | (DKIM key from Resend)

## Email Templates Available:
- ✅ Password Reset
- ✅ Welcome Email
- ✅ Study Reminder

## URLs to Configure:
- Password Reset Page: `https://lukaskoprolin.com/linguaflow/reset`
- Privacy Policy: `https://lukaskoprolin.com/linguaflow-privacy`
- EULA: `https://lukaskoprolin.com/linguaflow-eula`
