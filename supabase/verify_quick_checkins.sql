-- Verification script for migration 005_create_quick_checkins_table
-- Run this in Supabase SQL Editor after applying the migration

-- 1. Check if quick_checkins table exists
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name = 'quick_checkins';

-- Expected result: table_name: quick_checkins, table_type: BASE TABLE

-- 2. Check all columns and their properties
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name = 'quick_checkins'
ORDER BY ordinal_position;

-- Expected columns:
-- id (uuid, default gen_random_uuid(), NOT NULL)
-- user_id (uuid, NOT NULL)
-- type (character varying(10), NOT NULL)
-- value (character varying(10), NOT NULL)
-- note (character varying(100), nullable)
-- created_at (timestamp with time zone, default NOW(), NOT NULL)

-- 3. Check constraints
SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public'
AND rel.relname = 'quick_checkins'
ORDER BY con.contype, con.conname;

-- Expected constraints:
-- PRIMARY KEY on id
-- FOREIGN KEY to auth.users(id) with ON DELETE CASCADE
-- CHECK constraint on type IN ('emoji', 'rating')

-- 4. Check indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'quick_checkins'
ORDER BY indexname;

-- Expected indexes:
-- quick_checkins_pkey (PRIMARY KEY)
-- idx_quick_checkins_user_id
-- idx_quick_checkins_created_at
-- idx_quick_checkins_user_date

-- 5. Check RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'quick_checkins';

-- Expected: rowsecurity = true

-- 6. Check RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'quick_checkins'
ORDER BY policyname;

-- Expected 4 policies:
-- "Users can view their own check-ins" (SELECT)
-- "Users can insert their own check-ins" (INSERT)
-- "Users can update their own check-ins" (UPDATE)
-- "Users can delete their own check-ins" (DELETE)

-- 7. Check triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'public'
AND event_object_table = 'quick_checkins'
ORDER BY trigger_name;

-- Expected trigger:
-- validate_checkin_data (BEFORE INSERT OR UPDATE)

-- 8. Check if validation function exists
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'validate_quick_checkin';

-- Expected: validate_quick_checkin (FUNCTION)

-- 9. Check if sentiment function exists
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'get_checkin_sentiment';

-- Expected: get_checkin_sentiment (FUNCTION)

-- 10. Check if view exists
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name = 'quick_checkins_with_sentiment';

-- Expected: quick_checkins_with_sentiment (VIEW)

-- 11. Test sentiment mapping function
SELECT 
    public.get_checkin_sentiment('emoji', '😄') as happy_emoji,
    public.get_checkin_sentiment('emoji', '😐') as neutral_emoji,
    public.get_checkin_sentiment('emoji', '😢') as sad_emoji,
    public.get_checkin_sentiment('rating', '5') as high_rating,
    public.get_checkin_sentiment('rating', '3') as mid_rating,
    public.get_checkin_sentiment('rating', '1') as low_rating;

-- Expected results:
-- happy_emoji: positive
-- neutral_emoji: neutral
-- sad_emoji: negative
-- high_rating: positive
-- mid_rating: neutral
-- low_rating: negative

-- 12. Test inserting valid emoji check-in (if authenticated)
-- Uncomment to test:
/*
INSERT INTO public.quick_checkins (user_id, type, value, note)
VALUES (auth.uid(), 'emoji', '😊', 'Feeling good today!');
*/

-- 13. Test inserting valid rating check-in (if authenticated)
-- Uncomment to test:
/*
INSERT INTO public.quick_checkins (user_id, type, value, note)
VALUES (auth.uid(), 'rating', '4', 'Pretty good day');
*/

-- 14. Test validation - invalid emoji (should fail)
-- Uncomment to test:
/*
INSERT INTO public.quick_checkins (user_id, type, value)
VALUES (auth.uid(), 'emoji', '🎉');
-- Expected: ERROR - Invalid emoji value
*/

-- 15. Test validation - invalid rating (should fail)
-- Uncomment to test:
/*
INSERT INTO public.quick_checkins (user_id, type, value)
VALUES (auth.uid(), 'rating', '6');
-- Expected: ERROR - Invalid rating value
*/

-- 16. Test validation - note too long (should fail)
-- Uncomment to test:
/*
INSERT INTO public.quick_checkins (user_id, type, value, note)
VALUES (auth.uid(), 'emoji', '😊', REPEAT('a', 101));
-- Expected: ERROR - Note exceeds maximum length
*/

-- 17. Test querying your check-ins
-- Uncomment to test:
/*
SELECT 
    id,
    type,
    value,
    note,
    created_at
FROM public.quick_checkins
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 10;
*/

-- 18. Test the view with sentiment labels
-- Uncomment to test:
/*
SELECT 
    type,
    value,
    sentiment_label,
    note,
    created_at
FROM public.quick_checkins_with_sentiment
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 10;
*/

-- If all queries above return expected results, migration is successful! ✓
