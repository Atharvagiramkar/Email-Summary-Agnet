# Firebase Console Setup - Visual Step Guide

## 🖼️ UI Navigation Guide

This guide describes what you'll see at each step in Firebase Console.

---

## STEP 1: Open Firebase Console

### What You'll See
```
┌─────────────────────────────────────────────────┐
│  🔥 Firebase Console Header                      │
├─────────────────────────────────────────────────┤
│                                                  │
│  My Projects                                     │
│  ├─ Email Summary Agent  ← CLICK HERE            │
│  ├─ My App Project                               │
│  └─ Test Project                                 │
│                                                  │
└─────────────────────────────────────────────────┘
```

### Action
Click on **"Email Summary Agent"** project

---

## STEP 2: Left Sidebar Navigation

### After Clicking Project, You'll See

```
┌──────────────────────────────────────────┐
│  Email Summary Agent                      │
├──────────────────────────────────────────┤
│  🏠 Project Overview                      │
│  📋 Firestore Database                    │
│  🔐 Authentication                        │
│  🎁 Realtime Database                     │
│  ☁️ Cloud Functions          ← FIND THIS  │
│  📄 Cloud Storage                         │
│  📊 Analytics                             │
│  ⚙️ Settings                              │
│  🧩 Extensions               ← & THIS    │
│                                           │
│  (More options below)                     │
└──────────────────────────────────────────┘
```

### Action
1. First, click 🧩 **"Extensions"** (STEP 3)
2. Later, click ☁️ **"Cloud Functions"** (STEP 7)

---

## STEP 3: Extensions Page

### First Time View
```
┌─────────────────────────────────────────────────────────┐
│  🧩 Extensions                                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  "Get Started with Extensions"                          │
│                                                          │
│  ┌─────────────────────────────────────┐                │
│  │ [Explore Extensions]  [Install]  etc│                │
│  └─────────────────────────────────────┘                │
│                                                          │
│  No extensions installed yet                            │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Action
Click **"Explore Extensions"** or **"Install an Extension"**

---

## STEP 4: Extension Search

### Search Screen
```
┌─────────────────────────────────────────────────────────┐
│  🧩 Browse Extensions                                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [🔍 Search box: "sendgrid" ← TYPE HERE ]              │
│                                                          │
│  Results:                                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │ 📧 Trigger Email with SendGrid  ← CLICK THIS    │   │
│  │ By: Google                                       │   │
│  │ "Sends an email using SendGrid when a document" │   │
│  │ [Install in Console]                            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Other email extensions...                        │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Action
1. Type: **"sendgrid"**
2. Click the "**Trigger Email with SendGrid**" card

---

## STEP 5: Extension Details

### Extension Card View
```
┌─────────────────────────────────────────────────────────┐
│  📧 Trigger Email with SendGrid                         │
│  By Google                                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  "Sends an email using SendGrid when you write a"       │
│  "document to a specified Cloud Firestore collection"   │
│                                                          │
│  ✅ Tested on production                                 │
│  ✅ Free tier eligible                                   │
│  ⭐⭐⭐⭐⭐ (5 stars)                                      │
│                                                          │
│  [📖 View docs]  [❓ FAQ]  [⭐ Rate]                     │
│                                                          │
│  ┌─────────────────────────────────┐                    │
│  │ [Install in Console] ← CLICK    │                    │
│  └─────────────────────────────────┘                    │
│                                                          │
│  (Specifications, requirements below)                   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Action
Click **"Install in Console"** button

---

## STEP 6: Project Selection

### Dialog Box
```
┌─────────────────────────────────────┐
│  Select a Project                   │
├─────────────────────────────────────┤
│                                     │
│  Select a Firebase project to      │
│  install the extension:             │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🔽 Email Summary Agent ✓   │   │
│  └─────────────────────────────┘   │
│                                     │
│  (Usually pre-selected)             │
│                                     │
│  [Cancel]  [Install] ← CLICK       │
│                                     │
└─────────────────────────────────────┘
```

### Action
1. Verify "Email Summary Agent" is selected
2. Click **"Install"**

---

## STEP 7: Granting Permissions

### Permission Request
```
┌──────────────────────────────────────────────────┐
│  ⚠️ Grant Permissions                            │
├──────────────────────────────────────────────────┤
│                                                  │
│  This extension requires permission to:          │
│                                                  │
│  ✓ Write to your Firestore database             │
│  ✓ Run Cloud Functions                          │
│  ✓ Access Cloud Logging                         │
│                                                  │
│  These permissions allow the extension to       │
│  work correctly.                                 │
│                                                  │
│  [Deny]  [Grant Permissions] ← CLICK            │
│                                                  │
│  (May require Google sign-in)                   │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Action
Click **"Grant Permissions"**

### What Happens
- Google sign-in may appear
- Installation starts (3-5 minutes)
- Progress bar shows installation status
- Green checkmark ✅ when complete

---

## STEP 8: Configuration Page

### Extension Configuration Form
```
┌────────────────────────────────────────────────────────┐
│  📧 Trigger Email with SendGrid - Configuration        │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Cloud Tasks Queue Region *                           │
│  ┌──────────────────────────────────────────────────┐ │
│  │ us-central1 ◀ ▸ (Dropdown) ← SELECT REGION       │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  ┌ SMTP Configuration ────────────────────────────┐   │
│  │                                                │   │
│  │  SMTP Connection URI *                         │   │
│  │  ┌──────────────────────────────────────────┐ │   │
│  │  │ smtps://apikey:SG.xxxxxx@smtp.sendgrid  │ │   │
│  │  │ (Paste your SendGrid connection URI)    │ │   │
│  │  └──────────────────────────────────────────┘ │   │
│  │                                                │   │
│  │  Sender Email *                                │   │
│  │  ┌──────────────────────────────────────────┐ │   │
│  │  │ noreply@emailsummaryagent.com           │ │   │
│  │  └──────────────────────────────────────────┘ │   │
│  │                                                │   │
│  │  [Additional fields...]                        │   │
│  │                                                │   │
│  └────────────────────────────────────────────────┘   │
│                                                        │
│  Input fields for collection path, email field, etc  │
│                                                        │
│  [Cancel]  [Install Extension] ← CLICK               │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### Action
1. Fill in all fields (see FEEDBACK_QUICK_SETUP.md Phase 3)
2. Click **"Install Extension"**

---

## STEP 9: Cloud Functions Page

### After Installation Complete
```
┌─────────────────────────────────────────────────────────┐
│  ☁️ Cloud Functions                                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Functions:                                             │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │ ✅  sendFeedbackToEmail              us-central1 │   │
│  │     Cloud Firestore, sendFeedbackEmail()         │   │
│  │     Status: Running                             │   │
│  │     Memory: 256 MB                              │   │
│  │     Code: JavaScript                            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  [+Create Function]                                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Action
Click on **"sendFeedbackToEmail"** to edit

---

## STEP 10: Function Code Editor

### Code Tab
```
┌──────────────────────────────────────────────────┐
│  📝 Code                                          │
├──────────────────────────────────────────────────┤
│                                                  │
│  [Source tab] [Events] [Permissions] [Logs]     │
│                                                  │
│  Runtime: Node.js 18 ◀ ▸                        │
│ Memory: 256 MB                                  │
│                                                  │
│  index.js [▼]  package.json                     │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │ const functions = ...                    │   │
│  │ const nodemailer = ...                   │   │
│  │                                          │   │
│  │ (JavaScript code editor)                 │   │
│  │                                          │   │
│  │ exports.sendFeedbackToEmail = functions │   │
│  │ .firestore...                            │   │
│  │                                          │   │
│  │ (Paste code here)                        │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
│  [Deploy]  [Cancel]                            │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Action
1. Replace entire code with code from FEEDBACK_QUICK_SETUP.md
2. Click **"Deploy"**

---

## STEP 11: Runtime Settings

### Settings Tab
```
┌──────────────────────────────────────────────────┐
│  ⚙️ Runtime Settings                             │
├──────────────────────────────────────────────────┤
│                                                  │
│  [General] [Runtime Settings] [Permissions]     │
│                                                  │
│  Environment Variables:                         │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ Name: SENDGRID_API_KEY                  │   │
│  │ Value: SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxx  │   │
│  │        (Your SendGrid API Key)          │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  [Add Variable]                                 │
│                                                  │
│  Memory: 256 MB                                 │
│  Timeout: 60 seconds                           │
│                                                  │
│  [Save]                                        │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Action
1. Click **"Add Variable"**
2. Enter SENDGRID_API_KEY
3. Paste your SendGrid API key as Value
4. Click **"Save"**

---

## STEP 12: Logs Tab

### View Function Logs
```
┌──────────────────────────────────────────────────┐
│  📋 Logs                                          │
├──────────────────────────────────────────────────┤
│                                                  │
│  Time         Level    Message                   │
│                                                  │
│  14:32:45     INFO     Function execution       │
│                        started                   │
│                                                  │
│  14:32:47     INFO     ✅ Email sent for        │
│               (green)  feedback abc123          │
│                                                  │
│  14:32:48     INFO     Function execution       │
│                        completed                │
│                                                  │
│  (Error logs would show in red)                 │
│                                                  │
└──────────────────────────────────────────────────┘
```

### What to Look For
- ✅ Green messages = Success
- ❌ Red messages = Error (review details)

---

## STEP 13: Firestore Database Tab

### Firestore Collections View
```
┌──────────────────────────────────────────────────┐
│  📋 Firestore Database                           │
├──────────────────────────────────────────────────┤
│                                                  │
│  [Data] [Rules] [Indexes]                       │
│                                                  │
│  Collections:                                    │
│                                                  │
│  📁 feedback                                     │
│     ├─ feedback_123abc                          │
│     │  ├─ id: "feedback_123abc"                 │
│     │  ├─ uid: "user_456def"                    │
│     │  ├─ subject: "Test Feedback"              │
│     │  ├─ message: "This is a test"             │
│     │  ├─ userEmail: "test@gmail.com"           │
│     │  ├─ name: "Test User"                     │
│     │  ├─ createdAt: Apr 4, 2026, 2:30:45 PM   │
│     │  └─ status: "sent"                        │
│     │                                            │
│     └─ feedback_234bcd                          │
│        ├─ id: "feedback_234bcd"                 │
│        ├─ ... (similar fields)                  │
│                                                  │
│  [+ Create Collection]                          │
│                                                  │
└──────────────────────────────────────────────────┘
```

### What This Shows
- Each feedback submission as a document
- All user information preserved
- Timestamp of when submitted
- Status of email (sent/pending)

---

## STEP 14: Rules Tab

### Security Rules Editor
```
┌──────────────────────────────────────────────────┐
│  📋 Rules                                        │
├──────────────────────────────────────────────────┤
│                                                  │
│  [✏️ Edit Rules]                                │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ rules_version = '2';                    │   │
│  │                                         │   │
│  │ service cloud.firestore {               │   │
│  │   match /databases/{database}/          │   │
│  │          documents {                    │   │
│  │     match /feedback/{document=**} {     │   │
│  │       allow read: if ...                │   │
│  │       allow create: if ...              │   │
│  │       ...                               │   │
│  │     }                                   │   │
│  │   }                                     │   │
│  │ }                                       │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  [Publish]                                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

### Action
1. Click **"Edit Rules"**
2. Paste the complete rules from FEEDBACK_QUICK_SETUP.md
3. Click **"Publish"**

---

## ✅ Final Status View

### After Everything is Set Up
```
┌──────────────────────────────────────────────────┐
│  🎉 Setup Complete!                             │
│                                                  │
│  ✅ SendGrid Extension installed                │
│  ✅ Cloud Function deployed                     │
│  ✅ Environment variables set                   │
│  ✅ Firestore rules published                   │
│  ✅ Feedback collection created                 │
│  ✅ Test email received                         │
│  ✅ App feedback working                        │
│                                                  │
│  Your feedback system is now LIVE! 🚀           │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 🔍 Quick Icon Reference

| Icon | Means |
|------|-------|
| ✅ | Complete/Success |
| ❌ | Error/Failed |
| ⚠️ | Warning/Attention needed |
| 🔽 | Dropdown menu |
| 📝 | Text input |
| ◀ ▶ | Navigate/Scroll |
| [Button] | Clickable button |

---

## 📍 Common Button Locations

| Button | Location | Purpose |
|--------|----------|---------|
| Install Extension | Extensions page | Start installation |
| Grant Permissions | Permission dialog | Approve access |
| Deploy | Cloud Function code | Save and deploy |
| Publish | Firestore Rules tab | Apply security rules |
| Save | Runtime Settings | Save environment variables |
| Add Variable | Runtime Settings | Add new env var |

---

Last Updated: April 4, 2026
