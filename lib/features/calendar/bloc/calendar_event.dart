import 'package:equatable/equatable.dart';

/// Base class for calendar events
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load calendar data for a specific month
class LoadCalendarMonth extends CalendarEvent {
  final DateTime month;

  const LoadCalendarMonth(this.month);

  @override
  List<Object?> get props => [month];
}

/// Event when user selects a specific date
class SelectDate extends CalendarEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to navigate to previous or next month
class NavigateMonth extends CalendarEvent {
  final int offset; // -1 for previous, +1 for next

  const NavigateMonth(this.offset);

  @override
  List<Object?> get props => [offset];
}
