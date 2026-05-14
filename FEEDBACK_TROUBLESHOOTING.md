# Feedback System - Troubleshooting & FAQ

## 🆘 Common Issues & Solutions

---

## Issue 1: "Extension won't install"

### Symptoms
- Installation button does nothing
- Page hangs on "Installing..."
- Get error message during installation

### Quick Fixes (Try in Order)

**Step 1: Clear Browser Cache**
1. Chrome Menu (three dots) → Settings → Clear browsing data
2. Select "All time"
3. Check: Cookies and other site data, Cached images and files
4. Click "Clear data"
5. Close and reopen Firebase Console

**Step 2: Try Incognito Mode**
1. Open new Incognito window (Ctrl+Shift+N on Windows)
2. Go to Firebase Console
3. Try installing extension again

**Step 3: Check Project Permissions**
1. Firebase Console → Settings (gear icon) → Project settings
2. Scroll to "Service account"
3. Click "Generate new private key" just to verify you have access
4. Try extension installation again

**Step 4: Use Different Browser**
- Try Microsoft Edge, Firefox, or Safari
- Sometimes Chrome has temporary issues

**Expected:** Installation takes 2-3 minutes with progress indicator

---

## Issue 2: "My email is not receiving feedback"

### Symptoms
- Feedback submitted in app
- No email in inbox
- No email in spam folder

### Diagnostic Steps

**Step 1: Check if Firestore Document Created**

1. Firebase Console → Firestore Database → Collections → "feedback"
2. Look for recent documents
3. Check the document has all these fields:
   - `id`
   - `uid`
   - `userEmail`
   - `name`
   - `subject`
   - `message`
   - `createdAt`
   - `status`

**If NO document:** Problem is in the app
   - Check user is authenticated
   - Verify user account is active
   - Test in emulator: `flutter run`

**If YES document:** Problem is in email delivery → Go to Step 2

---

**Step 2: Check Cloud Function Logs**

1. Firebase Console → Cloud Functions → `sendFeedbackToEmail`
2. Click on the function name
3. Go to "Logs" tab
4. Look for recent logs (last 5 minutes)

**Check for:**
- Green checkmarks ✅ = email sent successfully
- Red Xs ❌ = error occurred

**Copy the error message** if you see one

**Common Error Messages:**

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | SendGrid API Key wrong | Check API key in Environment Variables |
| `ECONNREFUSED` | Can't connect to SendGrid | Check internet connection, verify API key |
| `SMTP Error: Invalid sender` | Sender email not verified | Verify sender in SendGrid dashboard |
| `Function timeout` | Took too long | Increase timeout to 60 seconds |

---

**Step 3: Check SendGrid Configuration**

1. Go to SendGrid Dashboard: https://app.sendgrid.com
2. Navigate to **Settings** → **API Keys**
3. Find your API key
4. Click on it to view details
5. Verify **Permissions**: Should include "Mail Send"

**If No API Key:**
   - Click "Create API Key"
   - Name: `Email Summary App Feedback`
   - Grant permission: "Mail Send" (Full Access)
   - Copy the key
   - Go to Firebase → Cloud Functions → sendFeedbackToEmail → Runtime Settings
   - Paste the API key in SENDGRID_API_KEY environment variable
   - Click "Deploy"
   - Wait 2 minutes for update

---

**Step 4: Check SendGrid Sender Verification**

1. SendGrid Dashboard → **Settings** → **Sender Authentication**
2. Look for your sender email/domain

**If Not Listed:**
   - Click "Verify a Single Sender"
   - Add your email address
   - Check your email for verification link
   - Click the link
   - Wait 5 minutes

**If Listed but "Unverified":**
   - Click on it
   - Click "Re-verify"

**Important:** SendGrid Free Tier only sends from verified addresses

---

**Step 5: Manual Email Test**

1. Firebase Console → Cloud Functions → `sendFeedbackToEmail`
2. Look for your test document in Firestore
3. Click on it
4. Check `status` field = `sent`
5. Check timestamps to ensure it's recent
6. Go to Cloud Functions → Logs
7. Search for the feedback ID in logs
8. Look for success message

**If success in logs but no email:**
   - Check spam folder (sometimes Gmail filters it)
   - Add to contacts: `noreply@emailsummaryagent.com`
   - Try with different email sender

---

## Issue 3: "Firestore document not saving"

### Symptoms
- User submits feedback
- No error message
- Document doesn't appear in Firestore
- App shows: "Thank you for your feedback"

### Causes & Solutions

**Cause 1: User Not Authenticated**
- Solution: Login again in app → Try submitting feedback

**Cause 2: Firestore Security Rules Blocking**
1. Firebase Console → Firestore Database → Rules tab
2. Check if your rule has:
   ```firestore
   allow create: if request.auth.uid != null
   ```
3. If not, update with the complete rule set from FEEDBACK_QUICK_SETUP.md
4. Click "Publish"

**Cause 3: Firestore Quota Exceeded**
1. Firebase Console → Quotas page
2. Check "Firestore writes" usage
3. If at limit:
   - Upgrade to pay-as-you-go plan
   - Or wait until quota resets (usually next day)

**Cause 4: App Offline**
- Check internet connection
- Run in emulator to test: `flutter run -d emulator-5554`

---

## Issue 4: "Permission Denied" error in Firestore"

### Symptoms
- See error in app: "Permission Denied"
- App crashes or shows error dialog
- Cannot save feedback

### Solution

1. Firebase Console → Firestore Database → Rules
2. Copy and paste this exact rule:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to create feedback
    match /feedback/{document=**} {
      allow read: if request.auth.uid == resource.data.uid;
      allow create: if request.auth.uid != null && 
                       request.auth.uid == request.resource.data.uid;
      allow update: if false;
      allow delete: if request.auth.uid == resource.data.uid;
    }
    
    // Deny everything else by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click "Publish"
4. Wait 30 seconds for rules to activate
5. Test again in app

---

## Issue 5: "Function shows error in logs"

### Symptoms
- Cloud Function showing red X ❌
- Error message in logs
- Email not sending

### Debugging Steps

**Step 1: Read the Error Message**
1. Cloud Functions → sendFeedbackToEmail → Logs
2. Find your error
3. Copy the full error text

**Step 2: Common Error Fixes**

**Error: "Cannot read property 'userEmail' of undefined"**
- Problem: Firestore document missing fields
- Fix: Make sure all fields in FEEDBACK_QUICK_SETUP.md Step 4 are present

**Error: "Invalid credentials"**
- Problem: SendGrid API key wrong or expired
- Fix:
  1. SendGrid → Settings → API Keys
  2. Generate new key
  3. Update Cloud Functions → Runtime Settings
  4. Re-deploy

**Error: "ENOTFOUND smtp.sendgrid.net"**
- Problem: Network issue
- Fix: 
  1. Check internet (use different device/network)
  2. Verify Cloud Function has internet access
  3. Try in 5 minutes (might be temporary)

**Error: "Function timeout"**
- Problem: Email took too long to send
- Fix:
  1. Cloud Functions → sendFeedbackToEmail → Edit
  2. Go to Runtime Settings
  3. Change Timeout to 60 seconds
  4. Save and deploy

---

## Issue 6: "SendGrid says 'email bounced'"

### Symptoms
- Email shows in SendGrid as "Bounced"
- You never receive the feedback
- SendGrid Dashboard shows "Hard Bounce" or "Soft Bounce"

### Meanings

| Bounce Type | Meaning | Fix |
|-----------|---------|-----|
| Hard Bounce | Email address doesn't exist | Verify email is correct in feedback_service.dart |
| Soft Bounce | Temporary issue | Wait 24 hours, try resending |
| Unsubscribed | Email marked as unsubscribed | Check SendGrid suppression list |

### Solution

1. SendGrid Dashboard → **Suppressions** → **Bounces**
2. Look for `atharvagiramkar4@gmail.com`
3. If found, click **Delete**
4. Wait 5 minutes
5. Test sending manually again

---

## Issue 7: "App crashes when I click 'Send Feedback'"

### Symptoms
- App crashes (closes completely)
- See error in console/terminal
- No error message in app UI

### Quick Fixes

**Step 1: Run with Debugging**
```bash
flutter run --verbose
```

Look for error message in output, then search that error below.

**Step 2: Check Dependencies**
1. Open `pubspec.yaml`
2. Verify `uuid: ^4.0.0` is listed
3. Run: `flutter pub get`
4. Try again

**Step 3: Check Imports**
1. Open `lib/screens/profile_page.dart`
2. Verify these lines exist:
```dart
import 'package:emailsummaryagent/screens/feedback_dialog.dart';
import 'package:emailsummaryagent/services/feedback_service.dart';
```

If missing, run:
```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

**Step 4: Rebuild App**
```bash
flutter clean
flutter pub get
flutter run
```

---

## Issue 8: "Emails arriving but with formatting issues"

### Symptoms
- Email arrives but looks broken
- HTML not rendering correctly
- Text displaying as code

### Solution

This is usually a email client issue. Try:

1. Open the email in different client:
   - Gmail (web version)
   - Outlook web
   - Apple Mail
   
2. If it works in Gmail web but not desktop:
   - Use web version instead
   - Update your email client

3. If broken in all clients:
   - Cloud Functions → sendFeedbackToEmail → Edit
   - Check the HTML in the function
   - Compare with code in FEEDBACK_QUICK_SETUP.md
   - Update if different
   - Deploy again

---

## Issue 9: "Multiple emails arriving for one submission"

### Symptoms
- User submits feedback once
- You receive email 2-3 times
- Or receive feedback twice

### Causes & Fixes

**Cause 1: Document uploaded twice**
- Solution: Check Firestore - delete duplicate documents

**Cause 2: Cloud Function running multiple times**
- Solution:
  1. Cloud Functions → sendFeedbackToEmail
  2. Check "Maximum instances" setting
  3. Set to 1
  4. Deploy

**Cause 3: User submitted form twice**
- Solution: 
  1. Check if button was clickable twice
  2. Profile page → FeedbackDialog
  3. Verify: `onPressed: _isSubmitting ? null : _submitFeedback`
  4. This should prevent double-clicks

---

## Issue 10: "Can't find my API key in SendGrid"

### Symptoms
- Can't locate API key in SendGrid
- Lost or forgot the key
- SMTP Connection failing

### Solution - Create New API Key

1. Go to https://app.sendgrid.com
2. Login (if not already)
3. Left sidebar → **Settings** → **API Keys**
4. Click **Create API Key** (blue button)
5. **API Key Name**: `Email Summary App Feedback`
6. **API Key Permissions**:
   - ☑️ Restricted Access
   - Under Mail Send: ☑️ Full Access
7. Click **Create & Edit**
8. **Copy the API Key** (it starts with `SG.` and is very long)
9. Click **I have saved my API key** (confirmation)
10. Paste the key into Firebase Cloud Functions:
    - Firebase Console → Cloud Functions → sendFeedbackToEmail
    - Runtime Settings
    - SENDGRID_API_KEY = `SG.your_key_here`
    - Deploy

**⚠️ Important:** API keys are only shown once. Save it somewhere safe!

---

## 🆘 Still Not Working?

### Data to Collect

1. **Firestore Document**:
   - Screenshot of the feedback document in Firestore

2. **Cloud Function Logs**:
   - Copy the entire error message from Functions logs

3. **App Error**:
   - Run `flutter run --verbose`
   - Screenshot/copy any error messages

4. **SendGrid Status**:
   - Screenshot from SendGrid dashboard showing:
     - List of API Keys
     - Sender Authentication status
     - Email Activity/Logs

### Where to Get Help

1. **Firebase Emulator**: Test locally first
   ```bash
   firebase emulators:start
   flutter run
   ```

2. **Firebase Support**: https://firebase.google.com/support

3. **SendGrid Support**: https://support.sendgrid.com

4. **Stack Overflow**: Search for similar issues

---

## 📋 Pre-Support Checklist

Before contacting support, verify:

- [ ] SendGrid account created and verified
- [ ] API Key generated and saved
- [ ] Sender email verified in SendGrid
- [ ] Firebase Project settings allow Functions
- [ ] Firestore rules published
- [ ] Cloud Function deployed successfully
- [ ] Environment variables set (SENDGRID_API_KEY)
- [ ] Firestore collection "feedback" created
- [ ] Test document manually created
- [ ] Manual test email attempted
- [ ] Logs checked for errors
- [ ] Firebase project quota not exceeded

---

## ✅ Quick Status Check

Run this checklist to verify everything works:

```
1. ☐ Go to Firebase Console
2. ☐ Navigate to Firestore → feedback collection
3. ☐ See at least 1 document? YES/NO
4. ☐ Go to Cloud Functions → sendFeedbackToEmail → Logs
5. ☐ See green checkmarks in logs? YES/NO
6. ☐ Check email inbox (include spam)
7. ☐ See feedback email? YES/NO

Results:
- All YES: ✅ System working perfectly!
- No Firestore doc: ❌ Problem in app form/auth
- Error in logs: ❌ Check Runtime Settings
- No email received: ❌ Check SendGrid configuration
```

---

**Last Updated**: April 4, 2026  
**For Issues**: Contact developer at atharvagiramkar4@gmail.com
