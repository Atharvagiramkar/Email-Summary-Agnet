# Email Summary Agent

Flutter app for user authentication, preference-driven email summarization, summary history, and profile management.

## Features

- Splash screen with auth check
- Login and registration with email/password
- Google sign-in
- Preference setup for:
  - Summary Type: Daily / Weekly
  - Email Filter: All / Unread / Starred
  - Number of Emails per batch
  - Summary Style: Formal / Casual / Bullet Points
  - Delivery Method: In App / In Inbox
- Home screen with user card and last summarized time
- AI summary generation button
- Summary list page with read/unread tags
- Summary detail page with "Mark it Read"
- History page with date search
- Profile page with editable name, visible preferences, edit preferences, and logout
- Bottom navigation for Home, Summary, History, and Profile

## Backend behavior

- When Firebase is configured, the app uses Firebase Auth + Firestore.
- If Firebase initialization fails, the app falls back to a local demo mode so UI flow still works.
- If `GEMINI_API_KEY` is provided, summaries are generated with Gemini (`gemini-2.5-pro`).
- If Gemini is not configured or generation fails, the app uses a deterministic local summary fallback.

## Setup

1. Install dependencies:

	flutter pub get

2. Configure Firebase for your platforms and ensure `google-services.json` / platform-specific setup is in place.

3. Create a local `.env` file in project root and configure required values:

  GEMINI_API_KEY=your_gemini_api_key
  FIREBASE_API_KEY=your_firebase_api_key
  FIREBASE_AUTH_DOMAIN=your_auth_domain
  FIREBASE_PROJECT_ID=your_project_id
  FIREBASE_STORAGE_BUCKET=your_storage_bucket
  FIREBASE_MESSAGING_SENDER_ID=your_sender_id
  FIREBASE_APP_ID=your_app_id
  FIREBASE_MEASUREMENT_ID=your_measurement_id
  GOOGLE_CLOUD_PROJECT_ID=your_google_cloud_project_id
  GOOGLE_OAUTH_WEB_CLIENT_ID=your_google_oauth_web_client_id
  GOOGLE_OAUTH_ANDROID_CLIENT_ID=your_google_oauth_android_client_id
  GOOGLE_OAUTH_IOS_CLIENT_ID=your_google_oauth_ios_client_id

4. (Optional) You can still pass Gemini key via dart define:

	flutter run --dart-define=GEMINI_API_KEY=your_api_key_here

## Run tests

flutter test
