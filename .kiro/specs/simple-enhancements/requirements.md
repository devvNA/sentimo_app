# Requirements Document

## Introduction

This document outlines the requirements for six simple enhancement features to be added to the Sentimo AI Sentiment Journal application. These features aim to improve user engagement, provide better insights into emotional patterns, and enhance the overall journaling experience. The enhancements include: Mood Calendar View, Daily Mood Streak, Quick Mood Check-in, Mood Insights Summary, Favorite Entries, and Search & Filter functionality.

## Glossary

- **Sentimo App**: The AI-powered sentiment journal Flutter mobile application
- **Journal Entry**: A text-based diary entry created by the user with associated sentiment analysis
- **Sentiment Label**: AI-generated classification of emotional tone (positive, negative, neutral)
- **Mood Streak**: Consecutive days where the user has created at least one journal entry
- **Quick Check-in**: A simplified mood logging method using emoji or numeric rating without full text entry
- **Mood Calendar**: Visual calendar representation showing daily mood patterns
- **Favorite Entry**: A journal entry marked by the user for easy retrieval
- **Supabase Database**: PostgreSQL database backend for data storage
- **BloC**: Business Logic Component pattern used for state management

## Requirements

### Requirement 1: Mood Calendar View

**User Story:** As a user, I want to view my journal entries in a calendar format with color-coded moods, so that I can quickly visualize my emotional patterns over time.

#### Acceptance Criteria

1. WHEN the user navigates to the calendar view, THE Sentimo App SHALL display a monthly calendar grid with all dates of the current month
2. WHILE displaying the calendar, THE Sentimo App SHALL color-code each date based on the predominant sentiment label of entries created on that date
3. WHEN a date contains multiple journal entries, THE Sentimo App SHALL calculate and display the most frequent sentiment label for that date
4. WHEN the user taps on a calendar date, THE Sentimo App SHALL navigate to a list view showing all journal entries created on that date
5. WHEN a date has no journal entries, THE Sentimo App SHALL display that date with a neutral background color
6. THE Sentimo App SHALL provide navigation controls to move between previous and next months

### Requirement 2: Daily Mood Streak

**User Story:** As a user, I want to see how many consecutive days I have been journaling, so that I can stay motivated to maintain my journaling habit.

#### Acceptance Criteria

1. THE Sentimo App SHALL calculate the current streak by counting consecutive days with at least one journal entry
2. WHEN the user creates a journal entry, THE Sentimo App SHALL update the streak counter if the entry extends the current streak
3. WHEN a day passes without a journal entry, THE Sentimo App SHALL reset the streak counter to zero
4. THE Sentimo App SHALL display the current streak count prominently on the home page
5. WHEN the user reaches milestone streak counts (7, 30, 60, 90 days), THE Sentimo App SHALL display a congratulatory badge or notification
6. THE Sentimo App SHALL store the highest streak achieved by the user and display it alongside the current streak

### Requirement 3: Quick Mood Check-in

**User Story:** As a user, I want to quickly log my mood without writing a full journal entry, so that I can track my emotional state even on busy days.

#### Acceptance Criteria

1. THE Sentimo App SHALL provide a quick check-in interface accessible from the home page
2. THE Sentimo App SHALL offer two check-in methods: emoji selection (5 options) and numeric rating (1-5 scale)
3. WHEN the user submits a quick check-in, THE Sentimo App SHALL store the mood data with a timestamp in the Supabase Database
4. THE Sentimo App SHALL allow users to optionally add a brief note (maximum 100 characters) to the quick check-in
5. WHEN displaying quick check-ins, THE Sentimo App SHALL visually distinguish them from full journal entries
6. THE Sentimo App SHALL include quick check-ins in streak calculations and calendar view

### Requirement 4: Mood Insights Summary

**User Story:** As a user, I want to see a summary of my emotional patterns over time, so that I can understand my mental health trends better.

#### Acceptance Criteria

1. THE Sentimo App SHALL calculate and display sentiment distribution percentages for a selected time period (week or month)
2. WHEN the user views the insights summary, THE Sentimo App SHALL show the count of positive, negative, and neutral entries
3. THE Sentimo App SHALL identify and display the three most frequently used words across all journal entries in the selected period
4. THE Sentimo App SHALL provide a simple text-based summary statement (e.g., "This week you were mostly positive!")
5. THE Sentimo App SHALL allow users to toggle between weekly and monthly views of the insights
6. WHEN insufficient data exists for the selected period, THE Sentimo App SHALL display an appropriate message encouraging more journaling

### Requirement 5: Favorite Entries

**User Story:** As a user, I want to mark certain journal entries as favorites, so that I can easily find and revisit meaningful moments.

#### Acceptance Criteria

1. THE Sentimo App SHALL provide a favorite toggle button on each journal entry card and detail view
2. WHEN the user taps the favorite button, THE Sentimo App SHALL update the entry's favorite status in the Supabase Database
3. THE Sentimo App SHALL provide a dedicated view showing only favorited journal entries
4. WHEN displaying the favorites list, THE Sentimo App SHALL sort entries by creation date in descending order
5. THE Sentimo App SHALL display a visual indicator (star icon) on favorited entries in all list views
6. THE Sentimo App SHALL allow users to unfavorite an entry by tapping the favorite button again

### Requirement 6: Search & Filter

**User Story:** As a user, I want to search and filter my journal entries, so that I can quickly find specific entries or review entries with particular sentiments.

#### Acceptance Criteria

1. THE Sentimo App SHALL provide a search bar on the home page that accepts text input
2. WHEN the user enters search text, THE Sentimo App SHALL filter journal entries to show only those containing the search term in their content
3. THE Sentimo App SHALL provide filter options for sentiment labels (positive, negative, neutral, all)
4. WHEN a sentiment filter is applied, THE Sentimo App SHALL display only entries matching the selected sentiment label
5. THE Sentimo App SHALL provide a date range filter allowing users to specify start and end dates
6. THE Sentimo App SHALL allow users to combine multiple filters (search text, sentiment, and date range) simultaneously
7. WHEN no entries match the applied filters, THE Sentimo App SHALL display an appropriate "no results" message
