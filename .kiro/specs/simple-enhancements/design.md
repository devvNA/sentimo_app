# Design Document: Simple Enhancements

## Overview

This design document outlines the technical implementation approach for six enhancement features for the Sentimo application: Mood Calendar View, Daily Mood Streak, Quick Mood Check-in, Mood Insights Summary, Favorite Entries, and Search & Filter. These features build upon the existing architecture using Flutter, BloC pattern, and Supabase backend.

## Architecture

### High-Level Architecture

All features follow the existing clean architecture pattern:

```
Presentation Layer (UI Widgets)
         ↓
    BloC Layer (State Management)
         ↓
Repository Layer (Data Abstraction)
         ↓
Service Layer (Supabase API)
         ↓
    Database (PostgreSQL)
```

### New Components

1. **Calendar Feature Module** - Mood calendar visualization
2. **Streak Feature Module** - Streak tracking and display
3. **Quick Check-in Feature Module** - Simplified mood logging
4. **Insights Feature Module** - Analytics and summaries
5. **Enhanced Journal Repository** - Extended with favorite and filter capabilities
6. **Search Service** - Text search and filtering logic

## Components and Interfaces

### 1. Mood Calendar View

#### UI Components

**CalendarPage Widget**
- Monthly calendar grid using `table_calendar` package
- Color-coded cells based on sentiment
- Month navigation controls
- Tap handler for date selection

**CalendarDayCell Widget**
- Individual date cell with sentiment color
- Entry count indicator
- Visual states: has-entry, no-entry, selected

**DayEntriesSheet Widget**
- Bottom sheet showing entries for selected date
- List of journal entry cards
- Swipe-to-dismiss functionality

#### BloC Components

**CalendarBloc**
- Events:
  - `LoadCalendarMonth(DateTime month)`
  - `SelectDate(DateTime date)`
  - `NavigateMonth(int offset)`
- States:
  - `CalendarLoading`
  - `CalendarLoaded(Map<DateTime, SentimentData> data)`
  - `CalendarError(String message)`
  - `DateSelected(DateTime date, List<JournalEntry> entries)`

#### Data Models

```dart
class SentimentData {
  final String predominantSentiment; // positive, negative, neutral
  final int entryCount;
  final List<String> sentimentLabels;
}

class CalendarDayData {
  final DateTime date;
  final SentimentData? sentimentData;
}
```

#### Database Changes

No schema changes required. Uses existing `journal_entries` table with queries grouped by date.

### 2. Daily Mood Streak

#### UI Components

**StreakWidget**
- Displayed on home page header
- Shows current streak number with flame icon
- Shows longest streak
- Milestone badge overlay when achieved

**StreakMilestoneDialog**
- Congratulatory message
- Badge visual
- Share button (optional)

#### BloC Components

**StreakBloc**
- Events:
  - `LoadStreak(String userId)`
  - `UpdateStreak(JournalEntry newEntry)`
  - `CheckStreakExpiry()`
- States:
  - `StreakLoading`
  - `StreakLoaded(int current, int longest, List<int> milestones)`
  - `StreakMilestoneReached(int milestone)`
  - `StreakError(String message)`

#### Data Models

```dart
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastEntryDate;
  final List<int> achievedMilestones;
}
```

#### Database Changes

Add new table `user_streaks`:

```sql
CREATE TABLE user_streaks (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  last_entry_date DATE,
  achieved_milestones INT[] DEFAULT '{}',
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 3. Quick Mood Check-in

#### UI Components

**QuickCheckInButton**
- Floating action button on home page
- Quick access to check-in modal

**QuickCheckInModal**
- Bottom sheet with two tabs: Emoji and Rating
- Emoji selector (5 emojis: 😄😊😐😔😢)
- Rating slider (1-5 scale)
- Optional note text field (100 char limit)
- Submit button

**QuickCheckInCard**
- Compact card for displaying check-ins in list
- Shows emoji/rating, timestamp, optional note
- Visually distinct from full entries

#### BloC Components

**QuickCheckInBloc**
- Events:
  - `SubmitEmojiCheckIn(String emoji, String? note)`
  - `SubmitRatingCheckIn(int rating, String? note)`
  - `LoadCheckIns(String userId)`
- States:
  - `QuickCheckInInitial`
  - `QuickCheckInSubmitting`
  - `QuickCheckInSuccess`
  - `QuickCheckInError(String message)`

#### Data Models

```dart
class QuickCheckIn {
  final String id;
  final String userId;
  final String type; // 'emoji' or 'rating'
  final String value; // emoji character or rating number
  final String? note;
  final DateTime createdAt;
}
```

#### Database Changes

Add new table `quick_checkins`:

```sql
CREATE TABLE quick_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(10) NOT NULL, -- 'emoji' or 'rating'
  value VARCHAR(10) NOT NULL,
  note VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
```

Mapping for sentiment calculation:
- Emojis: 😄😊 = positive, 😐 = neutral, 😔😢 = negative
- Ratings: 4-5 = positive, 3 = neutral, 1-2 = negative

### 4. Mood Insights Summary

#### UI Components

**InsightsPage**
- Tab bar for Week/Month selection
- Sentiment distribution pie chart or bar chart
- Percentage cards for each sentiment
- Top words section with word chips
- Summary text card

**SentimentDistributionChart**
- Visual representation using `fl_chart` package
- Color-coded segments
- Legend with percentages

**TopWordsSection**
- Horizontal scrollable list of word chips
- Word frequency indicator

#### BloC Components

**InsightsBloc**
- Events:
  - `LoadInsights(String userId, InsightsPeriod period)`
  - `ChangePeriod(InsightsPeriod period)`
- States:
  - `InsightsLoading`
  - `InsightsLoaded(InsightsData data)`
  - `InsightsEmpty(String message)`
  - `InsightsError(String message)`

#### Data Models

```dart
enum InsightsPeriod { week, month }

class InsightsData {
  final int positiveCount;
  final int negativeCount;
  final int neutralCount;
  final double positivePercentage;
  final double negativePercentage;
  final double neutralPercentage;
  final List<WordFrequency> topWords;
  final String summaryText;
  final DateTime startDate;
  final DateTime endDate;
}

class WordFrequency {
  final String word;
  final int count;
}
```

#### Processing Logic

**Word Extraction:**
1. Combine all entry content for the period
2. Remove stop words (common words like "the", "and", "is")
3. Count word frequencies
4. Return top 3 words

**Summary Generation:**
- If positive > 50%: "This [period] you were mostly positive!"
- If negative > 50%: "This [period] was challenging. Remember, tough times pass."
- If neutral > 50%: "This [period] you maintained balance."
- Otherwise: "This [period] had mixed emotions."

#### Database Changes

No schema changes required. Uses existing `journal_entries` table with aggregation queries.

### 5. Favorite Entries

#### UI Components

**FavoriteButton**
- Star icon button on entry cards
- Filled star for favorited, outline for not favorited
- Tap animation

**FavoritesPage**
- Dedicated page accessible from navigation or home
- List of favorited entries
- Empty state with illustration

#### BloC Components

**FavoritesBloc**
- Events:
  - `ToggleFavorite(String entryId, bool isFavorite)`
  - `LoadFavorites(String userId)`
- States:
  - `FavoritesLoading`
  - `FavoritesLoaded(List<JournalEntry> favorites)`
  - `FavoriteToggled(String entryId, bool isFavorite)`
  - `FavoritesError(String message)`

#### Data Models

Extend existing `JournalEntry` model:

```dart
class JournalEntry {
  // ... existing fields
  final bool isFavorite; // NEW FIELD
}
```

#### Database Changes

Add column to `journal_entries` table:

```sql
ALTER TABLE journal_entries 
ADD COLUMN is_favorite BOOLEAN DEFAULT FALSE;

CREATE INDEX idx_favorite_entries ON journal_entries(user_id, is_favorite) 
WHERE is_favorite = TRUE;
```

### 6. Search & Filter

#### UI Components

**SearchBar**
- Text input field with search icon
- Clear button when text is entered
- Debounced search (300ms delay)

**FilterChipBar**
- Horizontal scrollable row of filter chips
- Sentiment filters: All, Positive, Neutral, Negative
- Date range filter chip (opens date picker)
- Active filter count indicator

**DateRangePickerDialog**
- Start and end date pickers
- Quick select options: Today, This Week, This Month
- Clear and Apply buttons

**FilteredEntriesList**
- List of entries matching filters
- Empty state with filter suggestions
- Result count header

#### BloC Components

**SearchFilterBloc**
- Events:
  - `SearchTextChanged(String query)`
  - `SentimentFilterChanged(String? sentiment)`
  - `DateRangeFilterChanged(DateTime? start, DateTime? end)`
  - `ClearFilters()`
  - `ApplyFilters()`
- States:
  - `SearchFilterInitial`
  - `SearchFilterLoading`
  - `SearchFilterLoaded(List<JournalEntry> results, FilterState filters)`
  - `SearchFilterError(String message)`

#### Data Models

```dart
class FilterState {
  final String? searchQuery;
  final String? sentimentFilter; // null, 'positive', 'negative', 'neutral'
  final DateTime? startDate;
  final DateTime? endDate;
  
  bool get hasActiveFilters => 
    searchQuery != null || 
    sentimentFilter != null || 
    startDate != null || 
    endDate != null;
    
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (sentimentFilter != null) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }
}
```

#### Database Changes

Add full-text search index:

```sql
CREATE INDEX idx_journal_content_search ON journal_entries 
USING gin(to_tsvector('english', content));

CREATE INDEX idx_journal_sentiment ON journal_entries(user_id, sentiment_label);
CREATE INDEX idx_journal_date ON journal_entries(user_id, created_at);
```

#### Search Logic

**Text Search:**
- Use PostgreSQL full-text search with `to_tsvector` and `to_tsquery`
- Case-insensitive matching
- Partial word matching support

**Combined Filters:**
```sql
SELECT * FROM journal_entries
WHERE user_id = $1
  AND ($2 IS NULL OR to_tsvector('english', content) @@ plainto_tsquery('english', $2))
  AND ($3 IS NULL OR sentiment_label = $3)
  AND ($4 IS NULL OR created_at >= $4)
  AND ($5 IS NULL OR created_at <= $5)
ORDER BY created_at DESC;
```

## Data Models

### Updated Journal Entry Model

```dart
class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final String? sentimentLabel;
  final double? sentimentScore;
  final bool isFavorite; // NEW
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### New Models Summary

1. `SentimentData` - Calendar day sentiment aggregation
2. `StreakData` - User streak information
3. `QuickCheckIn` - Quick mood check-in entry
4. `InsightsData` - Analytics summary data
5. `WordFrequency` - Word usage statistics
6. `FilterState` - Search and filter state

## Error Handling

### Calendar View
- **No internet**: Show cached calendar data with offline indicator
- **No entries**: Display empty calendar with encouraging message
- **Date selection error**: Show toast notification

### Streak Tracking
- **Calculation error**: Default to 0, log error
- **Milestone notification failure**: Queue for retry
- **Database sync error**: Show warning, retry on next app open

### Quick Check-in
- **Submission failure**: Show retry button, cache locally
- **Validation error**: Show inline error message
- **Network timeout**: Queue for background sync

### Insights
- **Insufficient data**: Show friendly message with minimum entry requirement
- **Word extraction failure**: Skip top words section
- **Chart rendering error**: Fall back to text-only display

### Favorites
- **Toggle failure**: Revert UI state, show error toast
- **Sync error**: Mark for retry, show sync indicator

### Search & Filter
- **Search timeout**: Show partial results with warning
- **Invalid date range**: Show validation error
- **No results**: Display helpful suggestions

## Testing Strategy

### Unit Tests

1. **BloC Tests**
   - Test all events trigger correct state transitions
   - Test error handling for each BloC
   - Mock repository responses

2. **Repository Tests**
   - Test data transformation
   - Test caching logic
   - Mock Supabase service

3. **Service Tests**
   - Test API call formatting
   - Test response parsing
   - Test error scenarios

4. **Utility Tests**
   - Test streak calculation logic
   - Test word frequency extraction
   - Test date range validation
   - Test sentiment aggregation

### Widget Tests

1. **Calendar Widget**
   - Test month navigation
   - Test date selection
   - Test color coding display

2. **Streak Widget**
   - Test counter display
   - Test milestone badge appearance

3. **Quick Check-in Modal**
   - Test emoji selection
   - Test rating input
   - Test note validation

4. **Insights Charts**
   - Test data visualization
   - Test period toggle

5. **Search Bar**
   - Test text input
   - Test debouncing
   - Test clear functionality

6. **Filter Chips**
   - Test selection state
   - Test multiple filter combination

### Integration Tests

1. **Calendar Flow**
   - Load calendar → Select date → View entries

2. **Streak Flow**
   - Create entry → Verify streak update → Check milestone

3. **Quick Check-in Flow**
   - Open modal → Submit check-in → Verify in list

4. **Insights Flow**
   - Navigate to insights → Toggle period → View data

5. **Favorites Flow**
   - Toggle favorite → Navigate to favorites page → Verify entry

6. **Search Flow**
   - Enter search text → Apply filters → View results → Clear filters

## Performance Considerations

### Calendar View
- Cache month data to avoid repeated queries
- Lazy load entry details only when date is selected
- Limit calendar range to ±12 months from current

### Streak Calculation
- Calculate on app launch and after new entry only
- Cache result in memory for session
- Use database trigger for automatic updates

### Quick Check-ins
- Batch sync when offline
- Compress data before transmission
- Limit history to last 90 days in UI

### Insights
- Pre-calculate insights daily via background job
- Cache results for 24 hours
- Limit word extraction to last 1000 entries

### Search & Filter
- Debounce search input (300ms)
- Limit results to 100 entries
- Use database indexes for fast queries
- Implement pagination for large result sets

### General
- Implement pull-to-refresh with rate limiting
- Use optimistic UI updates for favorites
- Lazy load images and heavy widgets
- Implement proper list view recycling

## Dependencies

### New Packages Required

```yaml
dependencies:
  # Calendar
  table_calendar: ^3.0.9
  
  # Charts
  fl_chart: ^0.65.0
  
  # Existing packages (already in project)
  flutter_bloc: ^8.x.x
  supabase_flutter: ^2.x.x
  equatable: ^2.x.x
```

## Migration Strategy

### Database Migrations

1. **Add is_favorite column**
```sql
ALTER TABLE journal_entries ADD COLUMN is_favorite BOOLEAN DEFAULT FALSE;
```

2. **Create user_streaks table**
```sql
CREATE TABLE user_streaks (...);
```

3. **Create quick_checkins table**
```sql
CREATE TABLE quick_checkins (...);
```

4. **Add indexes**
```sql
CREATE INDEX idx_favorite_entries ...;
CREATE INDEX idx_journal_content_search ...;
CREATE INDEX idx_journal_sentiment ...;
CREATE INDEX idx_journal_date ...;
```

### Rollout Plan

**Phase 1: Foundation (Week 1)**
- Database migrations
- Repository extensions
- Basic UI components

**Phase 2: Core Features (Week 2)**
- Favorites functionality
- Search & Filter
- Calendar view

**Phase 3: Analytics (Week 3)**
- Streak tracking
- Insights summary
- Quick check-in

**Phase 4: Polish (Week 4)**
- Performance optimization
- Error handling refinement
- User testing and feedback

## UI/UX Considerations

### Color Coding

**Sentiment Colors:**
- Positive: `#98D8C8` (Mint Green) - existing accent color
- Neutral: `#F7F7F7` (Off-White) - existing background
- Negative: `#CF6B6B` (Soft Red) - new color, complements palette

### Accessibility

- Minimum touch target size: 48x48 dp
- Color contrast ratio: 4.5:1 for text
- Screen reader support for all interactive elements
- Haptic feedback for important actions
- Support for system font scaling

### Animations

- Fade in/out for page transitions (200ms)
- Scale animation for favorite button (150ms)
- Slide up for bottom sheets (250ms)
- Smooth scroll for calendar navigation
- Confetti animation for milestone achievements

### Empty States

- Calendar: "Start journaling to see your mood patterns"
- Favorites: "Star your favorite entries to find them here"
- Insights: "Write at least 5 entries to see insights"
- Search: "No entries found. Try different keywords"

## Security Considerations

- All queries filtered by authenticated user_id
- Row-Level Security policies for new tables
- Input sanitization for search queries
- Rate limiting on search API calls
- Validate date ranges to prevent excessive queries

## Future Enhancements

- Export calendar as image
- Share insights on social media
- Custom streak milestones
- Advanced analytics (mood trends, correlations)
- Voice-based quick check-in
- Widget for home screen streak display
