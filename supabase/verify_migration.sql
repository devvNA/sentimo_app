-- Verification script for migration 003_add_is_favorite_column
-- Run this in Supabase SQL Editor after applying the migration

-- 1. Check if is_favorite column exists
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name = 'journal_entries' 
AND column_name = 'is_favorite';

-- Expected result:
-- column_name: is_favorite
-- data_type: boolean
-- column_default: false
-- is_nullable: NO

-- 2. Check if indexes were created
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'journal_entries' 
AND indexname LIKE '%favorite%'
ORDER BY indexname;

-- Expected results:
-- idx_journal_entries_favorites
-- idx_journal_entries_favorites_sentiment

-- 3. Check column comment
SELECT 
    col_description('public.journal_entries'::regclass, 
                    (SELECT ordinal_position 
                     FROM information_schema.columns 
                     WHERE table_name = 'journal_entries' 
                     AND column_name = 'is_favorite')) as column_comment;

-- Expected result:
-- "User-marked favorite status for quick access to meaningful entries"

-- 4. Test the column with sample data
SELECT 
    id,
    user_id,
    LEFT(content, 50) as content_preview,
    is_favorite,
    created_at
FROM public.journal_entries 
ORDER BY created_at DESC
LIMIT 5;

-- 5. Test updating is_favorite (if you have data)
-- Uncomment and replace with actual entry ID to test
-- UPDATE public.journal_entries 
-- SET is_favorite = TRUE 
-- WHERE id = 'your-entry-id-here';

-- 6. Test querying favorites (should return empty if no favorites yet)
SELECT 
    COUNT(*) as total_favorites
FROM public.journal_entries 
WHERE is_favorite = TRUE;

-- 7. Verify index usage (explain plan should show index scan)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM public.journal_entries 
WHERE is_favorite = TRUE 
ORDER BY created_at DESC;

-- If all queries above return expected results, migration is successful! ✓
