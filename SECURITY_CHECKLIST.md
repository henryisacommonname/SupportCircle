# Security Checklist for SupportCircle App

## Before Sharing Code or Deploying

### 1. API Keys & Credentials
- [ ] Revoke any exposed Google Maps API keys in Google Cloud Console
- [ ] Generate new Google Maps API keys (one for Android, one for iOS)
- [ ] Restrict API keys by package name (Android) and bundle ID (iOS)
- [ ] Verify `google-services.json` is NOT in git (should be in .gitignore)
- [ ] Verify `local.properties` is NOT in git (should be in .gitignore)
- [ ] Verify `key.properties` is NOT in git (should be in .gitignore)
- [ ] Verify `*.jks` files are NOT in git (should be in .gitignore)

### 2. Firebase Configuration
- [ ] Each developer/deployment should use their own Firebase project
- [ ] Download fresh `google-services.json` from Firebase Console
- [ ] Download fresh `GoogleService-Info.plist` from Firebase Console
- [ ] Update Firestore security rules for production

### 3. Git Repository Cleanup
- [ ] Ensure sensitive files are in `.gitignore`
- [ ] Run `git status` to verify no sensitive files are staged
- [ ] If keys were previously committed, revoke them immediately

### 4. Student/Developer Handoff
- [ ] Share template files (`.template` files)
- [ ] Share `SETUP.md` with instructions
- [ ] DO NOT share actual API keys or `google-services.json`
- [ ] Student should create their own Firebase project
- [ ] Student should generate their own API keys

### 5. Production Build
- [ ] Create release keystore (and back it up securely!)
- [ ] Store keystore password in a secure password manager
- [ ] Never commit keystore or passwords to git
- [ ] Use environment variables or secure CI/CD for production builds

## How to Revoke Exposed Keys

### Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis/credentials)
2. Find the exposed API key
3. Click "Delete" or "Restrict" to prevent unauthorized use
4. Create a new API key with proper restrictions

### Firebase Keys
1. If Firebase API key was exposed, create a new Firebase project
2. Migrate data if necessary
3. Update app with new `google-services.json`

### Keystore (if exposed)
1. If your app is already published, you CANNOT change the keystore
2. Contact Google Play support for guidance
3. For unreleased apps, generate a new keystore

## Regular Security Practices

- Never commit API keys, passwords, or certificates to git
- Use environment variables for secrets in CI/CD
- Regularly rotate API keys
- Monitor API usage in Google Cloud Console for anomalies
- Keep dependencies updated (`flutter pub outdated`)
- Review Firestore security rules regularly
