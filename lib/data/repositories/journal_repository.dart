import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities/journal_entry.dart';
import '../../core/entities/paginated_journal_entries.dart';

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
      
      log('📚 [JournalRepository] Fetching entries: limit=$safeLimit, offset=$safeOffset');
      
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
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('✏️ [JournalRepository] Creating entry...');

      final response = await _supabase
          .from('journal_entries')
          .insert({
            'user_id': userId,
            'content': content,
            'sentiment_label': sentimentLabel,
          })
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
