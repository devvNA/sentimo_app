import 'package:equatable/equatable.dart';
import 'journal_entry.dart';

/// Paginated response containing journal entries and pagination metadata
class PaginatedJournalEntries extends Equatable {
  final List<JournalEntry> entries;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedJournalEntries({
    required this.entries,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => currentPage == totalPages;

  /// Get the starting entry number for current page
  int get startEntry => (currentPage - 1) * pageSize + 1;

  /// Get the ending entry number for current page
  int get endEntry => startEntry + entries.length - 1;

  @override
  List<Object?> get props => [
        entries,
        currentPage,
        pageSize,
        totalCount,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];

  @override
  String toString() {
    return 'PaginatedJournalEntries(page $currentPage/$totalPages, '
        'entries: $startEntry-$endEntry of $totalCount)';
  }
}
