# SupportCircle App Setup Guide

This guide will help you configure the SupportCircle app for development and deployment.

## Prerequisites

- Flutter SDK installed
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- Firebase account
- Google Cloud account (for Maps API)

## Security Note

**NEVER commit the following files to git:**
- `android/app/google-services.json`
- `android/local.properties`
- `android/key.properties`
- `android/app/*.jks`
- `ios/GoogleService-Info.plist`

These files are already in `.gitignore`.

## Step 1: Firebase Setup

### Android
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Add an Android app with package name: `com.supportcircle.app`
4. Download the `google-services.json` file
5. Place it in `android/app/google-services.json`

### iOS
1. In the same Firebase project, add an iOS app with bundle ID: `com.supportcircle.app`
2. Download the `GoogleService-Info.plist` file
3. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 2: Google Maps API Key Setup

### Get API Keys
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android" and "Maps SDK for iOS"
3. Create credentials:
   - **Android**: API key with Android app restriction (package name: `com.supportcircle.app`)
   - **iOS**: API key with iOS app restriction (bundle ID: `com.supportcircle.app`)

### Android Configuration
1. Copy `android/local.properties.template` to `android/local.properties`
2. Add your Android Maps API key:
   ```
   GOOGLE_MAPS_API_KEY=YOUR_ANDROID_KEY_HERE
   ```

### iOS Configuration
The iOS Maps API key should be added to your Firebase `GoogleService-Info.plist` or configured separately.

## Step 3: Android Release Signing (For Google Play Store)

### Option A: Use Existing Keystore
If you already have a keystore from this project:
1. Ensure you have the `upload-keystore.jks` file in `android/app/`
2. Create `android/key.properties`:
   ```
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### Option B: Create New Keystore
Run this command from the project root:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties` as shown in Option A.

**IMPORTANT**: Save your keystore password securely. If you lose it, you cannot update your app on Google Play Store.

## Step 4: Build the App

### Android (Release)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Release)
```bash
flutter build ios --release
```

## Step 5: Deploy to Stores

### Google Play Store
1. Create a Google Play Developer account ($25 one-time fee)
2. Create a new app in Play Console
3. Upload the AAB file: `build/app/outputs/bundle/release/app-release.aab`
4. Fill in store listing details
5. Submit for review

### Apple App Store
1. Enroll in Apple Developer Program ($99/year)
2. Open `ios/Runner.xcworkspace` in Xcode
3. Configure signing with your team
4. Archive and upload to App Store Connect
5. Fill in app information and submit for review

## Troubleshooting

### "No matching client found" error
- Ensure package name in `google-services.json` matches `com.supportcircle.app`
- Re-download the config file from Firebase Console

### Maps not showing
- Verify API keys are correctly configured
- Check that Maps SDK is enabled in Google Cloud Console
- Ensure API key restrictions match your package/bundle ID

### Build fails with signing error
- Verify `key.properties` exists and has correct values
- Check that `upload-keystore.jks` is in the correct location

## Support

For issues, please check:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
