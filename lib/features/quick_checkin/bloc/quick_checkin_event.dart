import 'package:equatable/equatable.dart';

/// Base class for quick check-in events
abstract class QuickCheckInEvent extends Equatable {
  const QuickCheckInEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit an emoji-based check-in
class SubmitEmojiCheckIn extends QuickCheckInEvent {
  final String emoji;
  final String? note;

  const SubmitEmojiCheckIn({required this.emoji, this.note});

  @override
  List<Object?> get props => [emoji, note];
}

/// Event to submit a rating-based check-in
class SubmitRatingCheckIn extends QuickCheckInEvent {
  final int rating;
  final String? note;

  const SubmitRatingCheckIn({required this.rating, this.note});

  @override
  List<Object?> get props => [rating, note];
}

/// Event to load check-ins for the current user
class LoadCheckIns extends QuickCheckInEvent {
  final int limit;
  final int offset;

  const LoadCheckIns({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to refresh check-ins list
class RefreshCheckIns extends QuickCheckInEvent {
  const RefreshCheckIns();
}

/// Event to delete a check-in
class DeleteCheckIn extends QuickCheckInEvent {
  final String checkInId;

  const DeleteCheckIn(this.checkInId);

  @override
  List<Object?> get props => [checkInId];
}
