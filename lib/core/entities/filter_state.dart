import 'package:equatable/equatable.dart';

/// Represents the current state of search and filter options
class FilterState extends Equatable {
  /// Search query text (null or empty = no text filter)
  final String? searchQuery;

  /// Sentiment filter (null = all sentiments, 'positive'/'negative'/'neutral')
  final String? sentimentFilter;

  /// Start date for date range filter (null = no start limit)
  final DateTime? startDate;

  /// End date for date range filter (null = no end limit)
  final DateTime? endDate;

  const FilterState({
    this.searchQuery,
    this.sentimentFilter,
    this.startDate,
    this.endDate,
  });

  /// Creates an empty FilterState (no filters applied)
  const FilterState.empty()
    : searchQuery = null,
      sentimentFilter = null,
      startDate = null,
      endDate = null;

  /// Returns true if any filters are active
  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      sentimentFilter != null ||
      startDate != null ||
      endDate != null;

  /// Returns the number of active filters
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (sentimentFilter != null) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }

  /// Returns true if text search is active
  bool get hasSearchQuery => searchQuery != null && searchQuery!.isNotEmpty;

  /// Returns true if sentiment filter is active
  bool get hasSentimentFilter => sentimentFilter != null;

  /// Returns true if date range filter is active
  bool get hasDateRangeFilter => startDate != null || endDate != null;

  /// Creates a copy with updated values
  FilterState copyWith({
    String? searchQuery,
    String? sentimentFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool clearSearchQuery = false,
    bool clearSentimentFilter = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return FilterState(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      sentimentFilter: clearSentimentFilter
          ? null
          : (sentimentFilter ?? this.sentimentFilter),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  /// Clears all filters
  FilterState clearAll() {
    return const FilterState.empty();
  }

  /// Clears only the search query
  FilterState clearSearch() {
    return copyWith(clearSearchQuery: true);
  }

  /// Clears only the sentiment filter
  FilterState clearSentiment() {
    return copyWith(clearSentimentFilter: true);
  }

  /// Clears only the date range filter
  FilterState clearDateRange() {
    return copyWith(clearStartDate: true, clearEndDate: true);
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'search_query': searchQuery,
      'sentiment_filter': sentimentFilter,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  /// Creates from JSON
  factory FilterState.fromJson(Map<String, dynamic> json) {
    return FilterState(
      searchQuery: json['search_query'] as String?,
      sentimentFilter: json['sentiment_filter'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
    );
  }

  /// Returns a human-readable description of active filters
  String get description {
    if (!hasActiveFilters) return 'All entries';

    final parts = <String>[];

    if (hasSearchQuery) {
      parts.add('Search: "$searchQuery"');
    }

    if (hasSentimentFilter) {
      parts.add('Sentiment: $sentimentFilter');
    }

    if (hasDateRangeFilter) {
      if (startDate != null && endDate != null) {
        parts.add(
          'Date: ${_formatDate(startDate!)} - ${_formatDate(endDate!)}',
        );
      } else if (startDate != null) {
        parts.add('From: ${_formatDate(startDate!)}');
      } else if (endDate != null) {
        parts.add('Until: ${_formatDate(endDate!)}');
      }
    }

    return parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [searchQuery, sentimentFilter, startDate, endDate];
}
