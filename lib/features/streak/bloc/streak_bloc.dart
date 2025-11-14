import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/error_logger.dart';
import '../../../data/repositories/streak_repository.dart';
import 'streak_event.dart';
import 'streak_state.dart';

/// BLoC for managing streak tracking state and logic
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final StreakRepository _streakRepository;

  StreakBloc({required StreakRepository streakRepository})
    : _streakRepository = streakRepository,
      super(const StreakInitial()) {
    on<LoadStreak>(_onLoadStreak);
    on<UpdateStreak>(_onUpdateStreak);
    on<CheckStreakExpiry>(_onCheckStreakExpiry);
    on<RefreshStreak>(_onRefreshStreak);
    on<RetryStreakOperation>(_onRetryStreakOperation);
  }

  /// Handle loading streak data
  Future<void> _onLoadStreak(
    LoadStreak event,
    Emitter<StreakState> emit,
  ) async {
    try {
      log('🔥 [StreakBloc] Loading streak data...');

      emit(const StreakLoading());

      final streakData = await _streakRepository.getStreakData();

      log(
        '✅ [StreakBloc] Streak loaded: current=${streakData.currentStreak}, longest=${streakData.longestStreak}',
      );

      emit(StreakLoaded(streakData));
    } catch (e, stackTrace) {
      ErrorLogger.logError('StreakBloc.LoadStreak', e, stackTrace: stackTrace);

      emit(StreakError(ErrorLogger.getUserFriendlyMessage(e)));
    }
  }

  /// Handle updating streak after new entry
  Future<void> _onUpdateStreak(
    UpdateStreak event,
    Emitter<StreakState> emit,
  ) async {
    try {
      log('🔥 [StreakBloc] Updating streak...');

      // Get current streak data before update
      final currentStreakData = await _streakRepository.getStreakData();
      final previousMilestones = currentStreakData.achievedMilestones;

      // Update streak
      final updatedStreakData = await _streakRepository.updateStreak();

      log('✅ [StreakBloc] Streak updated: ${updatedStreakData.currentStreak}');

      // Check if a new milestone was reached
      final newMilestones = updatedStreakData.achievedMilestones
          .where((m) => !previousMilestones.contains(m))
          .toList();

      if (newMilestones.isNotEmpty) {
        // Emit milestone reached state
        final latestMilestone = newMilestones.reduce((a, b) => a > b ? a : b);

        log('🎉 [StreakBloc] Milestone reached: $latestMilestone days!');

        emit(
          StreakMilestoneReached(
            milestone: latestMilestone,
            streakData: updatedStreakData,
          ),
        );

        // After showing milestone, emit loaded state
        await Future.delayed(const Duration(milliseconds: 500));
        emit(StreakLoaded(updatedStreakData));
      } else {
        // No milestone, just emit loaded state
        emit(StreakLoaded(updatedStreakData));
      }
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'StreakBloc.UpdateStreak',
        e,
        stackTrace: stackTrace,
      );

      emit(StreakError(ErrorLogger.getUserFriendlyMessage(e)));
    }
  }

  /// Handle checking streak expiry on app launch
  Future<void> _onCheckStreakExpiry(
    CheckStreakExpiry event,
    Emitter<StreakState> emit,
  ) async {
    try {
      log('🔍 [StreakBloc] Checking streak expiry...');

      emit(const StreakLoading());

      // Get current streak before check
      final currentStreakData = await _streakRepository.getStreakData();
      final previousStreak = currentStreakData.currentStreak;

      // Check and reset if expired
      final updatedStreakData = await _streakRepository.checkAndResetStreak();

      // Check if streak was reset
      if (updatedStreakData.currentStreak == 0 && previousStreak > 0) {
        log('⚠️ [StreakBloc] Streak was reset due to expiry');

        emit(
          StreakReset(
            streakData: updatedStreakData,
            previousStreak: previousStreak,
          ),
        );

        // After showing reset message, emit loaded state
        await Future.delayed(const Duration(milliseconds: 500));
        emit(StreakLoaded(updatedStreakData));
      } else {
        log('✅ [StreakBloc] Streak is still active');
        emit(StreakLoaded(updatedStreakData));
      }
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'StreakBloc.CheckStreakExpiry',
        e,
        stackTrace: stackTrace,
      );

      emit(StreakError(ErrorLogger.getUserFriendlyMessage(e)));
    }
  }

  /// Handle refreshing streak data
  Future<void> _onRefreshStreak(
    RefreshStreak event,
    Emitter<StreakState> emit,
  ) async {
    try {
      log('🔄 [StreakBloc] Refreshing streak data...');

      final streakData = await _streakRepository.getStreakData();

      log('✅ [StreakBloc] Streak refreshed');

      emit(StreakLoaded(streakData));
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        'StreakBloc.RefreshStreak',
        e,
        stackTrace: stackTrace,
      );

      emit(StreakError(ErrorLogger.getUserFriendlyMessage(e)));
    }
  }

  /// Handle retry of failed operation
  Future<void> _onRetryStreakOperation(
    RetryStreakOperation event,
    Emitter<StreakState> emit,
  ) async {
    log('🔄 [StreakBloc] Retrying failed operation');

    // Retry loading streak data
    add(const LoadStreak());
  }
}
