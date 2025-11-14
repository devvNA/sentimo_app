-- Add is_favorite column to journal_entries table
-- Migration: 003_add_is_favorite_column
-- Purpose: Enable users to mark journal entries as favorites for easy retrieval

-- Add is_favorite column with default value FALSE
ALTER TABLE public.journal_entries
ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT FALSE NOT NULL;

-- Create index for favorite entries filtering
-- This index is partial (only indexes rows where is_favorite = TRUE) for better performance
CREATE INDEX IF NOT EXISTS idx_journal_entries_favorites 
ON public.journal_entries(user_id, created_at DESC) 
WHERE is_favorite = TRUE;

-- Create composite index for filtering favorites with sentiment
CREATE INDEX IF NOT EXISTS idx_journal_entries_favorites_sentiment 
ON public.journal_entries(user_id, sentiment_label, created_at DESC) 
WHERE is_favorite = TRUE;

-- Add comment for documentation
COMMENT ON COLUMN public.journal_entries.is_favorite IS 'User-marked favorite status for quick access to meaningful entries';
