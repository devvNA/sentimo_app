import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/journal_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// BLoC for managing calendar view state and logic
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final JournalRepository _journalRepository;

  CalendarBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(const CalendarInitial()) {
    on<LoadCalendarMonth>(_onLoadCalendarMonth);
    on<SelectDate>(_onSelectDate);
    on<NavigateMonth>(_onNavigateMonth);
  }

  /// Handle loading calendar data for a specific month
  Future<void> _onLoadCalendarMonth(
    LoadCalendarMonth event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      log('📅 [CalendarBloc] Loading calendar for month: ${event.month}');

      emit(const CalendarLoading());

      // Fetch entries grouped by date for the month
      final sentimentDataByDate = await _journalRepository.getEntriesByMonth(
        event.month,
      );

      log(
        '✅ [CalendarBloc] Loaded ${sentimentDataByDate.length} days with entries',
      );

      emit(
        CalendarLoaded(
          currentMonth: event.month,
          sentimentDataByDate: sentimentDataByDate,
        ),
      );
    } catch (e) {
      log('❌ [CalendarBloc] Error loading calendar: $e');

      emit(
        CalendarError(
          message: 'Failed to load calendar data. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle date selection
  Future<void> _onSelectDate(
    SelectDate event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      // Only proceed if we have a loaded calendar state
      if (state is! CalendarLoaded) {
        log('⚠️ [CalendarBloc] Cannot select date: calendar not loaded');
        return;
      }

      final currentState = state as CalendarLoaded;

      log('📅 [CalendarBloc] Selecting date: ${event.date}');

      // Fetch entries for the selected date
      final entries = await _journalRepository.getEntriesByDate(event.date);

      log('✅ [CalendarBloc] Found ${entries.length} entries for date');

      emit(
        DateSelected(
          selectedDate: event.date,
          entries: entries,
          previousState: currentState,
        ),
      );
    } catch (e) {
      log('❌ [CalendarBloc] Error selecting date: $e');

      emit(
        CalendarError(
          message: 'Failed to load entries for selected date.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle month navigation (previous/next)
  Future<void> _onNavigateMonth(
    NavigateMonth event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      // Get current month from state
      DateTime currentMonth;

      if (state is CalendarLoaded) {
        currentMonth = (state as CalendarLoaded).currentMonth;
      } else if (state is DateSelected) {
        currentMonth = (state as DateSelected).previousState.currentMonth;
      } else {
        // Default to current month if no state
        currentMonth = DateTime.now();
      }

      // Calculate new month
      final newMonth = DateTime(
        currentMonth.year,
        currentMonth.month + event.offset,
        1,
      );

      log(
        '📅 [CalendarBloc] Navigating to month: ${newMonth.year}-${newMonth.month}',
      );

      // Load the new month
      add(LoadCalendarMonth(newMonth));
    } catch (e) {
      log('❌ [CalendarBloc] Error navigating month: $e');

      emit(
        CalendarError(
          message: 'Failed to navigate to month.',
          previousState: state,
        ),
      );
    }
  }
}
