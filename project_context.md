# PROJECT_CONTEXT.md

Project: TruthLens / ai_check_app

Current stack:
- Flutter (SDK ^3.10.7)
- Riverpod 3.x (Notifier / AsyncNotifier)
- GoRouter
- Dio
- Hive & SharedPreferences
- Firebase (Core, Auth, Firestore, Storage)
- Google Mobile Ads

Current app flow:
- onboarding -> home -> scan -> result -> history -> settings -> paywall

Important rules:
- preserve Riverpod 3.x Notifier syntax
- preserve GoRouter
- preserve Hive history compatibility (Primary local storage)
- do not break onboarding -> home -> scan -> result -> history flow
- keep changes small and consistent with the existing structure
- **Firebase is ACTIVE**: Implementation for Auth, Firestore, and Storage is completed.

Current implementation notes:
- **Firebase Auth**: Uses `google_sign_in` 7.x. Requires explicit `initialize(serverClientId: ...)` on Android. Integrated into Settings page.
- **Firebase Sync**: `FirebaseDatabaseService` (Firestore) and `FirebaseStorageService` (Storage) are used for cloud backup/sync of scan data.
- **Hybrid Storage**: `ScanHistoryItem` includes `toMap`/`fromMap` for Firestore. Hive is the local cache.
- **SightEngine Integration**: Uses the `genai` model. Response parsing uses `response['type']['ai_generated']` for scores.
- **Image Quality**: `image_picker` uses `imageQuality: 100` to preserve pixel fingerprints.
- **Sharing**: Uses `share_plus` 12.x `SharePlus.instance.share(ShareParams(...))` API.
- **Android Build**: `minSdkVersion 23`, `multiDexEnabled = true`, `google-services 4.4.2`, and `gradle-8.14-all`.

Recently Fixed Issues:
- **Google Sign-In Fix**: Resolved `clientConfigurationError` by providing `serverClientId` in `FirebaseAuthService.initialize`.
- **Dependency Migration**: Updated project to support Riverpod 3.0, Google Sign-In 7.0, and SharePlus 12.0 breaking changes.
- **Android Build Fix**: Resolved `flutter run` failures by optimizing `local.properties` and Gradle scripts for Firebase compatibility.
- **Zero Score Fix**: Corrected nested response parsing path and disabled lossy image compression.
- **UI Tweaks**: The result wheel now always displays "AI" as the label. Heatmap removed.
- **Setup Guide**: Created `FIREBASE_SETUP.md` (Turkish) for manual Firebase Console configuration.

Focus:
- preserve working behavior
- improve only the relevant area
- prefer practical fixes over heavy architecture
- Avoid using `api_service.dart` or `sight_engine_repository.dart` (deprecated/orphaned).