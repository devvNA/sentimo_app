import 'package:equatable/equatable.dart';

import '../../../core/entities/filter_state.dart';
import '../../../core/entities/journal_entry.dart';

/// Base class for search/filter states
abstract class SearchFilterState extends Equatable {
  const SearchFilterState();

  @override
  List<Object?> get props => [];
}

/// Initial state when search/filter is first created
class SearchFilterInitial extends SearchFilterState {
  const SearchFilterInitial();
}

/// State when search/filter is being applied
class SearchFilterLoading extends SearchFilterState {
  final FilterState filters;

  const SearchFilterLoading(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// State when search/filter results have been loaded
class SearchFilterLoaded extends SearchFilterState {
  final List<JournalEntry> results;
  final FilterState filters;
  final int totalCount;

  const SearchFilterLoaded({
    required this.results,
    required this.filters,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [results, filters, totalCount];

  /// Check if there are any results
  bool get hasResults => results.isNotEmpty;

  /// Check if any filters are active
  bool get hasActiveFilters => filters.hasActiveFilters;

  /// Get the number of active filters
  int get activeFilterCount => filters.activeFilterCount;

  /// Create a copy with updated values
  SearchFilterLoaded copyWith({
    List<JournalEntry>? results,
    FilterState? filters,
    int? totalCount,
  }) {
    return SearchFilterLoaded(
      results: results ?? this.results,
      filters: filters ?? this.filters,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// State when no results match the filters
class SearchFilterEmpty extends SearchFilterState {
  final FilterState filters;
  final String message;

  const SearchFilterEmpty({required this.filters, required this.message});

  @override
  List<Object?> get props => [filters, message];

  /// Check if any filters are active
  bool get hasActiveFilters => filters.hasActiveFilters;
}

/// State when an error occurs
class SearchFilterError extends SearchFilterState {
  final String message;
  final FilterState? filters;

  const SearchFilterError({required this.message, this.filters});

  @override
  List<Object?> get props => [message, filters];
}
