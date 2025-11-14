import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/entities/streak_data.dart';

/// Repository for streak tracking operations
/// Manages daily mood streaks and milestone achievements
class StreakRepository {
  final SupabaseClient _supabase;

  // Milestone thresholds (in days)
  static const List<int> milestones = [7, 30, 60, 90, 180, 365];

  StreakRepository(this._supabase);

  /// Get streak data for the current user
  /// Returns StreakData with current and longest streaks
  Future<StreakData> getStreakData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('🔥 [StreakRepository] Fetching streak data for user: $userId');

      final response = await _supabase
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // No streak record exists, create one
        log('📝 [StreakRepository] No streak record found, creating new one');
        return await _createInitialStreak(userId);
      }

      final streakData = StreakData.fromJson(response);
      log(
        '✅ [StreakRepository] Streak data fetched: current=${streakData.currentStreak}, longest=${streakData.longestStreak}',
      );

      return streakData;
    } on PostgrestException catch (e) {
      log('❌ [StreakRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [StreakRepository] Error fetching streak: $e');
      rethrow;
    }
  }

  /// Create initial streak record for a user
  Future<StreakData> _createInitialStreak(String userId) async {
    try {
      final response = await _supabase
          .from('user_streaks')
          .insert({
            'user_id': userId,
            'current_streak': 0,
            'longest_streak': 0,
            'last_entry_date': null,
            'achieved_milestones': [],
          })
          .select()
          .single();

      return StreakData.fromJson(response);
    } catch (e) {
      log('❌ [StreakRepository] Error creating initial streak: $e');
      rethrow;
    }
  }

  /// Update streak after a new entry is created
  /// Calculates if the streak should continue or reset
  Future<StreakData> updateStreak() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('🔥 [StreakRepository] Updating streak for user: $userId');

      // Get current streak data
      final currentStreak = await getStreakData();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Check if user already logged today
      if (currentStreak.lastEntryDate != null) {
        final lastDate = DateTime(
          currentStreak.lastEntryDate!.year,
          currentStreak.lastEntryDate!.month,
          currentStreak.lastEntryDate!.day,
        );

        // If already logged today, no change needed
        if (lastDate.isAtSameMomentAs(todayDate)) {
          log('ℹ️ [StreakRepository] Already logged today, no update needed');
          return currentStreak;
        }
      }

      // Calculate new streak
      final newStreakData = _calculateNewStreak(currentStreak, todayDate);

      // Update in database
      final response = await _supabase
          .from('user_streaks')
          .update({
            'current_streak': newStreakData.currentStreak,
            'longest_streak': newStreakData.longestStreak,
            'last_entry_date': todayDate.toIso8601String(),
            'achieved_milestones': newStreakData.achievedMilestones,
          })
          .eq('user_id', userId)
          .select()
          .single();

      final updatedStreak = StreakData.fromJson(response);

      log(
        '✅ [StreakRepository] Streak updated: current=${updatedStreak.currentStreak}, longest=${updatedStreak.longestStreak}',
      );

      return updatedStreak;
    } on PostgrestException catch (e) {
      log('❌ [StreakRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [StreakRepository] Error updating streak: $e');
      rethrow;
    }
  }

  /// Calculate new streak based on current data and today's date
  StreakData _calculateNewStreak(StreakData current, DateTime today) {
    if (current.lastEntryDate == null) {
      // First entry ever
      return StreakData(
        currentStreak: 1,
        longestStreak: 1,
        lastEntryDate: today,
        achievedMilestones: _checkMilestone(1, []),
      );
    }

    final lastDate = DateTime(
      current.lastEntryDate!.year,
      current.lastEntryDate!.month,
      current.lastEntryDate!.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(lastDate).inDays;

    int newCurrentStreak;
    List<int> newMilestones = List.from(current.achievedMilestones);

    if (daysDifference == 1) {
      // Consecutive day - increment streak
      newCurrentStreak = current.currentStreak + 1;
      newMilestones = _checkMilestone(newCurrentStreak, newMilestones);
    } else if (daysDifference > 1) {
      // Streak broken - reset to 1
      newCurrentStreak = 1;
      // Keep achieved milestones even after streak breaks
    } else {
      // Same day (shouldn't happen due to check above, but handle it)
      newCurrentStreak = current.currentStreak;
    }

    final newLongestStreak = newCurrentStreak > current.longestStreak
        ? newCurrentStreak
        : current.longestStreak;

    return StreakData(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastEntryDate: today,
      achievedMilestones: newMilestones,
    );
  }

  /// Check if a new milestone has been reached
  /// Returns updated list of achieved milestones
  List<int> _checkMilestone(int currentStreak, List<int> achieved) {
    final newAchieved = List<int>.from(achieved);

    for (final milestone in milestones) {
      if (currentStreak >= milestone && !newAchieved.contains(milestone)) {
        newAchieved.add(milestone);
        log('🎉 [StreakRepository] Milestone reached: $milestone days!');
      }
    }

    return newAchieved;
  }

  /// Check if streak has expired and reset if necessary
  /// Should be called on app launch
  Future<StreakData> checkAndResetStreak() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      log('🔍 [StreakRepository] Checking streak expiry for user: $userId');

      final currentStreak = await getStreakData();

      if (currentStreak.lastEntryDate == null) {
        // No entries yet, nothing to check
        return currentStreak;
      }

      final lastDate = DateTime(
        currentStreak.lastEntryDate!.year,
        currentStreak.lastEntryDate!.month,
        currentStreak.lastEntryDate!.day,
      );
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final daysDifference = todayDate.difference(lastDate).inDays;

      // If more than 1 day has passed, reset streak
      if (daysDifference > 1) {
        log('⚠️ [StreakRepository] Streak expired, resetting to 0');

        final response = await _supabase
            .from('user_streaks')
            .update({
              'current_streak': 0,
              // Keep longest_streak and achieved_milestones
            })
            .eq('user_id', userId)
            .select()
            .single();

        return StreakData.fromJson(response);
      }

      log('✅ [StreakRepository] Streak is still active');
      return currentStreak;
    } on PostgrestException catch (e) {
      log('❌ [StreakRepository] Postgrest error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [StreakRepository] Error checking streak: $e');
      rethrow;
    }
  }

  /// Get the next milestone the user is working towards
  /// Returns null if all milestones achieved
  int? getNextMilestone(int currentStreak) {
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // All milestones achieved!
  }

  /// Get the most recently achieved milestone
  /// Returns null if no milestones achieved
  int? getLatestMilestone(List<int> achievedMilestones) {
    if (achievedMilestones.isEmpty) return null;
    return achievedMilestones.reduce((a, b) => a > b ? a : b);
  }

  /// Calculate days until next milestone
  /// Returns null if all milestones achieved
  int? getDaysUntilNextMilestone(int currentStreak) {
    final nextMilestone = getNextMilestone(currentStreak);
    if (nextMilestone == null) return null;
    return nextMilestone - currentStreak;
  }
}
