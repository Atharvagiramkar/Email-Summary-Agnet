# Complete Firebase & Google Cloud Setup Guide

A step-by-step guide to set up Firebase, Google Cloud Console, and Gemini API for the Email Summary Agent app.

---

## Table of Contents
1. [Firebase Project Setup](#step-1-firebase-project-setup)
2. [Firebase Sign-In Methods Setup](#step-2-firebase-sign-in-methods-setup)
3. [Firestore Setup](#step-3-firestore-setup)
4. [Google Cloud Console Setup](#step-4-google-cloud-console-setup)
5. [Gemini API Key Creation](#step-5-gemini-api-key-creation)
6. [Configuration File Setup](#step-6-configuration-file-setup)
7. [Verification & Testing](#step-7-verification--testing)

---

## Step 1: Firebase Project Setup

### 1.1 Create a New Firebase Project

1. Open [Firebase Console](https://console.firebase.google.com) in your browser
2. Make sure you're logged in with **your own Google account**
3. Click the **"Add project"** button
   
   ![Firebase Add Project](./images/firebase-add-project.png)

4. In the dialog box that appears:
   - **Project name**: Enter `email-summary-agent`
   - Click **"Continue"**

5. (Optional) Enable Google Analytics:
   - You can disable this for now (not required for this app)
   - Click **"Create project"**

6. Wait for the project to be created (this may take 1-2 minutes)

7. Once created, you'll see your Firebase dashboard
   - Note your **Project ID** from the top bar (format: `email-summary-agent-xxxxx`)

### 1.2 Connect to Google Cloud Project

1. In Firebase Console, click the **⚙️ Settings icon** → **Project settings**
2. Under **Integrations** section, you'll see your **Google Cloud Project**
3. Click on it to open Google Cloud Console (you'll need it later)
4. Copy and save your **Project ID** for later use

---

## Step 2: Firebase Sign-In Methods Setup

### 2.1 Enable Email/Password Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click the **"Sign-in method"** tab
3. Click on **"Email/Password"**
4. Toggle **"Enable"** to turn it ON
5. Toggle **"Email link (passwordless sign-in)"** to OFF (we'll use password-based)
6. Click **"Save"**

   ![Firebase Email/Password](./images/firebase-email-password.png)

### 2.2 Enable Google Sign-In

1. Still in **Authentication** → **Sign-in method**
2. Click on **"Google"**
3. Toggle **"Enable"** to turn it ON
4. **For "Project support email"**: Select your email from the dropdown (or enter it)
5. Click **"Save"**

   ![Firebase Google Sign-In](./images/firebase-google-signin.png)

⚠️ **Note**: We'll complete the Google OAuth configuration later in the Google Cloud Console section.

### 2.3 Verify Sign-In Methods

Your **Sign-in method** tab should now show:
- ✅ Email/Password - **Enabled**
- ✅ Google - **Enabled**

---

## Step 3: Firestore Setup

### 3.1 Create a Firestore Database

1. In Firebase Console, go to **Firestore Database** (left sidebar)
2. Click **"Create database"** button
3. In the dialog that appears:
   - **Select database location**: Choose the region closest to your users
     - For India: `asia-south1 (Delhi)`
     - For US: `us-central1`
     - For Europe: `eu-west1 (Belgium)` or `europe-west1 (Belgium)`
   - Click **"Next"**

4. **Security rules**: 
   - Select **"Start in test mode"** (for development only)
   - Click **"Create"**

   ⚠️ **Important**: This allows anyone to read/write. For production, you must update the rules.

5. Wait for Firestore to initialize (takes a few seconds)

### 3.2 Firestore Collections Structure

Your app will automatically create these collections when first used:

```
Firestore Root
├── users/
│   └── {uid}/
│       ├── name: String
│       ├── email: String
│       ├── photoUrl: String
│       ├── preferences: Map
│       │   ├── summaryType: String (daily/weekly)
│       │   ├── emailFilter: String (all/unread/starred)
│       │   ├── emailsPerBatch: Number
│       │   ├── summaryStyle: String (formal/casual/bullet_points)
│       │   └── deliveryMethod: String (in_app/in_inbox)
│       └── lastSummarizedAt: Timestamp
│
└── summaries/
    └── {uid}/
        └── summaries/
            └── {summaryId}/
                ├── batchIndex: Number
                ├── content: String
                ├── read: Boolean
                ├── bookmarked: Boolean
                └── createdAt: Timestamp
```

### 3.3 Set Test Mode Security Rules (Development)

1. In Firestore Database page, click on **"Rules"** tab
2. Replace all content with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes for authenticated users during development
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

⚠️ **For Production**: Update these rules to be more restrictive:

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

### 3.4 Verify Firestore Setup

1. In Firestore Database page, you should see:
   - ✅ Database location selected
   - ✅ Security rules set
   - ✅ No collections yet (will be created automatically)

---

## Step 4: Google Cloud Console Setup

### 4.1 Enable Required APIs

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Make sure your **Project** is selected (top dropdown)
3. Go to **APIs & Services** → **Library** (left sidebar)

#### Enable Gmail API:
1. Search for **"Gmail API"**
2. Click on it
3. Click **"ENABLE"**
4. Wait for it to enable

#### Enable Google Identity Services:
1. Go back to **Library**
2. Search for **"Google Identity Service"** or **"Identity and Access Management"**
3. Click **"ENABLE"** if not already enabled

### 4.2 Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen** (left sidebar)
2. **User Type**: Select **"External"**
3. Click **"CREATE"**
4. Fill in the form:

   **App information:**
   - **App name**: `Email Summary Agent`
   - **User support email**: Your email address
   - **Authorized domains** (optional): Leave empty for development

5. Click **"SAVE AND CONTINUE"**

6. **Scopes** page:
   - Click **"ADD OR REMOVE SCOPES"**
   - Search for: `gmail.readonly`
   - Select it and click **"UPDATE"**
   - Click **"SAVE AND CONTINUE"**

7. **Test users** page:
   - Click **"ADD USERS"**
   - Enter your email address
   - Click **"ADD"**
   - Click **"SAVE AND CONTINUE"**

8. Review everything and click **"BACK TO DASHBOARD"**

### 4.3 Create OAuth 2.0 Credentials (Android)

1. Go to **APIs & Services** → **Credentials** (left sidebar)
2. Click **"+ CREATE CREDENTIALS"** → **OAuth client ID**
3. **Application type**: Select **"Android"**
4. Fill in:
   - **Package name**: `com.example.emailsummaryagent`
   - **SHA-1 certificate fingerprint**: `c27bc5560868a7a4fa60f14faeb201a4aea55ef6`
5. Click **"CREATE"**
6. Copy the **Client ID** that appears (you'll need this later)

   **Example format**: `514354700625-9u2qrapfmo9ue3bl834nes5hek32rr4e.apps.googleusercontent.com`

7. Click outside the dialog or press Escape

### 4.4 Create OAuth 2.0 Credentials (iOS)

1. Click **"+ CREATE CREDENTIALS"** → **OAuth client ID** again
2. **Application type**: Select **"iOS"**
3. Fill in:
   - **Bundle ID**: `com.example.emailsummaryagent` (match your iOS project)
4. Click **"CREATE"**
5. Copy the **Client ID** that appears
6. Click outside the dialog

### 4.5 Create OAuth 2.0 Credentials (Web)

1. Click **"+ CREATE CREDENTIALS"** → **OAuth client ID** again
2. **Application type**: Select **"Web application"**
3. Fill in:
   - **Name**: `Email Summary Agent Web`
   - **Authorized redirect URIs**:
     - Add: `http://localhost:3000/callback` (development)
     - Add: `https://yourdomain.com/callback` (production - optional)
4. Click **"CREATE"**
5. Copy the **Client ID** (you'll need this)
6. Click outside the dialog

### 4.6 Get Your Google Cloud Project Details

1. Go to **APIs & Services** → **Credentials**
2. Under **API Keys** section, click **"+ CREATE CREDENTIALS"** → **API Key**
3. Copy the **API Key** that appears (this is your Firebase API Key)
4. Click the pencil icon to edit it
5. Under **API restrictions**:
   - Click **"Restrict key"**
   - Select **"All APIs"** → Change to **"Google Generative AI API"** (for Gemini)
   - Click **"SAVE"**

6. Go to **IAM & Admin** → **Settings**
7. Copy your **Project Number** (displayed at the top)

---

## Step 5: Gemini API Key Creation

### 5.1 Enable Google Generative AI API

1. In Google Cloud Console, go to **APIs & Services** → **Library**
2. Search for **"Google Generative AI API"** or **"Generative Language API"**
3. Click on it
4. Click **"ENABLE"**

### 5.2 Create Gemini API Key

1. Go to **APIs & Services** → **Credentials**
2. Click **"+ CREATE CREDENTIALS"** → **API Key**
3. A new API Key will be created and displayed
4. Copy this **API Key** (this is your **GEMINI_API_KEY**)
5. Click the pencil icon to edit and set restrictions:
   - **Key restriction type**: Select **"API restriction"**
   - **Restrict key to specific APIs**: Search and select **"Generative Language API"**
   - Click **"SAVE"**

**Example format**: `AIzaSyAxgq1mTHCKu61gk3-MC9zWYld-SY7GJqc`

### 5.3 Verify Gemini Setup

1. Check that the Generative Language API shows as **ENABLED** in your APIs list
2. Your API Key is restricted to only this API (more secure)

---

## Step 6: Configuration File Setup

### 6.1 Get Firebase Configuration Values

1. Go to Firebase Console → **⚙️ Settings** → **Project settings**
2. Under **"Your apps"** section, find your Android app
3. Copy these values:

   | Value | Where to Find |
   |-------|--------------|
   | **Project ID** | Top of Settings page or `email-summary-agent-xxxxx` |
   | **API Key** | Google Cloud Console → Credentials → API Keys |
   | **Auth Domain** | Settings page → Web API key details |
   | **Storage Bucket** | Settings page → `email-summary-agent-xxxxx.firebasestorage.app` |
   | **Messaging Sender ID** | Settings page (labeled as "Sender ID") |
   | **App ID** | Settings page (Android App ID) |

### 6.2 Download Platform-Specific Config Files

#### For Android:
1. Firebase Console → **Project settings** → **Your apps** → Android app
2. Click **"google-services.json"** download button
3. Save it to: `android/app/google-services.json`
4. Replace the existing file

#### For iOS:
1. Firebase Console → **Project settings** → **Your apps** → iOS app
2. Click **"GoogleService-Info.plist"** download button
3. Open `ios/Runner.xcworkspace` in Xcode
4. Right-click on **Runner** folder → **Add Files to "Runner"**
5. Select the downloaded plist file
6. Check **"Copy items if needed"** → Click **"Add"**

### 6.3 Create `.env` File

1. In your project root directory (same level as `pubspec.yaml`), create a file named `.env`
2. Add the following content with your values:

```env
# ==================== FIREBASE CONFIGURATION ====================

# Get these from Firebase Console → Project Settings
FIREBASE_PROJECT_ID=email-summary-agent-6fcaa
FIREBASE_API_KEY=AIzaSyAxgq1mTHCKu61gk3-MC9zWYld-SY7GJqc
FIREBASE_AUTH_DOMAIN=email-summary-agent-6fcaa.firebaseapp.com
FIREBASE_STORAGE_BUCKET=email-summary-agent-6fcaa.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=514354700625
FIREBASE_APP_ID=1:514354700625:android:2d8a21180ed20fed51f370
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# ==================== GOOGLE OAUTH CLIENT IDS ====================

# Get these from Google Cloud Console → APIs & Services → Credentials
GOOGLE_CLOUD_PROJECT_ID=email-summary-agent-6fcaa
GOOGLE_OAUTH_WEB_CLIENT_ID=514354700625-ibepurnogubrphfsj91kjbjkmpr9hsjo.apps.googleusercontent.com
GOOGLE_OAUTH_ANDROID_CLIENT_ID=514354700625-9u2qrapfmo9ue3bl834nes5hek32rr4e.apps.googleusercontent.com
GOOGLE_OAUTH_IOS_CLIENT_ID=514354700625-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com

# ==================== GEMINI API KEY ====================

# Get this from Google Cloud Console → APIs & Services → Credentials
GEMINI_API_KEY=AIzaSyAxgq1mTHCKu61gk3-MC9zWYld-SY7GJqc
```

3. **IMPORTANT**: Add `.env` to `.gitignore`:
   ```
   .env
   .env.local
   ```

4. Open `.gitignore` in your project root and verify `.env` is listed
   - If not, add it manually

### 6.4 Verify Environment Setup

1. Run this command in your terminal:
   ```bash
   flutter pub get
   ```

2. Verify `.env` file is created:
   ```bash
   ls -la .env  # macOS/Linux
   dir .env     # Windows
   ```

---

## Step 7: Verification & Testing

### 7.1 Pre-Flight Checklist

Before running the app, verify everything is set up:

- [ ] Firebase project created with correct name
- [ ] Email/Password sign-in enabled in Firebase
- [ ] Google sign-in enabled in Firebase
- [ ] OAuth consent screen configured
- [ ] Android OAuth credential created
- [ ] iOS OAuth credential created
- [ ] Web OAuth credential created (optional)
- [ ] Firestore database created and initialized
- [ ] Gmail API enabled in Google Cloud
- [ ] Generative Language API enabled
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `GoogleService-Info.plist` downloaded and added to Xcode (iOS)
- [ ] `.env` file created with all credentials
- [ ] `.env` added to `.gitignore`

### 7.2 Build and Run the App

#### For Android:

```bash
# Build and run the app
flutter run --dart-define=GEMINI_API_KEY='YOUR_GEMINI_API_KEY_HERE'

# Or if using .env file (it should auto-load):
flutter run
```

#### For iOS:

```bash
# First, update pods
cd ios
pod update
cd ..

# Run the app
flutter run --dart-define=GEMINI_API_KEY='YOUR_GEMINI_API_KEY_HERE'
```

### 7.3 Test Sign-In Methods

Once the app is running:

1. **Email/Password Sign-up**:
   - Tap "Register" 
   - Enter email: `test@example.com`
   - Enter password: `Test@123456`
   - Verify account is created
   - Check Firestore → Collections → `users` collection is created

2. **Google Sign-in**:
   - Tap "Sign in with Google"
   - Select your test account
   - Verify the account is logged in successfully

3. **Firebase Connection**:
   - Go to Firebase → **Authentication** → **Users**
   - Verify your test accounts appear here

### 7.4 Verify Firestore Integration

1. Firebase Console → **Firestore Database**
2. After first sign-in, you should see:
   - New collection: `users`
   - New document: Your user ID with your data

### 7.5 Test Gemini Integration

1. In the app, go to **Home screen** → **Generate Summary** button
2. The app should attempt to call Gemini API
3. If successful, you'll see a summary generated
4. If failed, check:
   - `GEMINI_API_KEY` in `.env` is correct
   - Generative Language API is enabled in Google Cloud
   - API Key has correct restrictions

---

## Troubleshooting

### Problem: "Firebase initialization failed"

**Solution**:
1. Verify `google-services.json` is in `android/app/`
2. Verify `GoogleService-Info.plist` is added to Xcode
3. Check all credentials in `.env` match Firebase settings
4. Run `flutter clean` then `flutter pub get`

### Problem: "Google Sign-in failed"

**Solution**:
1. Verify OAuth consent screen is set to "External" mode
2. Verify you added test user email in OAuth consent screen
3. Verify Android OAuth Client ID is correct
4. Check SHA-1 fingerprint matches exactly: `c27bc5560868a7a4fa60f14faeb201a4aea55ef6`

### Problem: "Firestore permission denied"

**Solution**:
1. Firestore is in Test mode (should allow reads/writes)
2. Verify security rules are published (go to Rules tab and click Publish)
3. Check you're logged in to Firebase Auth

### Problem: "Gemini API not working"

**Solution**:
1. Verify API Key is correct in `.env`
2. Verify Generative Language API is ENABLED
3. Check API Key has correct restrictions (Generative Language API only)
4. Check API Key is not expired or revoked
5. Run this to test connectivity:
   ```bash
   curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=YOUR_API_KEY"
   ```

---

## Summary of Created Resources

After completing this guide, you should have:

✅ **Firebase Project**
- Email/Password authentication
- Google sign-in authentication
- Firestore database with test mode

✅ **Google Cloud Console Setup**
- Gmail API enabled
- Generative Language API enabled
- OAuth consent screen configured
- Android OAuth credentials
- iOS OAuth credentials
- Web OAuth credentials (optional)
- API Key for Gemini

✅ **Configuration Files**
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `.env` file with all API keys and credentials

✅ **Ready to Run**
- All dependencies configured
- All APIs enabled
- Ready for app development and testing

---

## Next Steps

1. **Start Development**: You can now develop the app with full Firebase and Gemini integration
2. **Test All Features**: Test authentication, Firestore operations, and Gemini summaries
3. **Before Production**:
   - Update Firestore security rules from test mode to production rules
   - Add signing certificates for Google Play & App Store
   - Enable reCAPTCHA protection
   - Create separate Firebase projects for staging/production
   - Rotate API keys regularly

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Cloud Console](https://console.cloud.google.com)
- [Google Generative AI API](https://ai.google.dev/tutorials/rest_quickstart)
- [Flutter Firebase Plugin](https://firebase.flutter.dev)
- [Gmail API Documentation](https://developers.google.com/gmail/api/guides)
