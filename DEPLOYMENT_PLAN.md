# SupportCircle - Immediate Deployment Plan

## YOUR IMMEDIATE ACTION ITEMS

### Step 1: Revoke Exposed Keys (DO THIS FIRST!)
Since your API key was exposed, revoke it immediately:

1. **Google Maps API Key**:
   - Go to: https://console.cloud.google.com/google/maps-apis/credentials
   - Find and DELETE the exposed API key
   - Create a NEW Android Maps API key
   - Restrict it to package name: `com.supportcircle.app`

2. **Firebase API Key** (if exposed):
   - The Firebase key in `google-services.json` was committed to git
   - Consider creating a fresh Firebase project for production
   - Or rotate keys in Firebase Console settings

### Step 2: Configure Your Local Environment

1. **Add your NEW Google Maps API key**:
   ```bash
   # Edit android/local.properties
   # Add this line:
   GOOGLE_MAPS_API_KEY=your_new_android_key_here
   ```

2. **Restore google-services.json**:
   - Download fresh config from Firebase Console
   - Place at `android/app/google-services.json`
   - Verify package name is `com.supportcircle.app`

### Step 3: Build the Release APK

Once you've added the API key:
```bash
flutter build appbundle --release
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

### Step 4: Commit Security Changes

```bash
git add .gitignore SETUP.md SECURITY_CHECKLIST.md android/app/google-services.json.template android/local.properties.template
git add android/app/build.gradle.kts android/settings.gradle.kts android/app/src/main/AndroidManifest.xml
git add android/app/src/main/res/mipmap-*/ic_launcher.png
git commit -m "Security: Remove sensitive files from git and update app configuration

- Add google-services.json to gitignore
- Update package name to com.supportcircle.app
- Add setup documentation and templates
- Update app icons
- Configure release signing

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Step 5: For Your Student

**DO NOT share:**
- Your `google-services.json` file
- Your API keys
- Your keystore file (`upload-keystore.jks`)
- Your `key.properties` file

**DO share:**
- The git repository (after committing the security changes above)
- `SETUP.md` - comprehensive setup instructions
- Template files (`.template` files)

**Instruct your student to:**
1. Clone the repository
2. Follow `SETUP.md` to create their own:
   - Firebase project
   - Google Maps API keys
   - Configuration files

### Step 6: Google Play Store Submission (You Only)

1. **Create Google Play Developer Account**:
   - Cost: $25 one-time fee
   - Link: https://play.google.com/console/signup

2. **Create New App**:
   - Go to Play Console
   - Click "Create app"
   - Fill in app details

3. **Upload AAB**:
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Complete store listing (screenshots, description, etc.)

4. **Required Store Assets**:
   - App icon (already done ✓)
   - Screenshots (at least 2)
   - Feature graphic (1024x500)
   - Description
   - Privacy policy URL

5. **Submit for Review**

## Important Security Notes

### Keystore Password
- Password: `supportcircle2024`
- Alias: `upload`
- **CRITICAL**: Back up `android/app/upload-keystore.jks` securely
- **CRITICAL**: If you lose this keystore, you CANNOT update the app on Google Play

### Git History
- The old `google-services.json` with Firebase keys is in git history
- This is why you should revoke those keys
- For maximum security, you could create a new Firebase project

### For Future Development
- NEVER commit files listed in `.gitignore`
- Always use template files for configuration
- Rotate API keys regularly
- Use environment variables in CI/CD

## Troubleshooting

### Build fails with "No matching client found"
→ Make sure `google-services.json` exists with package name `com.supportcircle.app`

### Build fails with "GOOGLE_MAPS_API_KEY"
→ Make sure `android/local.properties` has the Maps API key

### Maps not showing in app
→ Verify API key is enabled for "Maps SDK for Android" in Google Cloud Console

## Next Steps After Google Play

1. Test the published app thoroughly
2. Monitor crash reports in Play Console
3. Set up Firebase Analytics
4. Configure Firestore security rules for production
5. Plan for iOS App Store submission (if needed)

---

**Current Keystore Info (SAVE THIS SECURELY)**:
- Location: `android/app/upload-keystore.jks`
- Password: `supportcircle2024`
- Alias: `upload`
- Key Password: `supportcircle2024`
