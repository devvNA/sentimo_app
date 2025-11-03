import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities/journal_entry.dart';

class JournalRepository {
  final SupabaseClient _supabase;

  JournalRepository(this._supabase);

  Future<List<JournalEntry>> getJournalEntries({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => JournalEntry.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
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

      final response = await _supabase
          .from('journal_entries')
          .insert({
            'user_id': userId,
            'content': content,
            'sentiment_label': sentimentLabel,
          })
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
      await _supabase.from('journal_entries').delete().eq('id', id);
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
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
