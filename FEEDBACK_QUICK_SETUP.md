# Firebase Extensions Setup - Quick Reference Checklist

**⏱️ Estimated Time: 15-20 minutes**

---

## 📋 Pre-Setup Checklist

- [ ] Have Firebase Console open (https://console.firebase.google.com/)
- [ ] Have your SendGrid account ready (or create free account at sendgrid.com)
- [ ] Have your GitHub/project access ready
- [ ] Have your developer email ready: `atharvagiramkar4@gmail.com`

---

## 🎯 Step-by-Step Checklist

### Phase 1: SendGrid Setup (5 minutes)

- [ ] Go to https://app.sendgrid.com
- [ ] Create account or log in
- [ ] Navigate to **Settings** → **API Keys**
- [ ] Click **Create API Key**
- [ ] Name: `Email Summary App Feedback`
- [ ] Click **Create & Edit**
- [ ] **Copy the API Key** (starts with `SG.`)
- [ ] Go to **Settings** → **Sender Authentication**
- [ ] Add and verify sender email or domain
- [ ] **Save your API Key** (you'll need it soon)

### Phase 2: Firebase Extensions Installation (5 minutes)

- [ ] Open **Firebase Console** → Select **Email Summary Agent** project
- [ ] Left sidebar → Click **Extensions** (🧩 icon)
- [ ] Click **Install an Extension** or **Explore Extensions**
- [ ] Search: `sendgrid` then press Enter
- [ ] Find **"Trigger Email with SendGrid"** (by Google)
- [ ] Click the extension card
- [ ] Click **Install in Console** button
- [ ] Select project (Email Summary Agent)
- [ ] Click **Continue** → **Install Extension**
- [ ] Wait 2-3 minutes for installation to complete
- [ ] You should see a green checkmark ✅

### Phase 3: Configure Extension Parameters (3 minutes)

Once installed, fill in these fields:

- [ ] **Cloud Tasks Queue Region**
  - Select: `us-central1` (or your region)

- [ ] **SMTP Connection URI**
  - Copy this format: `smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:587`
  - Replace `YOUR_SENDGRID_API_KEY` with your copied key from SendGrid
  - Example: `smtps://apikey:SG.abc123xyz789@smtp.sendgrid.net:587`

- [ ] **Email address to send from**
  - Use verified sender from SendGrid
  - Example: `noreply@emailsummaryagent.com` (or your domain)

- [ ] **Email template path**
  - Leave empty

- [ ] **Firestore document path pattern**
  - Enter: `feedback/{uid}`

- [ ] **Email field**
  - Enter: `to`

- [ ] Click **Review and Install**

- [ ] Click **Install Extension**

### Phase 4: Create Firestore Collection (2 minutes)

- [ ] Go to **Firestore Database**
- [ ] Click **Data** tab
- [ ] Click **+ Create Collection**
- [ ] Collection ID: `feedback`
- [ ] Click **Next**
- [ ] Click **Auto ID**
- [ ] Add test document with:
  ```
  id: test-1
  uid: test-user
  userEmail: your-email@gmail.com
  name: Test User
  subject: Setup Test
  message: Testing the setup
  createdAt: (current timestamp)
  status: sent
  ```
- [ ] Click **Save**

### Phase 5: Update Firestore Security Rules (2 minutes)

- [ ] Go to **Firestore Database** → **Rules** tab
- [ ] Copy entire content in editor
- [ ] Paste this:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /feedback/{document=**} {
      allow read: if request.auth.uid == resource.data.uid;
      allow create: if request.auth.uid != null && 
                       request.auth.uid == request.resource.data.uid;
      allow update: if false;
      allow delete: if request.auth.uid == resource.data.uid;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

- [ ] Click **Publish**

### Phase 6: Set Up Cloud Function (3 minutes)

- [ ] Go to **Cloud Functions**
- [ ] Click **Create Function**
- [ ] Function name: `sendFeedbackToEmail`
- [ ] Region: Select same as Phase 2 (us-central1)
- [ ] Trigger: **Cloud Firestore**
- [ ] Event type: **On create**
- [ ] Database: (default)
- [ ] Document path: `feedback/{docId}`
- [ ] Runtime: **Node.js 18** (or latest)
- [ ] Click **Create and Deploy**
- [ ] Wait for deployment (2 minutes)
- [ ] Go to **Code** tab
- [ ] Paste code from `sendFeedbackEmail.js` (see below)
- [ ] Click **Deploy**

**Function Code to Paste:**

```javascript
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: "smtp.sendgrid.net",
  port: 587,
  secure: false,
  auth: {
    user: "apikey",
    pass: process.env.SENDGRID_API_KEY,
  },
});

exports.sendFeedbackToEmail = functions.firestore
  .document("feedback/{docId}")
  .onCreate(async (snap, context) => {
    const feedback = snap.data();

    try {
      const mailOptions = {
        from: "noreply@emailsummaryagent.com",
        to: "atharvagiramkar4@gmail.com",
        replyTo: feedback.userEmail,
        subject: `[User Feedback] ${feedback.subject}`,
        html: `<div style="font-family: Arial, sans-serif;"><div style="background: linear-gradient(135deg, #1E6BFF 0%, #00D4AA 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0;"><h1 style="margin: 0;">New User Feedback</h1></div><div style="background: #f5f5f5; padding: 20px; border-radius: 0 0 8px 8px;"><table style="width: 100%; border-collapse: collapse;"><tr><td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>From:</strong></td><td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${feedback.name}</td></tr><tr><td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>Email:</strong></td><td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><a href="mailto:${feedback.userEmail}">${feedback.userEmail}</a></td></tr><tr><td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>Subject:</strong></td><td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>${feedback.subject}</strong></td></tr></table><div style="margin-top: 20px; padding: 15px; background: white; border-left: 4px solid #1E6BFF; border-radius: 4px;"><h3 style="margin-top: 0; color: #1E6BFF;">Message:</h3><p style="white-space: pre-wrap; word-wrap: break-word;">${feedback.message}</p></div></div></div>`,
      };

      await transporter.sendMail(mailOptions);
      console.log(`✅ Email sent for feedback ${feedback.id}`);
    } catch (error) {
      console.error(`❌ Error:`, error);
    }
  });
```

### Phase 7: Add Environment Variables (1 minute)

- [ ] In Cloud Functions, find `sendFeedbackToEmail` function
- [ ] Click on it to edit
- [ ] Go to **Runtime Settings** tab
- [ ] Click **Add Variable** or **Set Environment Variables**
- [ ] **Name:** `SENDGRID_API_KEY`
- [ ] **Value:** Paste your SendGrid API key (starting with `SG.`)
- [ ] Click **Save**
- [ ] Click **Deploy**

---

## 🧪 Testing Phase

### Test 1: Manual Email Send

- [ ] Go to **Firestore Database** → **feedback** collection
- [ ] Add new document
- [ ] Fill all fields (same as Phase 4)
- [ ] Click **Save**
- [ ] **Wait 30 seconds**
- [ ] Check your email inbox (`atharvagiramkar4@gmail.com`)
- [ ] ✅ You should have received the test email

### Test 2: App Testing

- [ ] Run the Flutter app: `flutter run`
- [ ] Navigate to **Profile Page**
- [ ] Click **Send Feedback** button
- [ ] Fill the form:
  - Subject: `App Test`
  - Message: `Testing from the app`
- [ ] Click **Send Feedback**
- [ ] **Wait 30 seconds**
- [ ] Check your email
- [ ] ✅ You should receive the email

### Test 3: Check Logs

- [ ] Firebase Console → **Cloud Functions** → `sendFeedbackToEmail`
- [ ] Click **Logs** tab
- [ ] Look for green checkmarks ✅
- [ ] Should show: `✅ Email sent for feedback [ID]`

---

## ✅ Completion Checklist

- [ ] SendGrid account created and API key saved
- [ ] Firebase Extension installed and configured
- [ ] Firestore collection created
- [ ] Security rules published
- [ ] Cloud Function deployed
- [ ] Environment variables set
- [ ] Manual email test sent successfully ✅
- [ ] App feedback test sent successfully ✅
- [ ] Logs showing successful delivery ✅

---

## 🎉 You're Done!

Your feedback system is now live! Users can:
1. Go to Profile page
2. Click "Send Feedback"
3. Fill out the form
4. Submit
5. ✅ Feedback email arrives in your inbox

---

## 🆘 Quick Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| Extension won't install | Clear cache, try incognito mode, refresh page |
| Email not arriving | Check spam folder, verify SendGrid sender email, check logs |
| Green key icon in Firebase | This means the extension is active ✅ |
| Function shows error | Check SENDGRID_API_KEY environment variable is set |
| Firestore shows permission error | Publish the security rules again |

---

## 📞 Support Resources

- **Firebase Docs:** https://firebase.google.com/docs/extensions
- **SendGrid Docs:** https://docs.sendgrid.com
- **Cloud Functions:** https://firebase.google.com/docs/functions
- **Developer Email:** atharvagiramkar4@gmail.com
