import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/filter_state.dart';
import '../../../core/utils/error_logger.dart';
import '../../../data/repositories/journal_repository.dart';
import 'search_filter_event.dart';
import 'search_filter_state.dart';

/// BLoC for managing search and filter state and logic
class SearchFilterBloc extends Bloc<SearchFilterEvent, SearchFilterState> {
  final JournalRepository _journalRepository;

  // Current filter state
  FilterState _currentFilters = const FilterState();

  // Debounce timer for search text
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  SearchFilterBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(const SearchFilterInitial()) {
    on<SearchTextChanged>(_onSearchTextChanged);
    on<SentimentFilterChanged>(_onSentimentFilterChanged);
    on<DateRangeFilterChanged>(_onDateRangeFilterChanged);
    on<ClearFilters>(_onClearFilters);
    on<ApplyFilters>(_onApplyFilters);
    on<RefreshSearchResults>(_onRefreshSearchResults);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Handle search text changes with debouncing
  Future<void> _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<SearchFilterState> emit,
  ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update filter state
    _currentFilters = _currentFilters.copyWith(searchQuery: event.query);

    log('🔍 [SearchFilterBloc] Search text changed: "${event.query}"');

    // Debounce the search
    _debounceTimer = Timer(_debounceDuration, () {
      add(const ApplyFilters());
    });
  }

  /// Handle sentiment filter changes
  Future<void> _onSentimentFilterChanged(
    SentimentFilterChanged event,
    Emitter<SearchFilterState> emit,
  ) async {
    log('🔍 [SearchFilterBloc] Sentiment filter changed: ${event.sentiment}');

    // Update filter state
    _currentFilters = _currentFilters.copyWith(
      sentimentFilter: event.sentiment,
    );

    // Apply filters immediately
    add(const ApplyFilters());
  }

  /// Handle date range filter changes
  Future<void> _onDateRangeFilterChanged(
    DateRangeFilterChanged event,
    Emitter<SearchFilterState> emit,
  ) async {
    log(
      '🔍 [SearchFilterBloc] Date range changed: ${event.startDate} to ${event.endDate}',
    );

    // Update filter state
    _currentFilters = _currentFilters.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    // Apply filters immediately
    add(const ApplyFilters());
  }

  /// Handle clearing all filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchFilterState> emit,
  ) async {
    log('🔍 [SearchFilterBloc] Clearing all filters');

    // Reset filter state
    _currentFilters = const FilterState();

    // Return to initial state
    emit(const SearchFilterInitial());
  }

  /// Handle applying current filters
  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<SearchFilterState> emit,
  ) async {
    try {
      log(
        '🔍 [SearchFilterBloc] Applying filters: ${_currentFilters.activeFilterCount} active',
      );

      // If no filters are active, return to initial state
      if (!_currentFilters.hasActiveFilters) {
        emit(const SearchFilterInitial());
        return;
      }

      emit(SearchFilterLoading(_currentFilters));

      // Search with current filters
      final results = await _journalRepository.searchWithFilters(
        filters: _currentFilters,
        limit: 100,
      );

      // Get total count for the filters
      final totalCount = await _journalRepository.countFilteredEntries(
        searchQuery: _currentFilters.searchQuery,
        sentimentFilter: _currentFilters.sentimentFilter,
        startDate: _currentFilters.startDate,
        endDate: _currentFilters.endDate,
      );

      log('✅ [SearchFilterBloc] Found ${results.length} results');

      // Check if results are empty
      if (results.isEmpty) {
        emit(
          SearchFilterEmpty(
            filters: _currentFilters,
            message: _getEmptyMessage(_currentFilters),
          ),
        );
        return;
      }

      emit(
        SearchFilterLoaded(
          results: results,
          filters: _currentFilters,
          totalCount: totalCount,
        ),
      );
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'SearchFilterBloc.ApplyFilters',
        e,
        stackTrace: stackTrace,
        additionalData: {
          'searchQuery': _currentFilters.searchQuery,
          'sentimentFilter': _currentFilters.sentimentFilter,
          'hasDateRange':
              _currentFilters.startDate != null ||
              _currentFilters.endDate != null,
        },
      );

      emit(
        SearchFilterError(
          message: ErrorLogger.getUserFriendlyMessage(e),
          filters: _currentFilters,
        ),
      );
    }
  }

  /// Handle refreshing search results
  Future<void> _onRefreshSearchResults(
    RefreshSearchResults event,
    Emitter<SearchFilterState> emit,
  ) async {
    log('🔄 [SearchFilterBloc] Refreshing search results');

    // Reapply current filters
    add(const ApplyFilters());
  }

  /// Get appropriate empty message based on active filters
  String _getEmptyMessage(FilterState filters) {
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      return 'No entries found matching "${filters.searchQuery}".\nTry different keywords.';
    }

    if (filters.sentimentFilter != null) {
      return 'No ${filters.sentimentFilter} entries found.\nTry a different filter.';
    }

    if (filters.startDate != null || filters.endDate != null) {
      return 'No entries found in the selected date range.\nTry a different period.';
    }

    return 'No entries found.\nTry adjusting your filters.';
  }
}
