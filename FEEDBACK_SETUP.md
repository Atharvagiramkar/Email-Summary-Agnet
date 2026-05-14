# Feedback Feature Setup Guide - Complete Firebase Extensions Setup

This guide provides **detailed click-by-click instructions** to set up automatic email delivery for user feedback using Firebase Extensions.

## 📋 Overview

The feedback feature allows users to send queries and suggestions through the profile page. Using Firebase Extensions, feedback is automatically sent to your email inbox.

**Current Configuration:**
- Developer Email: `atharvagiramkar4@gmail.com` (configured in `feedback_service.dart`)
- Data Storage: Firestore collection `feedback`
- Email Provider: SendGrid (recommended) or Gmail
- Pricing: Free tier available

---

## 🚀 Step-by-Step Setup Guide (Click-by-Click)

### **STEP 1: Access Firebase Console**

1. Open your browser and go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account (if not already signed in)
3. Navigate to your **Email Summary Agent** project
4. **Left Sidebar** → Click on **"Extensions"** (you may see a puzzle icon 🧩)
   - If this is your first time, you might see a "Get started with Extensions" message

---

### **STEP 2: Install the Email Extension**

**Option A: Using SendGrid (Recommended)**

1. In Extensions page, click **"Explore Extensions"** or **"Install an Extension"** button
2. Search bar appears at the top → Type: **"sendgrid"** or **"Trigger Email"**
3. You'll see several options. Click on **"Trigger Email with SendGrid"** (by Google)
   - It shows: "Sends an email using SendGrid when a Firestore document is created or updated"
4. Click the extension card to open details
5. Click the blue **"Install in Console"** button
6. A dialog appears asking you to select your project
   - Select your **Email Summary Agent** project from dropdown (if not already selected)
   - Click **"Install"**

---

### **STEP 3: Grant Permissions**

After clicking Install, Firebase will ask for permissions:

1. A new dialog appears: **"Grant permissions to this extension"**
2. Review the permissions (cloud functions, Firestore, logging)
3. Click **"Grant Permissions"** (you may need to log in again with your Google account)
4. Wait 2-3 minutes for the extension to install
   - You'll see a progress indicator
   - Installation complete when you see a checkmark ✅

---

### **STEP 4: Configure Extension Parameters**

Once installation completes, you'll see the configuration screen. Fill in these fields:

#### **4.1 - Cloud Tasks Queue Region**
- **Label:** Cloud Tasks Queue Region
- **Dropdown:** Select the region closest to your location
- **Example:** `us-central1` (or your preferred region)
- Click the region you want

#### **4.2 - SMTP Connection URI (SendGrid)**
- **Label:** SMTP Connection URI
- **Format:** `smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:587`
- **How to get API Key:**
  1. Go to [SendGrid Dashboard](https://app.sendgrid.com) (create free account if needed)
  2. Left menu → **"Settings"** → **"API Keys"**
  3. Click **"Create API Key"** button
  4. **Name:** `Email Summary App Feedback`
  5. Click **"Create & Edit"**
  6. Copy the API key (it starts with `SG.`)
  7. Replace `YOUR_SENDGRID_API_KEY` in the URI with your copied key
- **Example:** `smtps://apikey:SG.abc123def456@smtp.sendgrid.net:587`

#### **4.3 - Sender Email**
- **Label:** Email address to send from
- **Value:** `noreply@emailsummaryagent.com` or your SendGrid verified sender
- **Important:** Must be verified in SendGrid account
  - Go to SendGrid → **"Settings"** → **"Sender Authentication"**
  - Verify your domain or single sender email

#### **4.4 - Email Template Path**
- **Label:** Path to template in Firestore
- **Value:** Leave empty for now (we'll create custom logic)

#### **4.5 - Document Path Pattern**
- **Label:** Firestore document path pattern
- **Value:** `feedback/{uid}`
- This means: trigger on new documents in `feedback` collection

#### **4.6 - Email Field**
- **Label:** Fields containing recipient email(s)
- **Value:** `to`
- We'll handle this differently - see Step 5

---

### **STEP 5: Update Extension Configuration (Important)**

The extension needs special configuration for our feedback system.

1. After completing Step 4, you'll be taken to a "Review & Install" page
2. Scroll down to see the full configuration
3. Click **"Install Extension"** button at the bottom
4. Wait for confirmation (you'll see a success message)

---

### **STEP 6: Create Cloud Function for Feedback Processing**

We need a custom Cloud Function to properly format and send feedback emails. Let me create this:

#### **6.1 - Access Cloud Functions**

1. Firebase Console → Left Sidebar → **"Functions"**
2. If this is your first time, click **"Get Started"** → **"Next"** → **"Next"**
   - Select your region (same as Step 4.1)
   - Click **"Create"**

#### **6.2 - Create New Function**

1. Click **"Create Function"** button
2. Configure the function:
   - **Function Name:** `sendFeedbackToEmail`
   - **Region:** Select same region as Step 4.1
   - **Trigger Type:** Cloud Firestore
   - **Event Type:** On create
   - **Database:** (default)
   - **Document path:** `feedback/{docId}`
   - **Runtime:** Node.js 18 (or latest)
3. Click **"Create and Deploy"**

---

### **STEP 7: Add Function Code**

1. After deployment, you'll see code editor
2. Copy this code into `index.js`:

```javascript
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
const DEVELOPER_EMAIL = "atharvagiramkar4@gmail.com";

// Setup SendGrid transporter
const transporter = nodemailer.createTransport({
  host: "smtp.sendgrid.net",
  port: 587,
  secure: false,
  auth: {
    user: "apikey",
    pass: SENDGRID_API_KEY,
  },
});

exports.sendFeedbackToEmail = functions.firestore
  .document("feedback/{docId}")
  .onCreate(async (snap, context) => {
    const feedback = snap.data();

    try {
      const mailOptions = {
        from: "noreply@emailsummaryagent.com",
        to: DEVELOPER_EMAIL,
        replyTo: feedback.userEmail,
        subject: `[User Feedback] ${feedback.subject}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px;">
            <div style="background: linear-gradient(135deg, #1E6BFF 0%, #00D4AA 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0;">
              <h1 style="margin: 0;">📬 New User Feedback</h1>
            </div>
            <div style="background: #f5f5f5; padding: 20px; border-radius: 0 0 8px 8px;">
              <table style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>From:</strong></td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${feedback.name}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>Email:</strong></td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">
                    <a href="mailto:${feedback.userEmail}">${feedback.userEmail}</a>
                  </td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>Subject:</strong></td>
                  <td style="padding: 10px 0; border-bottom: 1px solid #ddd;"><strong>${feedback.subject}</strong></td>
                </tr>
                <tr>
                  <td style="padding: 10px 0;"><strong>Date:</strong></td>
                  <td style="padding: 10px 0;">${new Date(feedback.createdAt.toDate()).toLocaleString()}</td>
                </tr>
              </table>
              <div style="margin-top: 20px; padding: 15px; background: white; border-left: 4px solid #1E6BFF; border-radius: 4px;">
                <h3 style="margin-top: 0; color: #1E6BFF;">Message:</h3>
                <p style="white-space: pre-wrap; word-wrap: break-word;">${feedback.message}</p>
              </div>
              <div style="margin-top: 20px; padding: 10px; background: #e8f4ff; border-radius: 4px; font-size: 12px; color: #666;">
                <strong>Feedback ID:</strong> ${feedback.id}
              </div>
            </div>
          </div>
        `,
      };

      await transporter.sendMail(mailOptions);
      console.log(`✅ Feedback email sent for ID: ${feedback.id}`);
    } catch (error) {
      console.error(`❌ Error sending feedback email:`, error);
    }
  });
```

3. Click **"Deploy"** button

---

### **STEP 8: Add Environment Variables**

1. In Cloud Functions page, find your `sendFeedbackToEmail` function
2. Click on the function name to edit it
3. Go to **"Runtime Settings"** tab
4. Click **"Set Runtime Environment Variables"** or **"Add Variable"**
5. Add these variables:
   - **Name:** `SENDGRID_API_KEY`
   - **Value:** `SG.your_actual_sendgrid_key` (paste your SendGrid API key)
6. Click **"Deploy"**

---

### **STEP 9: Update Firestore Security Rules**

1. Firebase Console → **"Firestore Database"** → **"Rules"** tab
2. Replace the content with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Feedback collection security rules
    match /feedback/{document=**} {
      // Users can only read their own feedback
      allow read: if request.auth.uid == resource.data.uid;
      
      // Authenticated users can create feedback
      allow create: if request.auth.uid != null && 
                       request.auth.uid == request.resource.data.uid;
      
      // Users cannot update feedback
      allow update: if false;
      
      // Users can delete their own feedback
      allow delete: if request.auth.uid == resource.data.uid;
    }
    
    // Other collections (existing rules)
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **"Publish"** button

---

### **STEP 10: Setup Firestore Collection Rules**

1. Go to **"Firestore Database"** → **"Data"** tab
2. Click **"+ Create Collection"**
3. **Collection ID:** `feedback`
4. Click **"Next"**
5. Click **"Auto ID"** (let Firestore generate IDs)
6. Add a sample document with these fields:
   - `id`: `test-feedback-1`
   - `uid`: `test-user`
   - `userEmail`: `test@example.com`
   - `name`: `Test User`
   - `subject`: `Test Feedback`
   - `message`: `This is a test message`
   - `createdAt`: Current timestamp
   - `status`: `sent`
7. Click **"Save"**

---

## ✅ Testing the Setup

### **Test 1: Manual Firestore Test**

1. Firestore → **"Collection: feedback"**
2. Click **"+ Add Document"**
3. Fill fields:
   - Document ID: `test-1`
   - `id`: `test-1`
   - `uid`: `your-test-uid`
   - `userEmail`: `your-email@gmail.com`
   - `name`: `Test User`
   - `subject`: `Test: Setup Complete`
   - `message`: `Testing feedback setup`
   - `createdAt`: (timestamp)
   - `status`: `sent`
4. Click **"Save"**
5. Check your email inbox (wait 30 seconds)
6. You should receive the feedback email ✅

### **Test 2: App Testing**

1. Run the Flutter app
2. Go to **Profile Page**
3. Click **"Send Feedback"** button
4. Fill the form:
   - **Subject:** `Test from App`
   - **Message:** `This is a test from the app`
5. Click **"Send Feedback"**
6. Check your email inbox (wait 30 seconds)
7. Verify you receive the email ✅

---

## 🔍 Monitoring & Troubleshooting

### **Check Email Delivery**

1. Firebase Console → **"Functions"** → `sendFeedbackToEmail`
2. Click on the function
3. Go to **"Logs"** tab
4. Look for green checkmarks (✅) or errors (❌)

### **Common Issues & Solutions**

| Issue | Solution |
|-------|----------|
| **Email not received** | 1. Check SendGrid API key is correct<br>2. Verify sender email in SendGrid dashboard<br>3. Check spam folder<br>4. Review Function logs for errors |
| **Function won't deploy** | 1. Check for code syntax errors<br>2. Ensure all dependencies are correct<br>3. Use Node.js 18 runtime or latest |
| **Permission errors** | 1. Review Firestore rules<br>2. Ensure user is authenticated<br>3. Check user UID matches in document |
| **Function timeout** | 1. Increase timeout: Cloud Functions → Edit → Runtime → Timeout (set to 60 sec)<br>2. Check SendGrid API is responsive |

---

## 🎯 Customization Options

### **Change Developer Email**

1. Open `lib/services/feedback_service.dart`
2. Line 11: Update `developerEmail`
3. Also update `DEVELOPER_EMAIL` in Cloud Function code

### **Change Email Design**

1. Cloud Functions → `sendFeedbackToEmail` → Edit
2. Modify the HTML in `html:` field
3. Deploy changes

### **Add Attachment Support**

Requires advanced setup - contact support if needed

---

## 📊 Pricing Information

**Firebase Extensions:**
- Free tier: Up to 100 emails/month
- Paid: $0.10 per email after 100/month

**SendGrid:**
- Free tier: 100 emails/day (30,000/month)
- More than enough for most apps

**Total Cost:** ~$0 to $5/month depending on volume

---

## ✨ Features Enabled

✅ Automatic email delivery to developer  
✅ User identity tracking  
✅ Beautiful formatted emails  
✅ Reply functionality (users can reply to emails)  
✅ Timestamp recording  
✅ Secure data storage  
✅ Real-time notifications  
✅ Error logging and monitoring  

---

## 🎓 Next Steps

1. ✅ Complete all 10 steps above
2. ✅ Test with manual Firestore entry
3. ✅ Test with app form submission
4. ✅ Monitor logs for 24 hours
5. ✅ Set up email forwarding if needed

---

## 📞 Support & Questions

If you encounter issues:
1. Check Firebase Console → Functions → Logs
2. Verify all environment variables are set
3. Ensure user is authenticated in app
4. Test with Firestore manual entry first

**Developer Email:** atharvagiramkar4@gmail.com  
**API Key Status:** Configure in Cloud Functions Runtime Settings
