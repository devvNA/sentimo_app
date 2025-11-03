-- Add sentiment score and tags columns to journal_entries table
-- Migration: 002_add_sentiment_details

-- Add sentiment_score column (0.0 to 10.0 scale)
ALTER TABLE public.journal_entries
ADD COLUMN IF NOT EXISTS sentiment_score DECIMAL(3,1) CHECK (sentiment_score >= 0 AND sentiment_score <= 10);

-- Add sentiment_tags column (array of emotion tags)
ALTER TABLE public.journal_entries
ADD COLUMN IF NOT EXISTS sentiment_tags TEXT[];

-- Create index for sentiment_score for analytics queries
CREATE INDEX IF NOT EXISTS idx_journal_entries_sentiment_score ON public.journal_entries(sentiment_score);

-- Add comments for documentation
COMMENT ON COLUMN public.journal_entries.sentiment_score IS 'AI-generated sentiment score from 0 (very negative) to 10 (very positive)';
COMMENT ON COLUMN public.journal_entries.sentiment_tags IS 'Array of emotion tags detected by AI (e.g., gratitude, excitement, anxiety)';
