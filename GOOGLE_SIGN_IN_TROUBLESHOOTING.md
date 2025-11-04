# Google Sign In Troubleshooting Guide

## ❌ Error: "Unacceptable audience in id_token"

```
AuthApiException(message: Unacceptable audience in id_token: 
[574327579297-8oaneej2dqutahok85od8rt55mmkec43.apps.googleusercontent.com], 
statusCode: 400)
```

### **Penyebab:**
Supabase menolak ID token karena Client ID (audience) tidak terdaftar sebagai authorized client.

---

## 🛠️ **Solusi Lengkap**

### **SOLUTION 1: Tambahkan Client ID ke Supabase (RECOMMENDED)**

#### Step 1: Buka Supabase Dashboard
1. Go to: https://supabase.com/dashboard
2. Select your project: **Sentimo**

#### Step 2: Configure Google Provider
1. Navigate to: **Authentication** → **Providers** → **Google**
2. Scroll down ke bagian **"Authorized Client IDs"**

#### Step 3: Tambahkan Client IDs
Tambahkan kedua Client IDs ini (satu per line):
```
574327579297-8oaneej2dqutahok85od8rt55mmkec43.apps.googleusercontent.com
574327579297-oore65353egnohc8npivlkhklpc0cpkv.apps.googleusercontent.com
```

Screenshot lokasi:
```
┌─────────────────────────────────────────────┐
│ Google Provider Configuration                │
├─────────────────────────────────────────────┤
│ Client ID (for OAuth):                       │
│ [your-oauth-client-id]                       │
│                                               │
│ Client Secret (for OAuth):                   │
│ [your-oauth-client-secret]                   │
│                                               │
│ ✅ Authorized Client IDs (for signInWithIdToken): │
│ ┌───────────────────────────────────────┐   │
│ │ 574327579297-8oaneej2d...             │   │
│ │ 574327579297-oore65353...             │   │
│ └───────────────────────────────────────┘   │
│                                               │
│ [Save] [Cancel]                              │
└─────────────────────────────────────────────┘
```

#### Step 4: Save & Test
1. Click **"Save"**
2. Wait 1-2 minutes for changes to propagate
3. Run app and test Google Sign In again

---

### **SOLUTION 2: Buat Android Client ID (Jika Solution 1 Gagal)**

Jika Solution 1 tidak berhasil, mungkin perlu Android-specific Client ID.

#### Step 1: Dapatkan SHA-1 Fingerprint

**For Debug Build:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**For Release Build:**
```bash
keytool -list -v -keystore "path\to\your\release.keystore" -alias your-key-alias
```

Copy SHA-1 yang muncul, contoh:
```
Certificate fingerprint:
SHA-1: A1:B2:C3:D4:E5:F6:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

#### Step 2: Buat Android OAuth Client ID

1. Go to: https://console.cloud.google.com/apis/credentials
2. Select project: **Sentimo** (atau nama project Anda)
3. Click **"+ CREATE CREDENTIALS"**
4. Select **"OAuth client ID"**

5. Fill in the form:
   - **Application type:** Android
   - **Name:** Sentimo Android
   - **Package name:** `com.sentimoapp.dev`
   - **SHA-1 certificate fingerprint:** (paste SHA-1 dari Step 1)

6. Click **"CREATE"**
7. Copy **Client ID** yang dihasilkan

#### Step 3: Update Supabase

Tambahkan Android Client ID baru ke Supabase:
1. Supabase Dashboard → Authentication → Providers → Google
2. Section **"Authorized Client IDs"**
3. Tambahkan Android Client ID yang baru dibuat
4. Save

#### Step 4: Test Again
Run app dan test Google Sign In.

---

### **SOLUTION 3: Verify Google Cloud Configuration**

Pastikan konfigurasi di Google Cloud Console sudah benar:

#### 1. OAuth Consent Screen
```
APIs & Services → OAuth consent screen

✅ App name: Sentimo
✅ User support email: [your-email]
✅ Developer contact: [your-email]
✅ Scopes:
   - .../auth/userinfo.email
   - .../auth/userinfo.profile
   - openid
✅ Test users: (add your test email addresses)
```

#### 2. OAuth Client IDs
```
APIs & Services → Credentials

Should have:
✅ Web client (for Supabase OAuth)
✅ iOS client (optional, for iOS)
✅ Android client (for native Android sign-in)
```

#### 3. Authorized redirect URIs
In Web Client settings:
```
Authorized redirect URIs:
✅ https://[your-project-ref].supabase.co/auth/v1/callback
```

---

## 🔍 **Debugging Steps**

### Check Logs
With the new logging, you'll see:
```bash
🔵 [AuthRepository] Starting Google Sign In...
🔵 [LoginPage] Google Sign In button pressed
✅ [AuthRepository] ID Token obtained
🔑 [AuthRepository] Token details:
   - Email: user@gmail.com
   - ID: 123456789
   - idToken length: 847 characters
   - accessToken: present
🔵 [AuthRepository] Sending to Supabase signInWithIdToken...
```

If error occurs:
```bash
❌ [AuthRepository] Google Sign In error: Unacceptable audience in id_token: [...]
```

The audience (Client ID) in the error message is the one that needs to be added to Supabase.

---

## ✅ **Verification Checklist**

Before testing, verify:

- [ ] SHA-1 fingerprint registered in Google Cloud Console
- [ ] Package name matches: `com.sentimoapp.dev`
- [ ] Client IDs added to Supabase **"Authorized Client IDs"**
- [ ] Google Provider is **enabled** in Supabase
- [ ] OAuth Consent Screen configured with correct scopes
- [ ] Test user email added (if app is in testing mode)
- [ ] Wait 1-2 minutes after saving Supabase config

---

## 📚 **References**

- [Supabase Google Sign In Docs](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google Sign In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Google OAuth 2.0 Setup](https://developers.google.com/identity/protocols/oauth2)

---

## 💡 **Quick Fix Summary**

**Most Common Solution:**
1. Copy Client ID from error message
2. Go to Supabase → Authentication → Providers → Google
3. Add Client ID to **"Authorized Client IDs"**
4. Save and wait 1-2 minutes
5. Test again

**Error Message Example:**
```
Unacceptable audience in id_token: [THIS-IS-THE-CLIENT-ID-TO-ADD]
```

---

## 🚀 **Expected Success Flow**

When working correctly:
```bash
1. User taps "Continue with Google"
2. Google account picker appears
3. User selects account
4. Permission dialog shows (email + profile)
5. User taps "Allow"
6. ✅ Token exchange with Supabase succeeds
7. ✅ User authenticated
8. ✅ Redirect to HomePage
9. ✅ Journal entries load
```

---

**Last Updated:** 2025-11-04
**App Version:** 1.0.0+1
**Google Sign In Version:** ^7.2.0
