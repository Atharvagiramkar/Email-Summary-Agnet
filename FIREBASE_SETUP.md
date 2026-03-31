# Firebase & Google Cloud Setup Guide

This guide walks you through setting up Firebase and Google Cloud for the Email Summary Agent app.

## Prerequisites

- A Google account
- Firebase account (free tier available)
- Google Cloud Console access
- Flutter development environment configured

---

## Part 1: Create Firebase Project

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `email-summary-agent` (or your preferred name)
4. Accept the Firebase terms
5. Disable Google Analytics (optional, not needed for this app)
6. Click **"Create project"**

---

## Part 2: Configure Firebase Authentication

### Step 1: Enable Authentication Methods

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable these sign-in providers:
   - **Email/Password**: Click the toggle to enable
   - **Google**: 
     - Click on Google
     - Enable it
     - For Development, you can use the default
     - Save

### Step 2: Set Up Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Make sure your Firebase project is selected in the top dropdown
3. Go to **APIs & Services** → **Credentials**
4. Click **"+ Create Credentials"** → **OAuth client ID**
5. If prompted, configure the OAuth consent screen first:
   - User Type: **External**
   - Click **Create**
   - Fill in App name: `Email Summary Agent`
   - Add your email as support email
   - Scroll to bottom and add your email as developer contact
   - Click **Save and Continue** through all screens
   - Click **Back to Credentials**

6. Now create OAuth credentials:
   - Click **"+ Create Credentials"** → **OAuth client ID**
   - For **Android**:
     - Application type: **Android**
     - Package name: `com.example.emailsummaryagent`
     - SHA-1 certificate fingerprint: `c27bc5560868a7a4fa60f14faeb201a4aea55ef6`
     - Click **Create**
     - Copy Client ID (you'll need this)

   - For **iOS**:
     - Application type: **iOS**
     - Bundle ID: `com.example.emailsummaryagent` (check your iOS project settings)
     - Click **Create**
     - Copy Client ID

   - For **Web** (if needed):
     - Application type: **Web application**
     - Add authorized redirect URIs if deploying web version
     - Click **Create**

---

## Part 3: Configure Firestore Database

### Step 1: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose location closest to you
4. Start in **Test mode** (for development)
   - ⚠️ **Important**: For production, switch to Production mode with proper security rules
5. Click **Enable**

### Step 2: Create Collections (Optional - Auto-created on first write)

Collections will be created automatically when data is written, but here's the expected structure:

```
users/
  {uid}/
    - name: String
    - email: String
    - photoUrl: String
    - preferences: Map
      - summaryType: String (daily/weekly)
      - emailFilter: String (all/unread/starred)
      - emailsPerBatch: int
      - summaryStyle: String (formal/casual/bullet_points)
      - deliveryMethod: String (in_app/in_inbox)
    - lastSummarizedAt: Timestamp

summaries/
  {uid}/summaries/
    {summaryId}/
    - batchIndex: int
    - content: String
    - Read: bool
    - bookmarked: bool
    - createdAt: Timestamp
```

---

## Part 4: Set Up Environment Variables

### Step 1: Create `.env` File

Create a `.env` file in your project root with the following values:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=email-summary-agent-6fcaa
FIREBASE_API_KEY=AIzaSyAxgq1mTHCKu61gk3-MC9zWYld-SY7GJqc
FIREBASE_AUTH_DOMAIN=email-summary-agent-6fcaa.firebaseapp.com
FIREBASE_STORAGE_BUCKET=email-summary-agent-6fcaa.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=514354700625
FIREBASE_APP_ID=1:514354700625:android:2d8a21180ed20fed51f370
FIREBASE_MEASUREMENT_ID=your_measurement_id

# Google OAuth Client IDs
GOOGLE_CLOUD_PROJECT_ID=email-summary-agent-6fcaa
GOOGLE_OAUTH_WEB_CLIENT_ID=514354700625-ibepurnogubrphfsj91kjbjkmpr9hsjo.apps.googleusercontent.com
GOOGLE_OAUTH_ANDROID_CLIENT_ID=514354700625-9u2qrapfmo9ue3bl834nes5hek32rr4e.apps.googleusercontent.com
GOOGLE_OAUTH_IOS_CLIENT_ID=your_ios_oauth_client_id

# Gemini API (for AI summaries)
GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 2: Find Your Values

**Get these values from Firebase Console:**

1. Go to Firebase Console → Project Settings (gear icon)
2. Copy these values:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_API_KEY`
   - `FIREBASE_AUTH_DOMAIN`
   - `FIREBASE_STORAGE_BUCKET`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_APP_ID`

**Get Google OAuth Client IDs from:**

1. Google Cloud Console → APIs & Services → Credentials
2. Find each OAuth client and copy the Client ID

**Get Gemini API Key:**

1. Google Cloud Console → APIs & Services → Credentials
2. Create an API Key (not OAuth)
3. Restrict it to Google Generative AI API only (for security)
4. Copy the key to `GEMINI_API_KEY`

---

## Part 5: Platform-Specific Setup

### Android Setup

The `google-services.json` file is already included in `android/app/`. Verify it contains:
- Correct project number and ID
- Your package name: `com.example.emailsummaryagent`
- SHA-1 certificate fingerprint (for Google Sign-in)

**If you changed the package name**, regenerate this file:
1. Go to Firebase Console → Project Settings
2. Under "Your apps", find the Android app
3. Download the new `google-services.json`
4. Replace `android/app/google-services.json`

### iOS Setup

1. Download `GoogleService-Info.plist` from Firebase:
   - Firebase Console → Project Settings → Your apps → iOS app
   - Click **Download GoogleService-Info.plist**

2. Place it in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on Runner folder → Add Files to Runner
   - Select the downloaded `GoogleService-Info.plist`
   - Ensure it's added to the Runner target

3. Update iOS bundle ID if different:
   - Xcode: Runner → Targets → Runner → General
   - Verify Bundle Identifier matches Firebase

### macOS & Windows Setup (if needed)

- **macOS**: Download `GoogleService-Info.plist` and add to Xcode same as iOS
- **Windows**: No Firebase setup required for basic Firebase-Web functionality

---

## Part 6: Gmail API Setup (for Email Fetching)

If your backend needs to fetch emails from Gmail:

### Step 1: Enable Gmail API

1. Google Cloud Console → APIs & Services → Library
2. Search for "Gmail API"
3. Click **Enable**

### Step 2: Create Service Account (Optional)

If using this app with a service account:
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **Service Account**
3. Fill in details and click **Create and Continue**
4. Skip optional steps
5. Go to Keys tab → Add Key → JSON
6. Save the JSON file securely (don't commit to repo)

---

## Part 7: Enable Realtime Email Fetching

### Gmail API Configuration

If your backend implementation uses Gmail API to fetch emails:

1. Make sure Gmail API is enabled (see Part 6)
2. Configure OAuth scopes in your backend:
   ```
   https://www.googleapis.com/auth/gmail.readonly
   ```
3. Add authorized redirect URIs:
   - For development: `http://localhost:3000/callback`
   - For production: Your actual app's callback URL

---

## Part 8: Security Rules for Firestore

⚠️ **For Production**: Replace the test mode security rules below.

Go to **Firestore Database** → **Rules** and set:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - only accessible to the user
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Summaries - only accessible to the user
    match /summaries/{uid}/summaries/{document=**} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

---

## Part 9: Build & Run the App

### Install Dependencies
```bash
flutter pub get
```

### Run with Environment Variables
```bash
# Android
flutter run --dart-define=GEMINI_API_KEY=your_api_key

# Or with all variables
flutter run \
  --dart-define=GEMINI_API_KEY=your_api_key \
  --dart-define=FIREBASE_PROJECT_ID=email-summary-agent-6fcaa \
  ...
```

### Or Build for Release
```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_api_key
flutter build ios --dart-define=GEMINI_API_KEY=your_api_key
```

---

## Troubleshooting

### Firebase Connection Issues

**Error: "Failed to initialize Firebase"**
- Ensure `.env` file has correct values
- Check internet connection
- Verify `google-services.json` is in correct location

### Google Sign-In Not Working

**On Android:**
- Verify SHA-1 certificate fingerprint matches Firebase
- Get correct fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore`
- Update in Firebase and re-download `google-services.json`

**On iOS:**
- Verify Bundle ID matches Firebase configuration
- Ensure `GoogleService-Info.plist` is added to Xcode

### Firestore Permissions Denied

- Go to Firestore → Rules
- Temporarily switch to Test Mode for development (not for production)
- Or update security rules to allow authenticated users

---

## Summary Checklist

- [ ] Firebase project created
- [ ] Authentication (Email/Password & Google) enabled
- [ ] Google OAuth credentials created for Android/iOS
- [ ] Firestore database created
- [ ] `.env` file created with all values
- [ ] `google-services.json` verified (Android)
- [ ] `GoogleService-Info.plist` downloaded (iOS)
- [ ] Gmail API enabled (if email fetching needed)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App built and tested locally

---

## Next Steps

1. **For Email Fetching**: Ensure your backend implements Gmail API integration
2. **For Production**: 
   - Switch Firestore to Production mode with proper security rules
   - Add signing certificates for Google Play & App Store
   - Enable reCAPTCHA on Authentication settings
3. **For Multiple Environments**: Create separate Firebase projects for dev/staging/production

---

For more details, visit:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Cloud Console](https://console.cloud.google.com)
- [Flutter Firebase Plugin](https://firebase.flutter.dev)
