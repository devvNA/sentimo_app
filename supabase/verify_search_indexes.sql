-- Verification script for migration 006_add_search_filter_indexes
-- Run this in Supabase SQL Editor after applying the migration

-- 1. Check if all new indexes were created
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'journal_entries'
AND indexname IN (
    'idx_journal_entries_content_search',
    'idx_journal_entries_sentiment_filter',
    'idx_journal_entries_date_range',
    'idx_journal_entries_sentiment_date'
)
ORDER BY indexname;

-- Expected 4 indexes:
-- idx_journal_entries_content_search (GIN index for full-text search)
-- idx_journal_entries_sentiment_filter
-- idx_journal_entries_date_range
-- idx_journal_entries_sentiment_date

-- 2. Check if search function exists
SELECT 
    routine_name,
    routine_type,
    data_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'search_journal_entries';

-- Expected: search_journal_entries (FUNCTION)

-- 3. Check if count function exists
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'count_filtered_entries';

-- Expected: count_filtered_entries (FUNCTION)

-- 4. Check if materialized view exists
SELECT 
    schemaname,
    matviewname,
    definition
FROM pg_matviews
WHERE schemaname = 'public'
AND matviewname = 'journal_entries_search_cache';

-- Expected: journal_entries_search_cache

-- 5. Check indexes on materialized view
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename = 'journal_entries_search_cache'
ORDER BY indexname;

-- Expected 2 indexes:
-- idx_search_cache_vector (GIN index)
-- idx_search_cache_user

-- 6. Check if refresh function exists
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'refresh_search_cache';

-- Expected: refresh_search_cache (FUNCTION)

-- 7. Test full-text search capability
-- This tests if the GIN index is working
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, content, created_at
FROM public.journal_entries
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'happy')
LIMIT 10;

-- Expected: Should show "Bitmap Index Scan" using idx_journal_entries_content_search

-- 8. Test search function with text query (if you have data and are authenticated)
-- Uncomment to test:
/*
SELECT 
    id,
    LEFT(content, 50) as content_preview,
    sentiment_label,
    created_at,
    search_rank
FROM public.search_journal_entries(
    auth.uid(),
    'happy',  -- search query
    NULL,     -- sentiment filter (NULL = all)
    NULL,     -- start date
    NULL,     -- end date
    10        -- limit
);
*/

-- 9. Test search function with sentiment filter
-- Uncomment to test:
/*
SELECT 
    id,
    LEFT(content, 50) as content_preview,
    sentiment_label,
    created_at,
    search_rank
FROM public.search_journal_entries(
    auth.uid(),
    NULL,        -- no text search
    'positive',  -- only positive entries
    NULL,
    NULL,
    10
);
*/

-- 10. Test search function with date range
-- Uncomment to test:
/*
SELECT 
    id,
    LEFT(content, 50) as content_preview,
    sentiment_label,
    created_at,
    search_rank
FROM public.search_journal_entries(
    auth.uid(),
    NULL,
    NULL,
    NOW() - INTERVAL '7 days',  -- last 7 days
    NOW(),
    10
);
*/

-- 11. Test combined filters (text + sentiment + date)
-- Uncomment to test:
/*
SELECT 
    id,
    LEFT(content, 50) as content_preview,
    sentiment_label,
    created_at,
    search_rank
FROM public.search_journal_entries(
    auth.uid(),
    'grateful',
    'positive',
    NOW() - INTERVAL '30 days',
    NOW(),
    10
);
*/

-- 12. Test count function
-- Uncomment to test:
/*
SELECT public.count_filtered_entries(
    auth.uid(),
    'happy',
    NULL,
    NULL,
    NULL
) as matching_entries;
*/

-- 13. Test materialized view query
-- Uncomment to test:
/*
SELECT 
    id,
    LEFT(content, 50) as content_preview,
    sentiment_label,
    created_at
FROM public.journal_entries_search_cache
WHERE user_id = auth.uid()
AND content_vector @@ plainto_tsquery('english', 'happy')
ORDER BY created_at DESC
LIMIT 10;
*/

-- 14. Test refresh materialized view
-- Uncomment to test:
/*
SELECT public.refresh_search_cache();
*/

-- 15. Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as times_used,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
AND tablename = 'journal_entries'
AND indexname LIKE 'idx_journal%'
ORDER BY indexname;

-- 16. Check index sizes
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
AND tablename IN ('journal_entries', 'journal_entries_search_cache')
ORDER BY pg_relation_size(indexrelid) DESC;

-- 17. Test search performance comparison
-- Run this to see the performance difference with and without index
-- First, disable index scan (for testing only):
/*
SET enable_indexscan = off;
SET enable_bitmapscan = off;

EXPLAIN ANALYZE
SELECT * FROM public.journal_entries
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'happy');

-- Now enable it back:
SET enable_indexscan = on;
SET enable_bitmapscan = on;

EXPLAIN ANALYZE
SELECT * FROM public.journal_entries
WHERE to_tsvector('english', content) @@ plainto_tsquery('english', 'happy');
*/

-- 18. Verify function permissions
SELECT 
    routine_name,
    grantee,
    privilege_type
FROM information_schema.routine_privileges
WHERE routine_schema = 'public'
AND routine_name IN ('search_journal_entries', 'count_filtered_entries', 'refresh_search_cache')
ORDER BY routine_name, grantee;

-- Expected: authenticated role should have EXECUTE privilege

-- If all queries above return expected results, migration is successful! ✓

-- Performance Notes:
-- - Full-text search is case-insensitive and handles word variations
-- - GIN indexes are larger but faster for text search
-- - Materialized view should be refreshed periodically (daily or after bulk updates)
-- - Monitor index usage and adjust based on query patterns
