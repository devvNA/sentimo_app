# Supabase Database Setup

## How to Run Migrations

### Option 1: Using Supabase Dashboard (Recommended for beginners)

1. Go to your Supabase project dashboard: https://app.supabase.com
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New query**
4. Copy the contents of `migrations/001_create_journal_entries.sql`
5. Paste into the SQL editor
6. Click **Run** to execute the migration

### Option 2: Using Supabase CLI

If you have Supabase CLI installed:

```bash
# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

## Database Schema

### journal_entries table

| Column           | Type                        | Description                                    |
|------------------|-----------------------------|------------------------------------------------|
| id               | UUID (Primary Key)          | Unique identifier for the entry                |
| user_id          | UUID (Foreign Key)          | References auth.users(id), cascades on delete  |
| content          | TEXT                        | Journal entry content                          |
| sentiment_label  | VARCHAR(20)                 | AI-generated sentiment (positive/negative/etc) |
| created_at       | TIMESTAMP WITH TIME ZONE    | Entry creation timestamp                       |
| updated_at       | TIMESTAMP WITH TIME ZONE    | Last update timestamp (auto-updated)           |

### Row-Level Security (RLS) Policies

All policies ensure users can only access their own data:

- **SELECT**: Users can view only their own journal entries
- **INSERT**: Users can create entries only with their own user_id
- **UPDATE**: Users can update only their own entries
- **DELETE**: Users can delete only their own entries

## Verification

After running the migration, verify the setup:

```sql
-- Check if table exists
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'journal_entries';

-- Check RLS policies
SELECT * FROM pg_policies 
WHERE tablename = 'journal_entries';

-- Test insert (should work when authenticated)
INSERT INTO journal_entries (user_id, content, sentiment_label)
VALUES (auth.uid(), 'Test entry', 'neutral');
```

## Next Steps

Once the database is set up:
1. Verify RLS policies are working
2. Test CRUD operations from the Flutter app
3. Implement sentiment analysis integration
