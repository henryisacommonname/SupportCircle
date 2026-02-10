# SupportCircle

A Flutter mobile app for volunteer coordination, training, and community service discovery.

## Setup Instructions

### Google Maps API Keys

Add your Maps API keys (not committed to git for security):
- **iOS**: `ios/Runner/MapsKeys.xcconfig` - Set `GOOGLE_MAPS_API_KEY`
- **Android**: `android/local.properties` - Set `GOOGLE_MAPS_API_KEY`

Both keys need bundle ID `com.supportcircle.app` restrictions.

### Firebase Configuration

Firebase config files are NOT committed to git:
- `ios/GoogleService-Info.plist`
- `android/app/google-services.json`

### Build & Run

```bash
flutter pub get
flutter run                    # Debug mode
flutter run --release         # Release mode
flutter build ios --release   # Build iOS
flutter build apk --release   # Build Android APK
flutter build appbundle       # Build Android App Bundle
```

## Tech Stack

- **Framework**: Flutter 3.8+
- **Backend**: Firebase (Auth, Firestore)
- **Maps**: Google Maps Flutter
- **Video**: YouTube Player
- **Architecture**: Repository pattern with service layer
