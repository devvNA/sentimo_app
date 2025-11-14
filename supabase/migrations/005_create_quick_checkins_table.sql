-- Create quick_checkins table for fast mood logging
-- Migration: 005_create_quick_checkins_table
-- Purpose: Enable users to quickly log mood without writing full journal entries

-- Create quick_checkins table
CREATE TABLE IF NOT EXISTS public.quick_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('emoji', 'rating')),
    value VARCHAR(10) NOT NULL,
    note VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index for user's check-ins (most common query)
CREATE INDEX IF NOT EXISTS idx_quick_checkins_user_id ON public.quick_checkins(user_id, created_at DESC);

-- Create index for date-based queries (for calendar and insights)
CREATE INDEX IF NOT EXISTS idx_quick_checkins_created_at ON public.quick_checkins(created_at DESC);

-- Create composite index for user + date range queries
CREATE INDEX IF NOT EXISTS idx_quick_checkins_user_date ON public.quick_checkins(user_id, created_at);

-- Enable Row Level Security
ALTER TABLE public.quick_checkins ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own check-ins
CREATE POLICY "Users can view their own check-ins"
ON public.quick_checkins
FOR SELECT
USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own check-ins
CREATE POLICY "Users can insert their own check-ins"
ON public.quick_checkins
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own check-ins
CREATE POLICY "Users can update their own check-ins"
ON public.quick_checkins
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own check-ins
CREATE POLICY "Users can delete their own check-ins"
ON public.quick_checkins
FOR DELETE
USING (auth.uid() = user_id);

-- Create function to validate check-in data
CREATE OR REPLACE FUNCTION public.validate_quick_checkin()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate emoji type
    IF NEW.type = 'emoji' THEN
        -- Check if value is one of the allowed emojis
        IF NEW.value NOT IN ('😄', '😊', '😐', '😔', '😢') THEN
            RAISE EXCEPTION 'Invalid emoji value. Must be one of: 😄, 😊, 😐, 😔, 😢';
        END IF;
    END IF;
    
    -- Validate rating type
    IF NEW.type = 'rating' THEN
        -- Check if value is a number between 1 and 5
        IF NEW.value !~ '^[1-5]$' THEN
            RAISE EXCEPTION 'Invalid rating value. Must be between 1 and 5';
        END IF;
    END IF;
    
    -- Validate note length if provided
    IF NEW.note IS NOT NULL AND LENGTH(NEW.note) > 100 THEN
        RAISE EXCEPTION 'Note exceeds maximum length of 100 characters';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to validate check-in data before insert/update
CREATE TRIGGER validate_checkin_data
BEFORE INSERT OR UPDATE ON public.quick_checkins
FOR EACH ROW
EXECUTE FUNCTION public.validate_quick_checkin();

-- Create function to get sentiment from check-in
CREATE OR REPLACE FUNCTION public.get_checkin_sentiment(checkin_type VARCHAR, checkin_value VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    -- Map emoji to sentiment
    IF checkin_type = 'emoji' THEN
        CASE checkin_value
            WHEN '😄', '😊' THEN RETURN 'positive';
            WHEN '😐' THEN RETURN 'neutral';
            WHEN '😔', '😢' THEN RETURN 'negative';
            ELSE RETURN 'neutral';
        END CASE;
    END IF;
    
    -- Map rating to sentiment
    IF checkin_type = 'rating' THEN
        CASE 
            WHEN checkin_value::INT >= 4 THEN RETURN 'positive';
            WHEN checkin_value::INT = 3 THEN RETURN 'neutral';
            WHEN checkin_value::INT <= 2 THEN RETURN 'negative';
            ELSE RETURN 'neutral';
        END CASE;
    END IF;
    
    RETURN 'neutral';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create view for check-ins with sentiment labels (useful for analytics)
CREATE OR REPLACE VIEW public.quick_checkins_with_sentiment AS
SELECT 
    id,
    user_id,
    type,
    value,
    note,
    created_at,
    public.get_checkin_sentiment(type, value) as sentiment_label
FROM public.quick_checkins;

-- Grant access to the view
GRANT SELECT ON public.quick_checkins_with_sentiment TO authenticated;

-- Add comments for documentation
COMMENT ON TABLE public.quick_checkins IS 'Quick mood check-ins without full journal entries';
COMMENT ON COLUMN public.quick_checkins.type IS 'Type of check-in: emoji or rating';
COMMENT ON COLUMN public.quick_checkins.value IS 'Emoji character (😄😊😐😔😢) or rating number (1-5)';
COMMENT ON COLUMN public.quick_checkins.note IS 'Optional brief note (max 100 characters)';
COMMENT ON COLUMN public.quick_checkins.created_at IS 'Timestamp when check-in was created';
COMMENT ON VIEW public.quick_checkins_with_sentiment IS 'Check-ins with computed sentiment labels for analytics';
