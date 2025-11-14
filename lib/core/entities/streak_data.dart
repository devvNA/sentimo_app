import 'package:equatable/equatable.dart';

/// Represents user's journaling streak information
class StreakData extends Equatable {
  /// Current consecutive days with at least one entry or check-in
  final int currentStreak;

  /// Highest streak ever achieved by the user
  final int longestStreak;

  /// Date of the last journal entry or check-in
  final DateTime? lastEntryDate;

  /// List of milestone days achieved (e.g., [7, 30, 60, 90])
  final List<int> achievedMilestones;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastEntryDate,
    this.achievedMilestones = const [],
  });

  /// Creates an empty StreakData (for new users)
  const StreakData.empty()
    : currentStreak = 0,
      longestStreak = 0,
      lastEntryDate = null,
      achievedMilestones = const [];

  /// Creates StreakData from JSON
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastEntryDate: json['last_entry_date'] != null
          ? DateTime.parse(json['last_entry_date'] as String)
          : null,
      achievedMilestones: json['achieved_milestones'] != null
          ? List<int>.from(json['achieved_milestones'] as List)
          : const [],
    );
  }

  /// Converts StreakData to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_entry_date': lastEntryDate?.toIso8601String(),
      'achieved_milestones': achievedMilestones,
    };
  }

  /// Returns true if the streak is active (entry within last 24 hours)
  bool get isActive {
    if (lastEntryDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastEntryDate!);
    return difference.inHours < 24;
  }

  /// Returns true if the streak has expired (no entry for 24+ hours)
  bool get isExpired {
    if (lastEntryDate == null) return currentStreak == 0;
    final now = DateTime.now();
    final difference = now.difference(lastEntryDate!);
    return difference.inHours >= 24 && currentStreak > 0;
  }

  /// Returns the next milestone to achieve
  int? get nextMilestone {
    const milestones = [7, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (!achievedMilestones.contains(milestone) &&
          currentStreak < milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Returns progress towards next milestone (0.0 to 1.0)
  double get progressToNextMilestone {
    final next = nextMilestone;
    if (next == null) return 1.0;
    return currentStreak / next;
  }

  /// Returns true if a new milestone was just reached
  bool hasReachedMilestone(int milestone) {
    return currentStreak >= milestone &&
        !achievedMilestones.contains(milestone);
  }

  /// Creates a copy with updated values
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastEntryDate,
    List<int>? achievedMilestones,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
    );
  }

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    lastEntryDate,
    achievedMilestones,
  ];
}
