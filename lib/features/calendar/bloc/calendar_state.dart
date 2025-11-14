import 'package:equatable/equatable.dart';

import '../../../core/entities/journal_entry.dart';
import '../../../core/entities/sentiment_data.dart';

/// Base class for calendar states
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

/// Initial state when calendar is first created
class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

/// State when calendar data is being loaded
class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

/// State when calendar data has been successfully loaded
class CalendarLoaded extends CalendarState {
  final DateTime currentMonth;
  final Map<DateTime, SentimentData> sentimentDataByDate;

  const CalendarLoaded({
    required this.currentMonth,
    required this.sentimentDataByDate,
  });

  @override
  List<Object?> get props => [currentMonth, sentimentDataByDate];

  /// Check if a specific date has entries
  bool hasEntriesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return sentimentDataByDate.containsKey(normalizedDate) &&
        sentimentDataByDate[normalizedDate]!.hasEntries;
  }

  /// Get sentiment data for a specific date
  SentimentData? getSentimentForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return sentimentDataByDate[normalizedDate];
  }

  /// Create a copy with updated values
  CalendarLoaded copyWith({
    DateTime? currentMonth,
    Map<DateTime, SentimentData>? sentimentDataByDate,
  }) {
    return CalendarLoaded(
      currentMonth: currentMonth ?? this.currentMonth,
      sentimentDataByDate: sentimentDataByDate ?? this.sentimentDataByDate,
    );
  }
}

/// State when a specific date has been selected
class DateSelected extends CalendarState {
  final DateTime selectedDate;
  final List<JournalEntry> entries;
  final CalendarLoaded previousState;

  const DateSelected({
    required this.selectedDate,
    required this.entries,
    required this.previousState,
  });

  @override
  List<Object?> get props => [selectedDate, entries, previousState];

  /// Check if the selected date has any entries
  bool get hasEntries => entries.isNotEmpty;

  /// Get the count of entries for the selected date
  int get entryCount => entries.length;
}

/// State when an error occurs
class CalendarError extends CalendarState {
  final String message;
  final CalendarState? previousState;

  const CalendarError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
