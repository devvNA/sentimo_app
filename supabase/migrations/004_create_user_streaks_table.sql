-- Create user_streaks table for tracking journaling streaks
-- Migration: 004_create_user_streaks_table
-- Purpose: Track consecutive days of journaling and milestone achievements

-- Create user_streaks table
CREATE TABLE IF NOT EXISTS public.user_streaks (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    current_streak INT DEFAULT 0 NOT NULL CHECK (current_streak >= 0),
    longest_streak INT DEFAULT 0 NOT NULL CHECK (longest_streak >= 0),
    last_entry_date DATE,
    achieved_milestones INT[] DEFAULT '{}' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index for querying user streaks
CREATE INDEX IF NOT EXISTS idx_user_streaks_user_id ON public.user_streaks(user_id);

-- Create index for finding users with active streaks
CREATE INDEX IF NOT EXISTS idx_user_streaks_current_streak ON public.user_streaks(current_streak DESC) 
WHERE current_streak > 0;

-- Enable Row Level Security
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own streak data
CREATE POLICY "Users can view their own streak data"
ON public.user_streaks
FOR SELECT
USING (auth.uid() = user_id);

-- RLS Policy: Users can insert their own streak data
CREATE POLICY "Users can insert their own streak data"
ON public.user_streaks
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own streak data
CREATE POLICY "Users can update their own streak data"
ON public.user_streaks
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can delete their own streak data
CREATE POLICY "Users can delete their own streak data"
ON public.user_streaks
FOR DELETE
USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_user_streaks_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER set_user_streaks_updated_at
BEFORE UPDATE ON public.user_streaks
FOR EACH ROW
EXECUTE FUNCTION public.handle_user_streaks_updated_at();

-- Create function to initialize streak for new users
CREATE OR REPLACE FUNCTION public.initialize_user_streak()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_streaks (user_id, current_streak, longest_streak)
    VALUES (NEW.id, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-initialize streak when user signs up
-- Note: This assumes users table exists in auth schema
CREATE TRIGGER initialize_streak_on_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.initialize_user_streak();

-- Add comments for documentation
COMMENT ON TABLE public.user_streaks IS 'Tracks user journaling streaks and milestone achievements';
COMMENT ON COLUMN public.user_streaks.current_streak IS 'Number of consecutive days with at least one journal entry or check-in';
COMMENT ON COLUMN public.user_streaks.longest_streak IS 'Highest streak ever achieved by the user';
COMMENT ON COLUMN public.user_streaks.last_entry_date IS 'Date of the last journal entry or check-in (used to calculate streak expiry)';
COMMENT ON COLUMN public.user_streaks.achieved_milestones IS 'Array of milestone days reached (e.g., [7, 30, 60, 90])';
