import 'package:equatable/equatable.dart';

import '../../../core/entities/quick_checkin.dart';

/// Base class for quick check-in states
abstract class QuickCheckInState extends Equatable {
  const QuickCheckInState();

  @override
  List<Object?> get props => [];
}

/// Initial state when quick check-in is first created
class QuickCheckInInitial extends QuickCheckInState {
  const QuickCheckInInitial();
}

/// State when check-in is being submitted
class QuickCheckInSubmitting extends QuickCheckInState {
  const QuickCheckInSubmitting();
}

/// State when check-in has been successfully submitted
class QuickCheckInSuccess extends QuickCheckInState {
  final QuickCheckIn checkIn;

  const QuickCheckInSuccess(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}

/// State when check-ins are being loaded
class QuickCheckInsLoading extends QuickCheckInState {
  const QuickCheckInsLoading();
}

/// State when check-ins have been successfully loaded
class QuickCheckInsLoaded extends QuickCheckInState {
  final List<QuickCheckIn> checkIns;
  final bool hasMore;

  const QuickCheckInsLoaded({required this.checkIns, this.hasMore = false});

  @override
  List<Object?> get props => [checkIns, hasMore];

  /// Get total count of check-ins
  int get count => checkIns.length;

  /// Check if list is empty
  bool get isEmpty => checkIns.isEmpty;

  /// Create a copy with updated values
  QuickCheckInsLoaded copyWith({List<QuickCheckIn>? checkIns, bool? hasMore}) {
    return QuickCheckInsLoaded(
      checkIns: checkIns ?? this.checkIns,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// State when a check-in is being deleted
class QuickCheckInDeleting extends QuickCheckInState {
  final String checkInId;

  const QuickCheckInDeleting(this.checkInId);

  @override
  List<Object?> get props => [checkInId];
}

/// State when a check-in has been successfully deleted
class QuickCheckInDeleted extends QuickCheckInState {
  final String checkInId;

  const QuickCheckInDeleted(this.checkInId);

  @override
  List<Object?> get props => [checkInId];
}

/// State when an error occurs
class QuickCheckInError extends QuickCheckInState {
  final String message;
  final QuickCheckInState? previousState;

  const QuickCheckInError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
