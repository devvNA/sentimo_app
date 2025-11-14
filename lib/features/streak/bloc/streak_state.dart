import 'package:equatable/equatable.dart';

import '../../../core/entities/streak_data.dart';

/// Base class for streak states
abstract class StreakState extends Equatable {
  const StreakState();

  @override
  List<Object?> get props => [];
}

/// Initial state when streak is first created
class StreakInitial extends StreakState {
  const StreakInitial();
}

/// State when streak data is being loaded
class StreakLoading extends StreakState {
  const StreakLoading();
}

/// State when streak data has been successfully loaded
class StreakLoaded extends StreakState {
  final StreakData streakData;

  const StreakLoaded(this.streakData);

  @override
  List<Object?> get props => [streakData];

  /// Get current streak count
  int get currentStreak => streakData.currentStreak;

  /// Get longest streak count
  int get longestStreak => streakData.longestStreak;

  /// Get achieved milestones
  List<int> get achievedMilestones => streakData.achievedMilestones;

  /// Check if user has an active streak
  bool get hasActiveStreak => streakData.currentStreak > 0;

  /// Get the next milestone to achieve
  int? get nextMilestone {
    const milestones = [7, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // All milestones achieved
  }

  /// Get days until next milestone
  int? get daysUntilNextMilestone {
    final next = nextMilestone;
    if (next == null) return null;
    return next - currentStreak;
  }

  /// Create a copy with updated streak data
  StreakLoaded copyWith({StreakData? streakData}) {
    return StreakLoaded(streakData ?? this.streakData);
  }
}

/// State when a milestone has been reached
class StreakMilestoneReached extends StreakState {
  final int milestone;
  final StreakData streakData;

  const StreakMilestoneReached({
    required this.milestone,
    required this.streakData,
  });

  @override
  List<Object?> get props => [milestone, streakData];

  /// Get congratulatory message based on milestone
  String get congratsMessage {
    switch (milestone) {
      case 7:
        return '🎉 Amazing! You\'ve journaled for a whole week!';
      case 30:
        return '🔥 Incredible! 30 days of consistent journaling!';
      case 60:
        return '⭐ Outstanding! 60 days streak achieved!';
      case 90:
        return '🏆 Phenomenal! 90 days of dedication!';
      case 180:
        return '💎 Legendary! Half a year of journaling!';
      case 365:
        return '👑 Extraordinary! A full year of journaling!';
      default:
        return '🎊 Congratulations on reaching $milestone days!';
    }
  }
}

/// State when streak has been reset due to expiry
class StreakReset extends StreakState {
  final StreakData streakData;
  final int previousStreak;

  const StreakReset({required this.streakData, required this.previousStreak});

  @override
  List<Object?> get props => [streakData, previousStreak];
}

/// State when an error occurs
class StreakError extends StreakState {
  final String message;

  const StreakError(this.message);

  @override
  List<Object?> get props => [message];
}
