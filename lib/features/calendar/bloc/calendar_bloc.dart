import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/error_logger.dart';
import '../../../data/repositories/journal_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// BLoC for managing calendar view state and logic
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final JournalRepository _journalRepository;
  DateTime? _lastRequestedMonth;
  DateTime? _lastSelectedDate;

  CalendarBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(const CalendarInitial()) {
    on<LoadCalendarMonth>(_onLoadCalendarMonth);
    on<SelectDate>(_onSelectDate);
    on<NavigateMonth>(_onNavigateMonth);
    on<RetryCalendarOperation>(_onRetryCalendarOperation);
  }

  /// Handle loading calendar data for a specific month
  Future<void> _onLoadCalendarMonth(
    LoadCalendarMonth event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      log('📅 [CalendarBloc] Loading calendar for month: ${event.month}');

      _lastRequestedMonth = event.month;
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
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'CalendarBloc.LoadCalendarMonth',
        e,
        stackTrace: stackTrace,
        additionalData: {'month': event.month.toIso8601String()},
      );

      emit(
        CalendarError(
          message: ErrorLogger.getUserFriendlyMessage(e),
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
      // Get the current loaded state
      CalendarLoaded currentState;

      if (state is CalendarLoaded) {
        currentState = state as CalendarLoaded;
      } else if (state is DateSelected) {
        currentState = (state as DateSelected).previousState;
      } else {
        log('⚠️ [CalendarBloc] Cannot select date: calendar not loaded');
        return;
      }

      log('📅 [CalendarBloc] Selecting date: ${event.date}');

      _lastSelectedDate = event.date;

      // Emit loading state briefly to ensure state change is detected
      emit(
        CalendarLoaded(
          currentMonth: currentState.currentMonth,
          sentimentDataByDate: currentState.sentimentDataByDate,
        ),
      );

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
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'CalendarBloc.SelectDate',
        e,
        stackTrace: stackTrace,
        additionalData: {'date': event.date.toIso8601String()},
      );

      emit(
        CalendarError(
          message: ErrorLogger.getUserFriendlyMessage(e),
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
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'CalendarBloc.NavigateMonth',
        e,
        stackTrace: stackTrace,
        additionalData: {'offset': event.offset},
      );

      emit(
        CalendarError(
          message: ErrorLogger.getUserFriendlyMessage(e),
          previousState: state,
        ),
      );
    }
  }

  /// Handle retry of failed operation
  Future<void> _onRetryCalendarOperation(
    RetryCalendarOperation event,
    Emitter<CalendarState> emit,
  ) async {
    log('🔄 [CalendarBloc] Retrying failed operation');

    // Retry the last operation based on what was stored
    if (_lastSelectedDate != null) {
      add(SelectDate(_lastSelectedDate!));
    } else if (_lastRequestedMonth != null) {
      add(LoadCalendarMonth(_lastRequestedMonth!));
    } else {
      // Default to loading current month
      add(LoadCalendarMonth(DateTime.now()));
    }
  }
}
