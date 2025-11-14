-- Verification script for migration 004_create_user_streaks_table
-- Run this in Supabase SQL Editor after applying the migration

-- 1. Check if user_streaks table exists
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name = 'user_streaks';

-- Expected result: table_name: user_streaks, table_type: BASE TABLE

-- 2. Check all columns and their properties
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name = 'user_streaks'
ORDER BY ordinal_position;

-- Expected columns:
-- user_id (uuid, NOT NULL)
-- current_streak (integer, default 0, NOT NULL)
-- longest_streak (integer, default 0, NOT NULL)
-- last_entry_date (date, nullable)
-- achieved_milestones (ARRAY, default '{}', NOT NULL)
-- created_at (timestamp with time zone, default NOW(), NOT NULL)
-- updated_at (timestamp with time zone, default NOW(), NOT NULL)

-- 3. Check constraints
SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public'
AND rel.relname = 'user_streaks'
ORDER BY con.contype, con.conname;

-- Expected constraints:
-- PRIMARY KEY on user_id
-- FOREIGN KEY to auth.users(id) with ON DELETE CASCADE
-- CHECK constraints on current_streak >= 0 and longest_streak >= 0

-- 4. Check indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'user_streaks'
ORDER BY indexname;

-- Expected indexes:
-- user_streaks_pkey (PRIMARY KEY)
-- idx_user_streaks_user_id
-- idx_user_streaks_current_streak (partial index WHERE current_streak > 0)

-- 5. Check RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'user_streaks';

-- Expected: rowsecurity = true

-- 6. Check RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'user_streaks'
ORDER BY policyname;

-- Expected 4 policies:
-- "Users can view their own streak data" (SELECT)
-- "Users can insert their own streak data" (INSERT)
-- "Users can update their own streak data" (UPDATE)
-- "Users can delete their own streak data" (DELETE)

-- 7. Check triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'public'
AND event_object_table = 'user_streaks'
ORDER BY trigger_name;

-- Expected triggers:
-- set_user_streaks_updated_at (BEFORE UPDATE)

-- 8. Check if auto-initialization trigger exists on auth.users
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
AND event_object_table = 'users'
AND trigger_name = 'initialize_streak_on_signup';

-- Expected: initialize_streak_on_signup (AFTER INSERT)

-- 9. Check table comments
SELECT 
    obj_description('public.user_streaks'::regclass) as table_comment;

-- Expected: "Tracks user journaling streaks and milestone achievements"

-- 10. Check column comments
SELECT 
    cols.column_name,
    pg_catalog.col_description('public.user_streaks'::regclass::oid, cols.ordinal_position) as column_comment
FROM information_schema.columns cols
WHERE cols.table_schema = 'public'
AND cols.table_name = 'user_streaks'
ORDER BY cols.ordinal_position;

-- 11. Test inserting a sample streak record (if you're authenticated)
-- Uncomment to test:
/*
INSERT INTO public.user_streaks (user_id, current_streak, longest_streak, last_entry_date, achieved_milestones)
VALUES (auth.uid(), 5, 10, CURRENT_DATE, ARRAY[7])
ON CONFLICT (user_id) DO UPDATE
SET current_streak = 5, longest_streak = 10, last_entry_date = CURRENT_DATE;
*/

-- 12. Test querying your streak data
-- Uncomment to test:
/*
SELECT 
    user_id,
    current_streak,
    longest_streak,
    last_entry_date,
    achieved_milestones,
    created_at,
    updated_at
FROM public.user_streaks
WHERE user_id = auth.uid();
*/

-- 13. Test the updated_at trigger
-- Uncomment to test (after inserting data):
/*
UPDATE public.user_streaks
SET current_streak = current_streak + 1
WHERE user_id = auth.uid();

-- Check if updated_at changed
SELECT updated_at FROM public.user_streaks WHERE user_id = auth.uid();
*/

-- If all queries above return expected results, migration is successful! ✓
