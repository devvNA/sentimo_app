import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities/filter_state.dart';
import '../../core/entities/insights_data.dart';
import '../../core/entities/journal_entry.dart';
import '../../core/entities/paginated_journal_entries.dart';
import '../../core/entities/sentiment_data.dart';

/// Repository for journal entry data operations
/// Implements pagination, caching, and optimized queries
class JournalRepository {
  final SupabaseClient _supabase;

  // PERFORMANCE: Cache for total count to avoid repeated queries
  int? _cachedTotalCount;
  DateTime? _countCacheTime;
  static const _countCacheTimeout = Duration(minutes: 5);

  JournalRepository(this._supabase);

  /// Get journal entries with pagination support
  ///
  /// [limit] - Maximum number of entries to fetch (default: 20)
  /// [offset] - Number of entries to skip (default: 0)
  /// [orderBy] - Field to order by (default: created_at)
  /// [ascending] - Sort order (default: false for newest first)
  Future<List<JournalEntry>> getJournalEntries({
    int limit = 20,
    int offset = 0,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      // PERFORMANCE: Limit validation to prevent excessive queries
      final safeLimit = limit.clamp(1, 100);
      final safeOffset = offset.clamp(0, 10000);

      log(
        '📚 [JournalRepository] Fetching entries: limit=$safeLimit, offset=$safeOffset',
      );

      final response = await _supabase
          .from('journal_entries')
          .select()
          .order(orderBy, ascending: ascending)
          .range(safeOffset, safeOffset + safeLimit - 1);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      log('✅ [JournalRepository] Fetched ${entries.length} entries');

      return entries;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error fetching entries: $e');
      rethrow;
    }
  }

  /// Get total count of journal entries for current user
  /// Results are cached for 5 minutes to improve performance
  Future<int> getTotalCount({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh &&
          _cachedTotalCount != null &&
          _countCacheTime != null) {
        final cacheAge = DateTime.now().difference(_countCacheTime!);
        if (cacheAge < _countCacheTimeout) {
          log('💾 [JournalRepository] Using cached count: $_cachedTotalCount');
          return _cachedTotalCount!;
        }
      }

      log('📊 [JournalRepository] Fetching total count...');

      // Use count query (more efficient than fetching all entries)
      // Note: Supabase requires fetching data to get count, but we minimize payload
      final response = await _supabase
          .from('journal_entries')
          .select('id')
          .limit(1000); // Reasonable limit for count

      final count = (response as List).length;

      // Cache the result
      _cachedTotalCount = count;
      _countCacheTime = DateTime.now();

      log('✅ [JournalRepository] Total entries: $count');

      return count;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Error getting count: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error: $e');
      rethrow;
    }
  }

  /// Get paginated entries with metadata
  /// Returns both entries and pagination info
  Future<PaginatedJournalEntries> getEntriesPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final safePageSize = pageSize.clamp(1, 100);
      final safePage = page.clamp(1, 1000);
      final offset = (safePage - 1) * safePageSize;

      // Get entries and total count in parallel for better performance
      final results = await Future.wait([
        getJournalEntries(limit: safePageSize, offset: offset),
        getTotalCount(),
      ]);

      final entries = results[0] as List<JournalEntry>;
      final totalCount = results[1] as int;
      final totalPages = (totalCount / safePageSize).ceil();

      return PaginatedJournalEntries(
        entries: entries,
        currentPage: safePage,
        pageSize: safePageSize,
        totalCount: totalCount,
        totalPages: totalPages,
        hasNextPage: safePage < totalPages,
        hasPreviousPage: safePage > 1,
      );
    } catch (e) {
      log('❌ [JournalRepository] Error in pagination: $e');
      rethrow;
    }
  }

  /// Clear the count cache (useful after creating/deleting entries)
  void clearCountCache() {
    _cachedTotalCount = null;
    _countCacheTime = null;
    log('🗑️ [JournalRepository] Count cache cleared');
  }

  Future<JournalEntry> getJournalEntryById(String id) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('id', id)
          .single();

      return JournalEntry.fromJson(response);
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<JournalEntry> createJournalEntry({
    required String content,
    String? sentimentLabel,
    DateTime? createdAt,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('✏️ [JournalRepository] Creating entry...');
      log('   Created at: ${createdAt ?? DateTime.now()}');

      final insertData = {
        'user_id': userId,
        'content': content,
        'sentiment_label': sentimentLabel,
      };

      // Add created_at if provided
      if (createdAt != null) {
        insertData['created_at'] = createdAt.toIso8601String();
      }

      final response = await _supabase
          .from('journal_entries')
          .insert(insertData)
          .select()
          .single();

      // Clear count cache since we added an entry
      clearCountCache();

      log('✅ [JournalRepository] Entry created');

      return JournalEntry.fromJson(response);
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error creating entry: $e');
      rethrow;
    }
  }

  Future<JournalEntry> updateJournalEntry({
    required String id,
    String? content,
    String? sentimentLabel,
    double? sentimentScore,
    List<String>? sentimentTags,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (content != null) updates['content'] = content;
      if (sentimentLabel != null) updates['sentiment_label'] = sentimentLabel;
      if (sentimentScore != null) updates['sentiment_score'] = sentimentScore;
      if (sentimentTags != null) updates['sentiment_tags'] = sentimentTags;

      if (updates.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _supabase
          .from('journal_entries')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return JournalEntry.fromJson(response);
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      log('🗑️ [JournalRepository] Deleting entry: $id');

      await _supabase.from('journal_entries').delete().eq('id', id);

      // Clear count cache since we deleted an entry
      clearCountCache();

      log('✅ [JournalRepository] Entry deleted');
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error deleting entry: $e');
      rethrow;
    }
  }

  /// Toggle favorite status of a journal entry
  /// Returns the updated entry with new favorite status
  Future<JournalEntry> toggleFavorite(String entryId, bool isFavorite) async {
    try {
      log(
        '⭐ [JournalRepository] Toggling favorite for entry: $entryId to $isFavorite',
      );

      final response = await _supabase
          .from('journal_entries')
          .update({'is_favorite': isFavorite})
          .eq('id', entryId)
          .select()
          .single();

      log('✅ [JournalRepository] Favorite status updated');

      return JournalEntry.fromJson(response);
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Get all favorite journal entries for the current user
  /// Returns entries ordered by creation date (newest first)
  Future<List<JournalEntry>> getFavoriteEntries({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final safeLimit = limit.clamp(1, 100);
      final safeOffset = offset.clamp(0, 10000);

      log(
        '⭐ [JournalRepository] Fetching favorite entries: limit=$safeLimit, offset=$safeOffset',
      );

      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('is_favorite', true)
          .order('created_at', ascending: false)
          .range(safeOffset, safeOffset + safeLimit - 1);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      log('✅ [JournalRepository] Fetched ${entries.length} favorite entries');

      return entries;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error fetching favorites: $e');
      rethrow;
    }
  }

  /// Get entries grouped by month for calendar view
  /// Returns a map of date to SentimentData
  Future<Map<DateTime, SentimentData>> getEntriesByMonth(DateTime month) async {
    try {
      // Calculate start and end of month
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      log(
        '📅 [JournalRepository] Fetching entries for month: ${month.year}-${month.month}',
      );

      final response = await _supabase
          .from('journal_entries')
          .select('created_at, sentiment_label')
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at', ascending: true);

      // Group entries by date
      final entriesByDate = <DateTime, List<String>>{};

      for (final item in response as List) {
        final createdAt = DateTime.parse(item['created_at'] as String);
        final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final sentiment = item['sentiment_label'] as String? ?? 'neutral';

        if (!entriesByDate.containsKey(date)) {
          entriesByDate[date] = [];
        }
        entriesByDate[date]!.add(sentiment);
      }

      // Convert to SentimentData map
      final result = <DateTime, SentimentData>{};
      entriesByDate.forEach((date, sentiments) {
        result[date] = SentimentData.fromLabels(sentiments);
      });

      log('✅ [JournalRepository] Fetched ${result.length} days with entries');

      return result;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error fetching month entries: $e');
      rethrow;
    }
  }

  /// Get all entries for a specific date
  /// Returns entries ordered by creation time (newest first)
  Future<List<JournalEntry>> getEntriesByDate(DateTime date) async {
    try {
      // Set time to start and end of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      log(
        '📅 [JournalRepository] Fetching entries for date: ${date.year}-${date.month}-${date.day}',
      );

      final response = await _supabase
          .from('journal_entries')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      log('✅ [JournalRepository] Fetched ${entries.length} entries for date');

      return entries;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error fetching entries by date: $e');
      rethrow;
    }
  }

  /// Search and filter journal entries
  /// Supports text search, sentiment filter, and date range filter
  Future<List<JournalEntry>> searchAndFilterEntries({
    String? searchQuery,
    String? sentimentFilter,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final safeLimit = limit.clamp(1, 100);
      final safeOffset = offset.clamp(0, 10000);

      log(
        '🔍 [JournalRepository] Searching entries: query="$searchQuery", sentiment=$sentimentFilter',
      );

      // Start with base query
      var query = _supabase.from('journal_entries').select();

      // Apply text search filter (case-insensitive)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('content', '%$searchQuery%');
      }

      // Apply sentiment filter
      if (sentimentFilter != null && sentimentFilter.isNotEmpty) {
        query = query.eq('sentiment_label', sentimentFilter);
      }

      // Apply date range filters
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(safeOffset, safeOffset + safeLimit - 1);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      log('✅ [JournalRepository] Found ${entries.length} matching entries');

      return entries;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error searching entries: $e');
      rethrow;
    }
  }

  /// Search entries using FilterState object
  /// Convenience method that uses FilterState
  Future<List<JournalEntry>> searchWithFilters({
    required FilterState filters,
    int limit = 50,
    int offset = 0,
  }) async {
    return searchAndFilterEntries(
      searchQuery: filters.searchQuery,
      sentimentFilter: filters.sentimentFilter,
      startDate: filters.startDate,
      endDate: filters.endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Count entries matching search and filter criteria
  /// Used for pagination metadata
  Future<int> countFilteredEntries({
    String? searchQuery,
    String? sentimentFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      log('📊 [JournalRepository] Counting filtered entries...');

      // Start with base query
      var query = _supabase.from('journal_entries').select('id');

      // Apply same filters as search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('content', '%$searchQuery%');
      }

      if (sentimentFilter != null && sentimentFilter.isNotEmpty) {
        query = query.eq('sentiment_label', sentimentFilter);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final count = (response as List).length;

      log('✅ [JournalRepository] Filtered count: $count');

      return count;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error counting entries: $e');
      rethrow;
    }
  }

  /// Get entries for a specific time period (for insights)
  /// Returns entries within the date range
  Future<List<JournalEntry>> getEntriesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log(
        '📊 [JournalRepository] Fetching entries for period: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );

      final response = await _supabase
          .from('journal_entries')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      final entries = (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();

      log('✅ [JournalRepository] Fetched ${entries.length} entries for period');

      return entries;
    } on PostgrestException catch (e) {
      log('❌ [JournalRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [JournalRepository] Error fetching period entries: $e');
      rethrow;
    }
  }

  /// Get insights data for a specific period
  /// Calculates sentiment distribution and extracts top words
  Future<InsightsData> getInsightsForPeriod({
    required InsightsPeriod period,
  }) async {
    try {
      // Calculate date range based on period
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: period.days));

      log('📊 [JournalRepository] Generating insights for ${period.name}');

      // Fetch entries for the period
      final entries = await getEntriesByPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      if (entries.isEmpty) {
        return InsightsData.empty(startDate, endDate);
      }

      // Count sentiments
      int positiveCount = 0;
      int negativeCount = 0;
      int neutralCount = 0;

      // Collect all words for frequency analysis
      final allWords = <String>[];

      for (final entry in entries) {
        // Count sentiment
        final sentiment = entry.sentimentLabel?.name ?? 'neutral';
        switch (sentiment) {
          case 'positive':
            positiveCount++;
            break;
          case 'negative':
            negativeCount++;
            break;
          default:
            neutralCount++;
        }

        // Extract words from content
        final words = _extractWords(entry.content);
        allWords.addAll(words);
      }

      // Calculate top words
      final topWords = _calculateTopWords(allWords, limit: 3);

      // Create insights data
      final insights = InsightsData.fromCounts(
        positiveCount: positiveCount,
        negativeCount: negativeCount,
        neutralCount: neutralCount,
        topWords: topWords,
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      log(
        '✅ [JournalRepository] Insights generated: ${insights.totalCount} entries',
      );

      return insights;
    } catch (e) {
      log('❌ [JournalRepository] Error generating insights: $e');
      rethrow;
    }
  }

  /// Extract words from text (helper method)
  /// Removes stop words and returns meaningful words
  List<String> _extractWords(String text) {
    // Common stop words to filter out
    const stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'from',
      'as',
      'is',
      'was',
      'are',
      'were',
      'been',
      'be',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'can',
      'i',
      'you',
      'he',
      'she',
      'it',
      'we',
      'they',
      'my',
      'your',
      'his',
      'her',
      'its',
      'our',
      'their',
      'this',
      'that',
      'these',
      'those',
    };

    // Convert to lowercase and split by non-word characters
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3 && !stopWords.contains(word))
        .toList();

    return words;
  }

  /// Calculate top N most frequent words
  List<WordFrequency> _calculateTopWords(List<String> words, {int limit = 3}) {
    if (words.isEmpty) return [];

    // Count word frequencies
    final wordCounts = <String, int>{};
    for (final word in words) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }

    // Sort by frequency and take top N
    final sortedWords = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedWords
        .take(limit)
        .map((entry) => WordFrequency(word: entry.key, count: entry.value))
        .toList();
  }

  Stream<List<JournalEntry>> watchJournalEntries() {
    return _supabase
        .from('journal_entries')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => JournalEntry.fromJson(json)).toList(),
        );
  }
}
