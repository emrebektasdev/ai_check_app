# Secure analysis deployment
The mobile app contains no Sightengine credentials. It calls the authenticated `analyzeImage` callable in `europe-west1`.

1. Revoke the formerly exposed Sightengine key. Removing source code does not revoke a key or erase Git history.
2. Set SIGHTENGINE_API_USER and SIGHTENGINE_API_SECRET using `firebase functions:secrets:set NAME --project ai-check-app-1ffa4`. Enter values only in the secret prompt. Never put them in Flutter, Git, screenshots, or chat.
3. Register the Android app with Play Integrity and the iOS app with App Attest in Firebase App Check. Debug builds use the debug provider; register debug tokens only for development. Never ship the debug provider in release builds. Unsupported desktop/web clients cannot analyze until their App Check provider is configured.
4. Copy `functions/.env.example` to `functions/.env.ai-check-app-1ffa4` (use your project ID for another project). This contains only the global daily limit; secret values stay in Secret Manager. Explicitly setting the limit also supports non-interactive Firebase deployments. Deploy Firestore rules and the callable: `firebase deploy --only firestore:rules,storage,functions:analyzeImage --project ai-check-app-1ffa4`.
5. Test Google sign-in and analysis on a registered device. Anonymous/unverified users and requests without App Check are rejected.
6. The server reserves a maximum of 5 analyses per user per UTC day and 100 globally per UTC day (DAILY_GLOBAL_SCAN_LIMIT). Failed upstream attempts also count, to cap abuse. Premium purchasing is disabled until verified store receipts and server entitlements exist.
7. Run `npm ci` and `npm test` in functions; run `flutter analyze` and targeted Flutter tests at the repository root.

Credentials and App Check registration are deployment prerequisites; source tests do not establish that a real device can use the live callable.
