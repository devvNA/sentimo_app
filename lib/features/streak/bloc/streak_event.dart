import 'package:equatable/equatable.dart';

/// Base class for streak events
abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load streak data for the current user
class LoadStreak extends StreakEvent {
  const LoadStreak();
}

/// Event to update streak after a new journal entry or check-in
class UpdateStreak extends StreakEvent {
  const UpdateStreak();
}

/// Event to check if streak has expired (called on app launch)
class CheckStreakExpiry extends StreakEvent {
  const CheckStreakExpiry();
}

/// Event to refresh streak data
class RefreshStreak extends StreakEvent {
  const RefreshStreak();
}

/// Event to retry failed streak operation
class RetryStreakOperation extends StreakEvent {
  const RetryStreakOperation();
}
