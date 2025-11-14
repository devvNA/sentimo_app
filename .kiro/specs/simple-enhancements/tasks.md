# Implementation Plan: Simple Enhancements

## Phase 1: Database Setup & Core Infrastructure

- [x] 1. Database schema updates and migrations


  - [x] 1.1 Add is_favorite column to journal_entries table



    - Execute SQL migration to add BOOLEAN column with default FALSE
    - Create index for favorite entries filtering
    - _Requirements: 5.2, 5.4_


  
  - [x] 1.2 Create user_streaks table
    - Write SQL schema for streak tracking
    - Add foreign key constraint to users table


    - Set up default values and constraints
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [x] 1.3 Create quick_checkins table


    - Write SQL schema for check-in entries
    - Add foreign key constraint to users table
    - Set up type and value validation constraints
    - _Requirements: 3.3, 3.6_
  
  - [x] 1.4 Add search and filter indexes
    - Create full-text search index on journal content
    - Create composite indexes for sentiment and date filtering
    - Verify index performance with EXPLAIN queries
    - _Requirements: 6.2, 6.3, 6.5_

- [x] 2. Update core data models


  - [x] 2.1 Extend JournalEntry model with isFavorite field


    - Add boolean field to JournalEntry class
    - Update fromJson and toJson methods
    - Update copyWith method
    - _Requirements: 5.1, 5.5_
  

  - [x] 2.2 Create new data models

    - Implement SentimentData model for calendar
    - Implement StreakData model for streak tracking
    - Implement QuickCheckIn model for check-ins
    - Implement InsightsData and WordFrequency models
    - Implement FilterState model for search
    - Add Equatable for all models


    - _Requirements: 1.3, 2.1, 3.3, 4.2, 6.6_

- [x] 3. Add new dependencies to pubspec.yaml

  - Add table_calendar package for calendar view
  - Add fl_chart package for insights visualization
  - Run flutter pub get to install dependencies
  - _Requirements: 1.1, 4.2_

## Phase 2: Repository & Service Layer

- [x] 4. Extend JournalRepository with new methods


  - [x] 4.1 Implement favorite operations


    - Add toggleFavorite method
    - Add getFavoriteEntries method
    - Handle Supabase update and query operations
    - _Requirements: 5.2, 5.3_
  



  - [x] 4.2 Implement calendar data fetching
    - Add getEntriesByMonth method with date grouping
    - Add getEntriesByDate method for specific date
    - Implement sentiment aggregation logic
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 4.3 Implement search and filter methods
    - Add searchEntries method with full-text search
    - Add filterBySentiment method
    - Add filterByDateRange method
    - Add combined filter method with multiple parameters
    - _Requirements: 6.2, 6.3, 6.5, 6.6_
  
  - [x] 4.4 Implement insights data fetching
    - Add getEntriesByPeriod method (week/month)
    - Add sentiment distribution calculation
    - Implement word frequency extraction with stop words filtering
    - Generate summary text based on sentiment distribution
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 5. Create StreakRepository
  - [x] 5.1 Implement streak data operations
    - Add getStreakData method
    - Add updateStreak method
    - Add checkAndResetStreak method for expired streaks
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [x] 5.2 Implement streak calculation logic
    - Calculate consecutive days from journal entries
    - Update longest streak when current exceeds it
    - Track milestone achievements
    - _Requirements: 2.1, 2.5_

- [x] 6. Create QuickCheckInRepository
  - [x] 6.1 Implement check-in CRUD operations
    - Add createCheckIn method
    - Add getCheckIns method with pagination
    - Map emoji/rating to sentiment labels
    - _Requirements: 3.3, 3.4_
  
  - [x] 6.2 Integrate check-ins with streak calculation
    - Modify streak logic to include check-ins
    - Ensure check-ins count toward daily activity
    - _Requirements: 3.6_

## Phase 3: BloC State Management

- [x] 7. Implement CalendarBloc
  - [x] 7.1 Define calendar events and states
    - Create LoadCalendarMonth event
    - Create SelectDate event
    - Create NavigateMonth event
    - Define CalendarLoading, CalendarLoaded, CalendarError states
    - Define DateSelected state with entries list
    - _Requirements: 1.1, 1.4_
  
  - [x] 7.2 Implement calendar event handlers
    - Handle month loading with repository call
    - Handle date selection and entry fetching
    - Handle month navigation with offset calculation
    - Implement error handling for all operations
    - _Requirements: 1.1, 1.4, 1.6_

- [x] 8. Implement StreakBloc
  - [x] 8.1 Define streak events and states
    - Create LoadStreak event
    - Create UpdateStreak event
    - Create CheckStreakExpiry event
    - Define StreakLoading, StreakLoaded states
    - Define StreakMilestoneReached state
    - _Requirements: 2.1, 2.2, 2.5_
  
  - [x] 8.2 Implement streak event handlers
    - Handle streak loading from repository
    - Handle streak updates after new entries
    - Handle expiry checks on app launch
    - Emit milestone events when thresholds reached
    - _Requirements: 2.2, 2.3, 2.5_

- [x] 9. Implement QuickCheckInBloc
  - [x] 9.1 Define check-in events and states
    - Create SubmitEmojiCheckIn event
    - Create SubmitRatingCheckIn event
    - Create LoadCheckIns event
    - Define QuickCheckInInitial, QuickCheckInSubmitting states
    - Define QuickCheckInSuccess, QuickCheckInError states
    - _Requirements: 3.3_
  
  - [x] 9.2 Implement check-in event handlers
    - Handle emoji submission with validation
    - Handle rating submission with validation
    - Handle note length validation (100 chars)
    - Trigger streak update after successful submission
    - _Requirements: 3.3, 3.4_

- [x] 10. Implement InsightsBloc
  - [x] 10.1 Define insights events and states
    - Create LoadInsights event with period parameter
    - Create ChangePeriod event
    - Define InsightsLoading, InsightsLoaded states
    - Define InsightsEmpty, InsightsError states
    - _Requirements: 4.1, 4.5_
  
  - [x] 10.2 Implement insights event handlers
    - Handle insights loading for selected period
    - Handle period switching (week/month)
    - Handle insufficient data scenarios
    - Calculate percentages and generate summary text
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6_

- [x] 11. Implement FavoritesBloc
  - [x] 11.1 Define favorites events and states
    - Create ToggleFavorite event
    - Create LoadFavorites event
    - Define FavoritesLoading, FavoritesLoaded states
    - Define FavoriteToggled, FavoritesError states
    - _Requirements: 5.2, 5.3_
  
  - [x] 11.2 Implement favorites event handlers
    - Handle favorite toggle with optimistic updates
    - Handle favorites list loading
    - Implement error rollback for failed toggles
    - _Requirements: 5.2, 5.3, 5.6_

- [x] 12. Implement SearchFilterBloc
  - [x] 12.1 Define search/filter events and states
    - Create SearchTextChanged event
    - Create SentimentFilterChanged event
    - Create DateRangeFilterChanged event
    - Create ClearFilters event
    - Create ApplyFilters event
    - Define SearchFilterInitial, SearchFilterLoading states
    - Define SearchFilterLoaded state with results and filter state
    - _Requirements: 6.2, 6.3, 6.5, 6.6_
  
  - [x] 12.2 Implement search/filter event handlers
    - Handle text search with 300ms debouncing
    - Handle sentiment filter changes
    - Handle date range filter changes
    - Handle filter clearing
    - Combine multiple filters in repository query
    - _Requirements: 6.2, 6.3, 6.5, 6.6, 6.7_

## Phase 4: UI Components - Calendar Feature

- [x] 13. Build calendar UI components
  - [x] 13.1 Create CalendarPage widget
    - Implement page scaffold with app bar
    - Add month navigation header
    - Integrate table_calendar widget
    - Configure calendar styling with app theme
    - _Requirements: 1.1, 1.6_
  
  - [x] 13.2 Implement calendar cell customization
    - Create custom cell builder for sentiment colors
    - Add entry count indicator on cells
    - Implement color mapping (positive=mint, neutral=white, negative=red)
    - Handle empty date cells
    - _Requirements: 1.2, 1.3, 1.5_
  
  - [x] 13.3 Create DayEntriesSheet bottom sheet
    - Build bottom sheet with entry list
    - Display all entries for selected date
    - Add swipe-to-dismiss functionality
    - Show empty state when no entries
    - _Requirements: 1.4_
  
  - [x] 13.4 Wire CalendarBloc to UI
    - Connect BlocProvider in widget tree
    - Implement BlocBuilder for calendar state
    - Handle loading, loaded, and error states
    - Trigger events on user interactions
    - _Requirements: 1.1, 1.4, 1.6_

## Phase 5: UI Components - Streak Feature

- [x] 14. Build streak UI components
  - [x] 14.1 Create StreakWidget for home page
    - Design compact widget with flame icon
    - Display current streak number prominently
    - Show longest streak as secondary info
    - Add subtle animation for streak updates
    - _Requirements: 2.4, 2.6_
  
  - [x] 14.2 Create StreakMilestoneDialog
    - Design congratulatory dialog with badge
    - Add confetti animation for celebration
    - Display milestone number (7, 30, 60, 90 days)
    - Add close button
    - _Requirements: 2.5_
  
  - [x] 14.3 Integrate StreakWidget into HomePage
    - Add widget to home page header
    - Connect StreakBloc with BlocProvider
    - Implement BlocListener for milestone events
    - Show milestone dialog when triggered
    - _Requirements: 2.4, 2.5_
  
  - [x] 14.4 Implement streak update triggers
    - Listen to journal entry creation events
    - Trigger streak update in StreakBloc
    - Check for streak expiry on app launch
    - _Requirements: 2.2, 2.3_

## Phase 6: UI Components - Quick Check-in Feature

- [x] 15. Build quick check-in UI components
  - [x] 15.1 Create QuickCheckInButton
    - Design floating action button
    - Position on home page
    - Add icon and styling
    - _Requirements: 3.1_
  
  - [x] 15.2 Create QuickCheckInModal bottom sheet
    - Build bottom sheet with two tabs (Emoji/Rating)
    - Implement emoji selector with 5 emojis
    - Implement rating slider (1-5 scale)
    - Add optional note text field with 100 char limit
    - Add character counter for note
    - Add submit button
    - _Requirements: 3.2, 3.4_
  
  - [x] 15.3 Create QuickCheckInCard widget
    - Design compact card for check-in display
    - Show emoji or rating prominently
    - Display timestamp and optional note
    - Style differently from full journal entries
    - _Requirements: 3.5_
  
  - [x] 15.4 Wire QuickCheckInBloc to UI
    - Connect BlocProvider for check-in modal
    - Implement form validation
    - Handle submission with loading state
    - Show success feedback and close modal
    - Display error messages for failures
    - _Requirements: 3.3, 3.4_
  
  - [x] 15.5 Integrate check-ins into home page list
    - Modify home page to show both entries and check-ins
    - Sort by timestamp in descending order
    - Use QuickCheckInCard for check-in items
    - _Requirements: 3.5_

## Phase 7: UI Components - Insights Feature

- [x] 16. Build insights UI components
  - [x] 16.1 Create InsightsPage scaffold
    - Implement page with app bar
    - Add tab bar for Week/Month selection
    - Set up scrollable content area
    - _Requirements: 4.5_
  
  - [x] 16.2 Create SentimentDistributionChart
    - Implement pie chart using fl_chart
    - Color-code segments (positive, neutral, negative)
    - Add legend with percentages
    - Handle empty data state
    - _Requirements: 4.1, 4.2_
  
  - [x] 16.3 Create sentiment percentage cards
    - Design three cards for each sentiment
    - Display count and percentage
    - Use sentiment colors for visual distinction
    - _Requirements: 4.2_
  
  - [x] 16.4 Create TopWordsSection
    - Build horizontal scrollable list
    - Display top 3 words as chips
    - Show word frequency indicators
    - Handle case when no words available
    - _Requirements: 4.3_
  
  - [x] 16.5 Create summary text card
    - Display generated summary text
    - Style with appropriate typography
    - Add icon based on predominant sentiment
    - _Requirements: 4.4_
  
  - [x] 16.6 Wire InsightsBloc to UI
    - Connect BlocProvider in widget tree
    - Implement BlocBuilder for insights state
    - Handle loading, loaded, empty, and error states
    - Trigger period change events from tab bar
    - _Requirements: 4.1, 4.5, 4.6_
  
  - [x] 16.7 Add insights navigation
    - Add insights option to navigation menu or profile
    - Implement route navigation
    - _Requirements: 4.1_

## Phase 8: UI Components - Favorites Feature

- [x] 17. Build favorites UI components
  - [x] 17.1 Create FavoriteButton widget
    - Design star icon button
    - Implement filled/outline states
    - Add tap animation
    - Handle optimistic UI updates
    - _Requirements: 5.1, 5.6_
  
  - [x] 17.2 Integrate FavoriteButton into entry cards
    - Add button to JournalEntryCard widget
    - Position in top-right corner
    - Connect to FavoritesBloc
    - _Requirements: 5.1, 5.5_
  
  - [x] 17.3 Create FavoritesPage
    - Implement page with app bar
    - Display list of favorited entries
    - Use existing JournalEntryCard component
    - Add empty state with illustration and message
    - _Requirements: 5.3, 5.4_
  
  - [x] 17.4 Wire FavoritesBloc to UI
    - Connect BlocProvider for favorites page
    - Implement BlocBuilder for favorites list
    - Handle toggle events from favorite buttons
    - Show error toast for failed operations
    - _Requirements: 5.2, 5.3_
  
  - [x] 17.5 Add favorites navigation
    - Add favorites option to navigation menu
    - Implement route navigation
    - _Requirements: 5.3_

## Phase 9: UI Components - Search & Filter Feature

- [x] 18. Build search and filter UI components
  - [x] 18.1 Create SearchBar widget
    - Implement text input field with search icon
    - Add clear button when text entered
    - Implement 300ms debouncing
    - Style according to app theme
    - _Requirements: 6.1, 6.2_
  
  - [x] 18.2 Create FilterChipBar widget
    - Build horizontal scrollable chip row
    - Add sentiment filter chips (All, Positive, Neutral, Negative)
    - Add date range filter chip
    - Show active filter count badge
    - Implement chip selection states
    - _Requirements: 6.3, 6.5_
  
  - [x] 18.3 Create DateRangePickerDialog
    - Implement date range picker dialog
    - Add start and end date pickers
    - Add quick select buttons (Today, This Week, This Month)
    - Add Clear and Apply buttons
    - Validate date range (start before end)
    - _Requirements: 6.5_
  
  - [x] 18.4 Create FilteredEntriesList widget
    - Display filtered entries list
    - Show result count header
    - Add empty state with filter suggestions
    - Use existing JournalEntryCard component
    - _Requirements: 6.7_
  
  - [x] 18.5 Integrate search/filter into HomePage
    - Add SearchBar to home page header
    - Add FilterChipBar below search bar
    - Replace static list with FilteredEntriesList
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 18.6 Wire SearchFilterBloc to UI
    - Connect BlocProvider in home page
    - Implement BlocBuilder for search results
    - Trigger search events on text changes
    - Trigger filter events on chip selections
    - Handle clear filters action
    - _Requirements: 6.2, 6.3, 6.5, 6.6_

## Phase 10: Integration & Polish

- [x] 19. Cross-feature integration
  - [x] 19.1 Update HomePage to show all features
    - Integrate StreakWidget in header
    - Add QuickCheckInButton as FAB
    - Integrate SearchBar and FilterChipBar
    - Ensure proper layout and spacing
    - _Requirements: 2.4, 3.1, 6.1_
  
  - [x] 19.2 Update navigation to include new pages
    - Add Calendar to bottom navigation or menu
    - Add Insights to navigation menu
    - Add Favorites to navigation menu
    - Ensure smooth transitions between pages
    - _Requirements: 1.1, 4.1, 5.3_
  
  - [ ] 19.3 Ensure check-ins integrate with calendar
    - Include check-ins in calendar day sentiment calculation
    - Display check-ins in DayEntriesSheet
    - _Requirements: 1.2, 3.6_
  
  - [ ] 19.4 Ensure check-ins integrate with insights
    - Include check-ins in insights calculations
    - Count check-ins in sentiment distribution
    - _Requirements: 4.1, 4.2_

- [ ] 20. Error handling and edge cases
  - [ ] 20.1 Implement offline support
    - Cache calendar data for offline viewing
    - Queue check-ins for sync when offline
    - Show offline indicators
    - _Requirements: 1.1, 3.3_
  
  - [ ] 20.2 Handle empty states gracefully
    - Show encouraging messages for empty calendar
    - Display helpful text for empty favorites
    - Show minimum entry requirement for insights
    - Provide filter suggestions for no search results
    - _Requirements: 1.5, 4.6, 5.3, 6.7_
  
  - [ ] 20.3 Implement error recovery
    - Add retry buttons for failed operations
    - Show user-friendly error messages
    - Log errors for debugging
    - _Requirements: All features_

- [ ] 21. Performance optimization
  - [ ] 21.1 Implement caching strategies
    - Cache calendar month data
    - Cache insights results for 24 hours
    - Cache streak data in memory
    - _Requirements: 1.1, 2.1, 4.1_
  
  - [ ] 21.2 Optimize database queries
    - Verify index usage with EXPLAIN
    - Limit result sets appropriately
    - Implement pagination for large lists
    - _Requirements: 6.2, 6.3, 6.5_
  
  - [ ] 21.3 Optimize UI rendering
    - Implement lazy loading for lists
    - Use const constructors where possible
    - Optimize widget rebuilds with keys
    - _Requirements: All UI components_

- [ ] 22. Accessibility improvements
  - [ ] 22.1 Add semantic labels
    - Add labels for all interactive elements
    - Provide context for screen readers
    - _Requirements: All UI components_
  
  - [ ] 22.2 Ensure proper contrast and sizing
    - Verify color contrast ratios (4.5:1)
    - Ensure minimum touch target size (48x48 dp)
    - Support system font scaling
    - _Requirements: All UI components_
  
  - [ ] 22.3 Add haptic feedback
    - Add feedback for favorite toggle
    - Add feedback for milestone achievements
    - Add feedback for check-in submission
    - _Requirements: 2.5, 3.3, 5.2_

- [ ] 23. Animations and transitions
  - [ ] 23.1 Add page transitions
    - Implement fade transitions (200ms)
    - Add slide-up for bottom sheets (250ms)
    - _Requirements: All pages_
  
  - [ ] 23.2 Add micro-interactions
    - Scale animation for favorite button (150ms)
    - Confetti for milestone achievements
    - Smooth scroll for calendar navigation
    - _Requirements: 1.6, 2.5, 5.1_

- [ ]* 24. Testing
  - [ ]* 24.1 Write unit tests for BloCs
    - Test CalendarBloc event handlers and state transitions
    - Test StreakBloc calculation logic
    - Test QuickCheckInBloc validation
    - Test InsightsBloc data processing
    - Test FavoritesBloc toggle logic
    - Test SearchFilterBloc filtering logic
    - _Requirements: All BloCs_
  
  - [ ]* 24.2 Write unit tests for repositories
    - Test JournalRepository new methods
    - Test StreakRepository calculations
    - Test QuickCheckInRepository operations
    - Mock Supabase responses
    - _Requirements: All repositories_
  
  - [ ]* 24.3 Write widget tests
    - Test calendar widget interactions
    - Test streak widget display
    - Test check-in modal form
    - Test insights charts rendering
    - Test favorite button toggle
    - Test search bar debouncing
    - Test filter chip selection
    - _Requirements: All UI components_
  
  - [ ]* 24.4 Write integration tests
    - Test calendar flow (load → select → view)
    - Test streak update flow
    - Test check-in submission flow
    - Test insights loading flow
    - Test favorite toggle flow
    - Test search and filter flow
    - _Requirements: All features_

- [ ] 25. Documentation and cleanup
  - [ ] 25.1 Update technical documentation
    - Document new database schema
    - Document new API methods
    - Update architecture diagrams
    - _Requirements: All features_
  
  - [ ] 25.2 Add code comments
    - Comment complex logic in repositories
    - Document BloC event handlers
    - Add widget documentation
    - _Requirements: All features_
  
  - [ ] 25.3 Code cleanup
    - Remove unused imports
    - Format code with dart format
    - Run flutter analyze and fix issues
    - _Requirements: All features_

## Implementation Notes

- Each task should be completed and tested before moving to the next
- Database migrations should be tested in development environment first
- UI components should match the existing Sentimo design system (soft blue, mint green, off-white, dark gray)
- All BloCs should follow the existing pattern in the codebase
- Error handling should be consistent across all features
- Performance should be monitored, especially for search and calendar features
- Accessibility should be considered from the start, not added later

## Estimated Complexity

- **Easy Tasks**: 1, 2, 3, 13.1, 14.1, 15.1, 17.1, 18.1
- **Medium Tasks**: 4, 5, 6, 7, 8, 9, 10, 11, 12, 13-18 (most UI tasks), 19, 20, 21, 22, 23
- **Hard Tasks**: 4.4 (word frequency), 12.2 (combined filtering), 21.2 (query optimization)

## Dependencies Between Tasks

- Tasks 1-3 must be completed before any other tasks (database foundation)
- Tasks 4-6 must be completed before tasks 7-12 (repositories before BloCs)
- Tasks 7-12 must be completed before tasks 13-18 (BloCs before UI)
- Task 19 requires all previous tasks to be completed
- Tasks 20-23 can be done in parallel after core features are complete
- Task 24 (testing) should be done incrementally alongside development
- Task 25 should be done last
