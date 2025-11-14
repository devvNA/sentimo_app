import 'package:equatable/equatable.dart';

/// Base class for search/filter events
abstract class SearchFilterEvent extends Equatable {
  const SearchFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Event when search text changes
class SearchTextChanged extends SearchFilterEvent {
  final String query;

  const SearchTextChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event when sentiment filter changes
class SentimentFilterChanged extends SearchFilterEvent {
  final String? sentiment; // null, 'positive', 'negative', 'neutral'

  const SentimentFilterChanged(this.sentiment);

  @override
  List<Object?> get props => [sentiment];
}

/// Event when date range filter changes
class DateRangeFilterChanged extends SearchFilterEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeFilterChanged({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to clear all filters
class ClearFilters extends SearchFilterEvent {
  const ClearFilters();
}

/// Event to apply current filters
class ApplyFilters extends SearchFilterEvent {
  const ApplyFilters();
}

/// Event to refresh search results
class RefreshSearchResults extends SearchFilterEvent {
  const RefreshSearchResults();
}
