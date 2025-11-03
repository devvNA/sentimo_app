# Sentimo Setup Guide

## Prerequisites Checklist

- ✅ Flutter installed (SDK 3.8.1+)
- ✅ Supabase project created
- ✅ Google Gemini API key obtained
- ✅ `.env` file configured with API keys

---

## Step 1: Run Supabase Database Migration

### Option A: Using Supabase Dashboard (Recommended)

1. **Open Supabase Dashboard**
   - Go to https://app.supabase.com
   - Select your project: `wdcwjnshzocibvwrbuok`

2. **Navigate to SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

3. **Run the Migration**
   - Open file: `supabase/migrations/001_create_journal_entries.sql`
   - Copy the entire contents
   - Paste into the SQL editor
   - Click **"Run"** button

4. **Verify Success**
   - You should see: "Success. No rows returned"
   - Check the Tables section to confirm `journal_entries` table exists

### Option B: Using Supabase CLI

```bash
# Install Supabase CLI (if not installed)
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref wdcwjnshzocibvwrbuok

# Run migrations
supabase db push
```

### Verify Database Setup

Run this SQL query in the SQL Editor to verify:

```sql
-- Check if table exists
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'journal_entries';

-- Check RLS policies
SELECT * FROM pg_policies 
WHERE tablename = 'journal_entries';
```

You should see:
- 1 table: `journal_entries`
- 4 RLS policies: SELECT, INSERT, UPDATE, DELETE

---

## Step 2: Run the Flutter App

### Install Dependencies

```bash
flutter pub get
```

### Run on Device/Emulator

```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

---

## Step 3: Test Complete Flow

### 1. Register New Account

1. Open the app
2. Click "Don't have an account? Sign Up"
3. Enter email: `test@example.com`
4. Enter password: `password123`
5. Click "Sign Up"
6. ✅ Should show success message and auto-login

### 2. Create Journal Entry

1. You should see the Home page (empty state)
2. Click the "New Entry" floating action button
3. Write a journal entry (at least 10 characters)
   - Example: "Today was amazing! I finally completed my project and felt so accomplished. The sun was shining and everything went perfectly."
4. Click "Save Entry"
5. ✅ Should navigate back to Home page
6. ✅ Entry should appear in the list
7. ✅ Sentiment indicator should show "Analyzing..." initially

### 3. View Sentiment Analysis

1. Wait 2-5 seconds for AI analysis
2. Pull down to refresh the list
3. ✅ Sentiment badge should update:
   - **Positive** = Green badge with happy face
   - **Negative** = Red badge with sad face
   - **Neutral** = Blue badge with neutral face
   - **Mixed** = Orange badge with neutral face

### 4. Test Multiple Entries

Create entries with different sentiments:

**Positive Entry:**
```
I'm so grateful for my amazing friends and family. Today was filled with joy, laughter, and beautiful moments. Life is wonderful!
```

**Negative Entry:**
```
Today was really tough. I feel frustrated and overwhelmed with everything. Nothing seems to be going right and I'm exhausted.
```

**Neutral Entry:**
```
Today I went to the grocery store and bought some vegetables. Then I came home and made dinner. It was a regular Tuesday.
```

### 5. Test Logout and Re-login

1. Click logout icon in app bar
2. ✅ Should return to login page
3. Login with same credentials
4. ✅ Should see your previous journal entries

---

## Step 4: Verify Everything Works

### Checklist

- [ ] Registration works
- [ ] Login works
- [ ] Logout works
- [ ] Can create journal entries
- [ ] Entries appear in list
- [ ] Pull-to-refresh works
- [ ] Sentiment analysis completes
- [ ] Sentiment badges display correctly with colors
- [ ] Can navigate to New Entry page
- [ ] Form validation works (minimum 10 characters)
- [ ] Loading states display properly
- [ ] Error messages show when needed

---

## Troubleshooting

### Issue: "User not authenticated"

**Solution:** Make sure you're logged in and the session is active.

```bash
# Check Supabase console logs
# Verify RLS policies are enabled
```

### Issue: Sentiment shows "Analyzing..." forever

**Possible causes:**
1. Gemini API key not configured correctly
2. Network/firewall blocking API calls
3. API quota exceeded

**Solution:**
- Check `.env` file has correct `GEMINI_API_KEY`
- Verify API key is active in Google AI Studio
- Check console logs for errors

### Issue: Cannot create entries

**Solution:**
- Verify database migration ran successfully
- Check RLS policies are configured
- Ensure user is authenticated

### Issue: Flutter build errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## What's Next?

Once everything is working:

1. ✅ Test all features thoroughly
2. ✅ Create multiple journal entries
3. ✅ Verify sentiment analysis accuracy
4. ⚠️ Consider implementing:
   - Entry editing functionality
   - Entry deletion with confirmation
   - Search/filter entries
   - Mood trend visualization
   - Export journal as PDF
   - Dark mode theme

---

## Support

If you encounter issues:

1. Check `flutter doctor` output
2. Verify all dependencies in `pubspec.yaml`
3. Check Supabase project status
4. Verify API keys are correct
5. Review console logs for errors

**Happy journaling! 📝✨**
