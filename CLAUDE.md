# SupportCircle

A Flutter mobile app for volunteer coordination, training, and community service discovery.

## Tech Stack

- **Framework**: Flutter 3.8+ / Dart
- **Backend**: Firebase (Auth, Firestore)
- **State Management**: Streams + StreamBuilder (RxDart for combining streams)
- **Maps**: Google Maps Flutter + Geolocator
- **Video**: youtube_player_iframe
- **Architecture**: Repository pattern with service layer

## Project Structure

```
lib/
├── main.dart              # App entry, Firebase init
├── app.dart               # MaterialApp with theme, routes, auth-gated AI chat
├── config/
│   ├── routes.dart        # Named route definitions
│   └── theme.dart         # AppTheme light/dark themes
├── models/                # Data classes with Firestore fromDoc factories
├── screens/               # UI organized by feature
│   ├── auth/              # Login, Register, AuthGate
│   ├── home/              # HomeShell (tabs), HomeTab
│   ├── training/          # TrainingScreen, ModulePlayer
│   ├── resources/         # ResourcesScreen, ResourcePlayer
│   ├── support/           # SupportScreen (maps)
│   └── profile/           # ProfileTab, ProfileEditingScreen
├── services/              # Business logic, API clients, repositories
└── widgets/               # Reusable components (YouTubePlayer, CollapsibleChat, OnboardingCarousel)
```

## Build Commands

```bash
flutter pub get                    # Install dependencies
flutter analyze                    # Static analysis
flutter run                        # Run debug build
flutter build ios --no-codesign    # Build iOS (no signing)
flutter build ios --release        # Release build (requires signing)
```

## Firestore Collections

| Collection | Purpose | Key Fields |
|------------|---------|------------|
| `users/{uid}` | User profiles | DisplayName, pfpURL, TimeTracker, hasSeenOnboarding |
| `users/{uid}/ModuleProgress/{moduleId}` | Training progress | status (notStarted/inProgress/completed) |
| `TrainingModules` | Training content | title, subtitle, youtubeURL, contentType, body |
| `Resources` | Resource items | title, subtitle, icon, youtubeURL, body |

## Key Patterns

- **Auth-gated features**: `lib/app.dart:33-42` wraps CollapsibleChat in auth StreamBuilder
- **Firestore models**: Use `fromDoc()` factories with null-safe field access (see `lib/models/training_module.dart:21-33`)
- **Repository streams**: Combine Firestore streams with RxDart `Rx.combineLatest2` (see `lib/services/training_repository.dart`)
- **Onboarding flow**: `lib/widgets/onboarding_carousel.dart` stores `hasSeenOnboarding` in user doc

## iOS Configuration

- Bundle ID: `com.supportcircle.app`
- Min iOS: 15.0
- Signing: Open `ios/Runner.xcworkspace` in Xcode, configure team in Signing & Capabilities

## Additional Documentation

- [Architectural Patterns](.claude/docs/architectural_patterns.md) - Design decisions, state management, repository pattern details
