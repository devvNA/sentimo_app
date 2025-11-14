import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quick_checkin_repository.dart';
import '../../../data/repositories/streak_repository.dart';
import 'quick_checkin_event.dart';
import 'quick_checkin_state.dart';

/// BLoC for managing quick check-in state and logic
class QuickCheckInBloc extends Bloc<QuickCheckInEvent, QuickCheckInState> {
  final QuickCheckInRepository _checkInRepository;
  final StreakRepository _streakRepository;

  QuickCheckInBloc({
    required QuickCheckInRepository checkInRepository,
    required StreakRepository streakRepository,
  }) : _checkInRepository = checkInRepository,
       _streakRepository = streakRepository,
       super(const QuickCheckInInitial()) {
    on<SubmitEmojiCheckIn>(_onSubmitEmojiCheckIn);
    on<SubmitRatingCheckIn>(_onSubmitRatingCheckIn);
    on<LoadCheckIns>(_onLoadCheckIns);
    on<RefreshCheckIns>(_onRefreshCheckIns);
    on<DeleteCheckIn>(_onDeleteCheckIn);
  }

  /// Handle submitting emoji check-in
  Future<void> _onSubmitEmojiCheckIn(
    SubmitEmojiCheckIn event,
    Emitter<QuickCheckInState> emit,
  ) async {
    try {
      log('✍️ [QuickCheckInBloc] Submitting emoji check-in: ${event.emoji}');

      // Validate note length if provided
      if (event.note != null && event.note!.length > 100) {
        emit(
          const QuickCheckInError(
            message: 'Note must be 100 characters or less.',
          ),
        );
        return;
      }

      emit(const QuickCheckInSubmitting());

      // Create check-in
      final checkIn = await _checkInRepository.createEmojiCheckIn(
        emoji: event.emoji,
        note: event.note,
      );

      log('✅ [QuickCheckInBloc] Emoji check-in submitted: ${checkIn.id}');

      // Update streak after successful check-in
      try {
        await _streakRepository.updateStreak();
        log('🔥 [QuickCheckInBloc] Streak updated after check-in');
      } catch (e) {
        log('⚠️ [QuickCheckInBloc] Failed to update streak: $e');
        // Don't fail the check-in if streak update fails
      }

      emit(QuickCheckInSuccess(checkIn));

      // Auto-transition back to initial state after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const QuickCheckInInitial());
    } catch (e) {
      log('❌ [QuickCheckInBloc] Error submitting emoji check-in: $e');

      emit(
        QuickCheckInError(
          message: 'Failed to submit check-in. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle submitting rating check-in
  Future<void> _onSubmitRatingCheckIn(
    SubmitRatingCheckIn event,
    Emitter<QuickCheckInState> emit,
  ) async {
    try {
      log('✍️ [QuickCheckInBloc] Submitting rating check-in: ${event.rating}');

      // Validate rating
      if (event.rating < 1 || event.rating > 5) {
        emit(
          const QuickCheckInError(message: 'Rating must be between 1 and 5.'),
        );
        return;
      }

      // Validate note length if provided
      if (event.note != null && event.note!.length > 100) {
        emit(
          const QuickCheckInError(
            message: 'Note must be 100 characters or less.',
          ),
        );
        return;
      }

      emit(const QuickCheckInSubmitting());

      // Create check-in
      final checkIn = await _checkInRepository.createRatingCheckIn(
        rating: event.rating,
        note: event.note,
      );

      log('✅ [QuickCheckInBloc] Rating check-in submitted: ${checkIn.id}');

      // Update streak after successful check-in
      try {
        await _streakRepository.updateStreak();
        log('🔥 [QuickCheckInBloc] Streak updated after check-in');
      } catch (e) {
        log('⚠️ [QuickCheckInBloc] Failed to update streak: $e');
        // Don't fail the check-in if streak update fails
      }

      emit(QuickCheckInSuccess(checkIn));

      // Auto-transition back to initial state after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const QuickCheckInInitial());
    } catch (e) {
      log('❌ [QuickCheckInBloc] Error submitting rating check-in: $e');

      emit(
        QuickCheckInError(
          message: 'Failed to submit check-in. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle loading check-ins
  Future<void> _onLoadCheckIns(
    LoadCheckIns event,
    Emitter<QuickCheckInState> emit,
  ) async {
    try {
      log(
        '📋 [QuickCheckInBloc] Loading check-ins: limit=${event.limit}, offset=${event.offset}',
      );

      emit(const QuickCheckInsLoading());

      final checkIns = await _checkInRepository.getCheckIns(
        limit: event.limit,
        offset: event.offset,
      );

      log('✅ [QuickCheckInBloc] Loaded ${checkIns.length} check-ins');

      // Check if there might be more check-ins
      final hasMore = checkIns.length >= event.limit;

      emit(QuickCheckInsLoaded(checkIns: checkIns, hasMore: hasMore));
    } catch (e) {
      log('❌ [QuickCheckInBloc] Error loading check-ins: $e');

      emit(
        QuickCheckInError(
          message: 'Failed to load check-ins. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle refreshing check-ins
  Future<void> _onRefreshCheckIns(
    RefreshCheckIns event,
    Emitter<QuickCheckInState> emit,
  ) async {
    try {
      log('🔄 [QuickCheckInBloc] Refreshing check-ins...');

      final checkIns = await _checkInRepository.getCheckIns(limit: 50);

      log('✅ [QuickCheckInBloc] Check-ins refreshed');

      emit(
        QuickCheckInsLoaded(checkIns: checkIns, hasMore: checkIns.length >= 50),
      );
    } catch (e) {
      log('❌ [QuickCheckInBloc] Error refreshing check-ins: $e');

      emit(
        QuickCheckInError(
          message: 'Failed to refresh check-ins. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle deleting a check-in
  Future<void> _onDeleteCheckIn(
    DeleteCheckIn event,
    Emitter<QuickCheckInState> emit,
  ) async {
    try {
      log('🗑️ [QuickCheckInBloc] Deleting check-in: ${event.checkInId}');

      emit(QuickCheckInDeleting(event.checkInId));

      await _checkInRepository.deleteCheckIn(event.checkInId);

      log('✅ [QuickCheckInBloc] Check-in deleted');

      emit(QuickCheckInDeleted(event.checkInId));

      // Reload check-ins after deletion
      add(const RefreshCheckIns());
    } catch (e) {
      log('❌ [QuickCheckInBloc] Error deleting check-in: $e');

      emit(
        QuickCheckInError(
          message: 'Failed to delete check-in. Please try again.',
          previousState: state,
        ),
      );
    }
  }
}
