import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities/quick_checkin.dart';

/// Repository for quick mood check-in operations
/// Manages emoji and rating-based mood logging
class QuickCheckInRepository {
  final SupabaseClient _supabase;

  QuickCheckInRepository(this._supabase);

  /// Create a new quick check-in entry
  /// Returns the created QuickCheckIn object
  Future<QuickCheckIn> createCheckIn({
    required CheckInType type,
    required String value,
    String? note,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Validate note length
      if (note != null && note.length > 100) {
        throw Exception('Note must be 100 characters or less');
      }

      log(
        '✍️ [QuickCheckInRepository] Creating check-in: type=${type.name}, value=$value',
      );

      final response = await _supabase
          .from('quick_checkins')
          .insert({
            'user_id': userId,
            'type': type.name,
            'value': value,
            'note': note,
          })
          .select()
          .single();

      final checkIn = QuickCheckIn.fromJson(response);

      log('✅ [QuickCheckInRepository] Check-in created: ${checkIn.id}');

      return checkIn;
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error creating check-in: $e');
      rethrow;
    }
  }

  /// Create an emoji-based check-in
  /// Convenience method for emoji check-ins
  Future<QuickCheckIn> createEmojiCheckIn({
    required String emoji,
    String? note,
  }) async {
    // Validate emoji is one of the allowed ones
    const allowedEmojis = ['😄', '😊', '😐', '😔', '😢'];
    if (!allowedEmojis.contains(emoji)) {
      throw Exception(
        'Invalid emoji. Must be one of: ${allowedEmojis.join(", ")}',
      );
    }

    return createCheckIn(type: CheckInType.emoji, value: emoji, note: note);
  }

  /// Create a rating-based check-in
  /// Convenience method for rating check-ins
  Future<QuickCheckIn> createRatingCheckIn({
    required int rating,
    String? note,
  }) async {
    // Validate rating is between 1 and 5
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    return createCheckIn(
      type: CheckInType.rating,
      value: rating.toString(),
      note: note,
    );
  }

  /// Get check-ins for the current user with pagination
  /// Returns list of QuickCheckIn objects ordered by creation date (newest first)
  Future<List<QuickCheckIn>> getCheckIns({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final safeLimit = limit.clamp(1, 100);
      final safeOffset = offset.clamp(0, 10000);

      log(
        '📋 [QuickCheckInRepository] Fetching check-ins: limit=$safeLimit, offset=$safeOffset',
      );

      final response = await _supabase
          .from('quick_checkins')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(safeOffset, safeOffset + safeLimit - 1);

      final checkIns = (response as List)
          .map((json) => QuickCheckIn.fromJson(json))
          .toList();

      log('✅ [QuickCheckInRepository] Fetched ${checkIns.length} check-ins');

      return checkIns;
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error fetching check-ins: $e');
      rethrow;
    }
  }

  /// Get check-ins for a specific date
  /// Used for calendar integration and streak calculation
  Future<List<QuickCheckIn>> getCheckInsByDate(DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Set time to start and end of day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      log(
        '📅 [QuickCheckInRepository] Fetching check-ins for date: ${date.year}-${date.month}-${date.day}',
      );

      final response = await _supabase
          .from('quick_checkins')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      final checkIns = (response as List)
          .map((json) => QuickCheckIn.fromJson(json))
          .toList();

      log(
        '✅ [QuickCheckInRepository] Fetched ${checkIns.length} check-ins for date',
      );

      return checkIns;
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error fetching check-ins by date: $e');
      rethrow;
    }
  }

  /// Get check-ins for a date range
  /// Used for insights and analytics
  Future<List<QuickCheckIn>> getCheckInsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log(
        '📊 [QuickCheckInRepository] Fetching check-ins for period: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );

      final response = await _supabase
          .from('quick_checkins')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      final checkIns = (response as List)
          .map((json) => QuickCheckIn.fromJson(json))
          .toList();

      log(
        '✅ [QuickCheckInRepository] Fetched ${checkIns.length} check-ins for period',
      );

      return checkIns;
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error fetching check-ins by period: $e');
      rethrow;
    }
  }

  /// Delete a check-in
  /// Returns true if successful
  Future<void> deleteCheckIn(String checkInId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('🗑️ [QuickCheckInRepository] Deleting check-in: $checkInId');

      await _supabase
          .from('quick_checkins')
          .delete()
          .eq('id', checkInId)
          .eq('user_id', userId); // Ensure user owns the check-in

      log('✅ [QuickCheckInRepository] Check-in deleted');
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error deleting check-in: $e');
      rethrow;
    }
  }

  /// Map emoji to sentiment label
  /// Used for calendar and insights integration
  static String emojiToSentiment(String emoji) {
    switch (emoji) {
      case '😄':
      case '😊':
        return 'positive';
      case '😐':
        return 'neutral';
      case '😔':
      case '😢':
        return 'negative';
      default:
        return 'neutral';
    }
  }

  /// Map rating to sentiment label
  /// Used for calendar and insights integration
  static String ratingToSentiment(int rating) {
    if (rating >= 4) {
      return 'positive';
    } else if (rating == 3) {
      return 'neutral';
    } else {
      return 'negative';
    }
  }

  /// Get sentiment label for a check-in
  /// Convenience method that handles both emoji and rating types
  static String getSentimentLabel(QuickCheckIn checkIn) {
    if (checkIn.type == CheckInType.emoji) {
      return emojiToSentiment(checkIn.value);
    } else {
      final rating = int.tryParse(checkIn.value) ?? 3;
      return ratingToSentiment(rating);
    }
  }

  /// Check if user has any check-ins for today
  /// Used for streak calculation
  Future<bool> hasCheckInToday() async {
    try {
      final today = DateTime.now();
      final checkIns = await getCheckInsByDate(today);
      return checkIns.isNotEmpty;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error checking today\'s check-ins: $e');
      return false;
    }
  }

  /// Get total count of check-ins for the current user
  Future<int> getTotalCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('📊 [QuickCheckInRepository] Fetching total count...');

      final response = await _supabase
          .from('quick_checkins')
          .select('id')
          .eq('user_id', userId);

      final count = (response as List).length;

      log('✅ [QuickCheckInRepository] Total check-ins: $count');

      return count;
    } on PostgrestException catch (e) {
      log('❌ [QuickCheckInRepository] Error getting count: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [QuickCheckInRepository] Error: $e');
      rethrow;
    }
  }
}
