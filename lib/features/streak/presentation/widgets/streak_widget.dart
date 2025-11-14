import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/bloc.dart';

/// Widget displaying current streak on home page
class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoading) {
          return _buildLoadingState();
        }

        if (state is StreakLoaded) {
          return _buildLoadedState(context, state);
        }

        if (state is StreakMilestoneReached) {
          return _buildLoadedState(
            context,
            StreakLoaded(state.streakData),
            showMilestone: true,
          );
        }

        // Initial or error state
        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Loading streak...',
            style: TextStyle(fontSize: 14, color: AppTheme.darkTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Your Streak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Journal daily to build your streak',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    StreakLoaded state, {
    bool showMilestone = false,
  }) {
    final currentStreak = state.currentStreak;
    final longestStreak = state.longestStreak;
    final nextMilestone = state.nextMilestone;
    final daysUntilNext = state.daysUntilNextMilestone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.brightBlue.withOpacity(0.2),
            AppTheme.mintGreen.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showMilestone
              ? Colors.amber.withOpacity(0.5)
              : AppTheme.brightBlue.withOpacity(0.3),
          width: showMilestone ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Flame icon with animation
          Stack(
            alignment: Alignment.center,
            children: [
              if (showMilestone)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withOpacity(0.2),
                  ),
                ),
              Text('🔥', style: TextStyle(fontSize: showMilestone ? 36 : 32)),
            ],
          ),

          const SizedBox(width: 16),

          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentStreak == 1 ? 'day' : 'days',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (nextMilestone != null && daysUntilNext != null)
                  Text(
                    '$daysUntilNext more ${daysUntilNext == 1 ? 'day' : 'days'} to $nextMilestone day milestone',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkTextSecondary,
                    ),
                  )
                else
                  const Text(
                    'All milestones achieved! 🎉',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mintGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // Longest streak badge
          if (longestStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Best',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.darkTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$longestStreak',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
