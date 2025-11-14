-- Add search and filter indexes to journal_entries table
-- Migration: 006_add_search_filter_indexes
-- Purpose: Optimize full-text search and filtering operations

-- 1. Add full-text search index using PostgreSQL's built-in text search
-- This enables fast searching through journal entry content
CREATE INDEX IF NOT EXISTS idx_journal_entries_content_search 
ON public.journal_entries 
USING gin(to_tsvector('english', content));

-- 2. Add composite index for sentiment filtering
-- Optimizes queries that filter by user_id and sentiment_label
CREATE INDEX IF NOT EXISTS idx_journal_entries_sentiment_filter 
ON public.journal_entries(user_id, sentiment_label, created_at DESC);

-- 3. Add composite index for date range filtering
-- Optimizes queries that filter by user_id and date range
CREATE INDEX IF NOT EXISTS idx_journal_entries_date_range 
ON public.journal_entries(user_id, created_at DESC);

-- 4. Add index for combined sentiment and date filtering
-- Optimizes complex queries with multiple filters
CREATE INDEX IF NOT EXISTS idx_journal_entries_sentiment_date 
ON public.journal_entries(user_id, sentiment_label, created_at);

-- 5. Create helper function for text search with ranking
-- This function provides relevance-ranked search results
CREATE OR REPLACE FUNCTION public.search_journal_entries(
    search_user_id UUID,
    search_query TEXT,
    sentiment_filter VARCHAR DEFAULT NULL,
    start_date TIMESTAMP DEFAULT NULL,
    end_date TIMESTAMP DEFAULT NULL,
    result_limit INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    content TEXT,
    sentiment_label VARCHAR,
    sentiment_score DECIMAL,
    is_favorite BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    search_rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        je.id,
        je.user_id,
        je.content,
        je.sentiment_label,
        je.sentiment_score,
        je.is_favorite,
        je.created_at,
        je.updated_at,
        ts_rank(to_tsvector('english', je.content), plainto_tsquery('english', search_query)) as search_rank
    FROM public.journal_entries je
    WHERE je.user_id = search_user_id
        AND (search_query IS NULL OR search_query = '' OR 
             to_tsvector('english', je.content) @@ plainto_tsquery('english', search_query))
        AND (sentiment_filter IS NULL OR je.sentiment_label = sentiment_filter)
        AND (start_date IS NULL OR je.created_at >= start_date)
        AND (end_date IS NULL OR je.created_at <= end_date)
    ORDER BY 
        CASE 
            WHEN search_query IS NOT NULL AND search_query != '' 
            THEN ts_rank(to_tsvector('english', je.content), plainto_tsquery('english', search_query))
            ELSE 0
        END DESC,
        je.created_at DESC
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.search_journal_entries TO authenticated;

-- 6. Create function to get entry count with filters (for pagination)
CREATE OR REPLACE FUNCTION public.count_filtered_entries(
    search_user_id UUID,
    search_query TEXT DEFAULT NULL,
    sentiment_filter VARCHAR DEFAULT NULL,
    start_date TIMESTAMP DEFAULT NULL,
    end_date TIMESTAMP DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    entry_count INT;
BEGIN
    SELECT COUNT(*)
    INTO entry_count
    FROM public.journal_entries je
    WHERE je.user_id = search_user_id
        AND (search_query IS NULL OR search_query = '' OR 
             to_tsvector('english', je.content) @@ plainto_tsquery('english', search_query))
        AND (sentiment_filter IS NULL OR je.sentiment_label = sentiment_filter)
        AND (start_date IS NULL OR je.created_at >= start_date)
        AND (end_date IS NULL OR je.created_at <= end_date);
    
    RETURN entry_count;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.count_filtered_entries TO authenticated;

-- 7. Create materialized view for search performance (optional, for large datasets)
-- This can be refreshed periodically to improve search performance
CREATE MATERIALIZED VIEW IF NOT EXISTS public.journal_entries_search_cache AS
SELECT 
    id,
    user_id,
    content,
    sentiment_label,
    sentiment_score,
    is_favorite,
    created_at,
    to_tsvector('english', content) as content_vector
FROM public.journal_entries;

-- Create index on the materialized view
CREATE INDEX IF NOT EXISTS idx_search_cache_vector 
ON public.journal_entries_search_cache 
USING gin(content_vector);

CREATE INDEX IF NOT EXISTS idx_search_cache_user 
ON public.journal_entries_search_cache(user_id, created_at DESC);

-- Grant access to the materialized view
GRANT SELECT ON public.journal_entries_search_cache TO authenticated;

-- 8. Create function to refresh search cache
CREATE OR REPLACE FUNCTION public.refresh_search_cache()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.journal_entries_search_cache;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Create trigger to auto-refresh cache on entry changes (optional)
-- Note: For production, consider using a scheduled job instead of trigger
-- to avoid performance impact on writes
CREATE OR REPLACE FUNCTION public.trigger_refresh_search_cache()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh cache asynchronously (requires pg_cron or similar)
    -- For now, we'll just note that cache needs refresh
    -- In production, use: PERFORM pg_notify('refresh_search_cache', '');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON INDEX idx_journal_entries_content_search IS 'Full-text search index for journal entry content';
COMMENT ON INDEX idx_journal_entries_sentiment_filter IS 'Composite index for sentiment filtering with date sorting';
COMMENT ON INDEX idx_journal_entries_date_range IS 'Index for date range queries';
COMMENT ON INDEX idx_journal_entries_sentiment_date IS 'Index for combined sentiment and date filtering';
COMMENT ON FUNCTION public.search_journal_entries IS 'Search journal entries with filters and relevance ranking';
COMMENT ON FUNCTION public.count_filtered_entries IS 'Count entries matching search and filter criteria';
COMMENT ON MATERIALIZED VIEW public.journal_entries_search_cache IS 'Cached search vectors for improved performance';

-- Performance tips:
-- 1. For better search results, consider using ts_rank_cd instead of ts_rank
-- 2. Refresh materialized view periodically: SELECT public.refresh_search_cache();
-- 3. For very large datasets, consider partitioning by date
-- 4. Monitor index usage with: SELECT * FROM pg_stat_user_indexes WHERE relname = 'journal_entries';
