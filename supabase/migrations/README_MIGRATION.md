# Database Migrations Guide

## Overview
This directory contains SQL migration files for the Sentimo database schema changes.

## Migration Files

1. `001_create_journal_entries.sql` - Initial journal entries table with RLS
2. `002_add_sentiment_details.sql` - Add sentiment score and tags
3. `003_add_is_favorite_column.sql` - Add favorite marking feature
4. `004_create_user_streaks_table.sql` - Create streak tracking table
5. `005_create_quick_checkins_table.sql` - Create quick mood check-in table
6. `006_add_search_filter_indexes.sql` - Add full-text search and filter indexes

## How to Run Migrations

### Option 1: Using Supabase Dashboard (Recommended for Development)

1. Go to your Supabase project dashboard: https://app.supabase.com/project/wdcwjnshzocibvwrbuok
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy and paste the content of the migration file (e.g., `003_add_is_favorite_column.sql`)
5. Click **Run** to execute the migration
6. Verify the changes in the **Table Editor**

### Option 2: Using Supabase CLI

If you have Supabase CLI installed:

```bash
# Link your project (first time only)
supabase link --project-ref wdcwjnshzocibvwrbuok

# Run all pending migrations
supabase db push

# Or run a specific migration
supabase db execute --file supabase/migrations/003_add_is_favorite_column.sql
```

### Option 3: Using psql (Direct Database Connection)

If you have PostgreSQL client installed:

```bash
# Get your database connection string from Supabase dashboard
# Settings > Database > Connection string (Direct connection)

psql "postgresql://postgres:[YOUR-PASSWORD]@db.wdcwjnshzocibvwrbuok.supabase.co:5432/postgres" -f supabase/migrations/003_add_is_favorite_column.sql
```

## Verification

### After running migration 003 (is_favorite):

```sql
-- Check if column exists
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'journal_entries' 
AND column_name = 'is_favorite';

-- Check if indexes were created
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'journal_entries' 
AND indexname LIKE '%favorite%';

-- Test the column
SELECT id, content, is_favorite 
FROM journal_entries 
LIMIT 5;
```

### After running migration 004 (user_streaks):

Use the comprehensive verification script:
```bash
# Run the verification script in Supabase SQL Editor
# File: supabase/verify_user_streaks.sql
```

Or quick check:
```sql
-- Check if table exists
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'user_streaks';

-- Check RLS is enabled
SELECT rowsecurity FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'user_streaks';

-- Check policies exist
SELECT policyname FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'user_streaks';
```

### After running migration 005 (quick_checkins):

Use the comprehensive verification script:
```bash
# Run the verification script in Supabase SQL Editor
# File: supabase/verify_quick_checkins.sql
```

Or quick check:
```sql
-- Check if table exists
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'quick_checkins';

-- Test sentiment function
SELECT public.get_checkin_sentiment('emoji', '😊') as sentiment;

-- Check view exists
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'quick_checkins_with_sentiment';
```

### After running migration 006 (search indexes):

Use the comprehensive verification script:
```bash
# Run the verification script in Supabase SQL Editor
# File: supabase/verify_search_indexes.sql
```

Or quick check:
```sql
-- Check if indexes exist
SELECT indexname FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename = 'journal_entries'
AND indexname LIKE 'idx_journal_entries_%search%';

-- Test search function
SELECT public.search_journal_entries(
    auth.uid(), 'test', NULL, NULL, NULL, 5
);

-- Check materialized view
SELECT matviewname FROM pg_matviews 
WHERE schemaname = 'public' 
AND matviewname = 'journal_entries_search_cache';
```

## Rollback (If Needed)

### Rollback migration 003 (is_favorite):

```sql
-- Remove indexes
DROP INDEX IF EXISTS idx_journal_entries_favorites;
DROP INDEX IF EXISTS idx_journal_entries_favorites_sentiment;

-- Remove column
ALTER TABLE public.journal_entries DROP COLUMN IF EXISTS is_favorite;
```

### Rollback migration 004 (user_streaks):

```sql
-- Remove trigger from auth.users
DROP TRIGGER IF EXISTS initialize_streak_on_signup ON auth.users;

-- Remove trigger from user_streaks
DROP TRIGGER IF EXISTS set_user_streaks_updated_at ON public.user_streaks;

-- Remove functions
DROP FUNCTION IF EXISTS public.initialize_user_streak();
DROP FUNCTION IF EXISTS public.handle_user_streaks_updated_at();

-- Remove table (this will also remove policies and indexes)
DROP TABLE IF EXISTS public.user_streaks CASCADE;
```

### Rollback migration 005 (quick_checkins):

```sql
-- Remove view
DROP VIEW IF EXISTS public.quick_checkins_with_sentiment;

-- Remove trigger
DROP TRIGGER IF EXISTS validate_checkin_data ON public.quick_checkins;

-- Remove functions
DROP FUNCTION IF EXISTS public.validate_quick_checkin();
DROP FUNCTION IF EXISTS public.get_checkin_sentiment(VARCHAR, VARCHAR);

-- Remove table (this will also remove policies and indexes)
DROP TABLE IF EXISTS public.quick_checkins CASCADE;
```

### Rollback migration 006 (search indexes):

```sql
-- Remove materialized view and its indexes
DROP MATERIALIZED VIEW IF EXISTS public.journal_entries_search_cache CASCADE;

-- Remove functions
DROP FUNCTION IF EXISTS public.search_journal_entries;
DROP FUNCTION IF EXISTS public.count_filtered_entries;
DROP FUNCTION IF EXISTS public.refresh_search_cache;
DROP FUNCTION IF EXISTS public.trigger_refresh_search_cache;

-- Remove indexes
DROP INDEX IF EXISTS public.idx_journal_entries_content_search;
DROP INDEX IF EXISTS public.idx_journal_entries_sentiment_filter;
DROP INDEX IF EXISTS public.idx_journal_entries_date_range;
DROP INDEX IF EXISTS public.idx_journal_entries_sentiment_date;
```

## Migration Status

- [x] 001_create_journal_entries.sql - Applied
- [x] 002_add_sentiment_details.sql - Applied
- [x] 003_add_is_favorite_column.sql - Applied
- [ ] 004_create_user_streaks_table.sql - **Ready to apply**
- [ ] 005_create_quick_checkins_table.sql - **Ready to apply**
- [ ] 006_add_search_filter_indexes.sql - **Ready to apply**

## Notes

- Always backup your database before running migrations in production
- Test migrations in a development environment first
- Migrations are designed to be idempotent (safe to run multiple times)
- All migrations include `IF NOT EXISTS` or `IF EXISTS` clauses for safety
