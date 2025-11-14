import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/insights_data.dart';
import '../../../data/repositories/journal_repository.dart';
import 'insights_event.dart';
import 'insights_state.dart';

/// BLoC for managing insights state and logic
class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final JournalRepository _journalRepository;

  InsightsBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(const InsightsInitial()) {
    on<LoadInsights>(_onLoadInsights);
    on<ChangePeriod>(_onChangePeriod);
    on<RefreshInsights>(_onRefreshInsights);
  }

  /// Handle loading insights for a specific period
  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<InsightsState> emit,
  ) async {
    try {
      log(
        '📊 [InsightsBloc] Loading insights for period: ${event.period.name}',
      );

      emit(InsightsLoading(event.period));

      // Fetch insights data from repository
      final insightsData = await _journalRepository.getInsightsForPeriod(
        period: event.period,
      );

      log(
        '✅ [InsightsBloc] Insights loaded: ${insightsData.totalCount} entries',
      );

      // Check if there are any entries
      if (!insightsData.hasEntries) {
        emit(
          InsightsEmpty(
            message: _getEmptyMessage(event.period),
            period: event.period,
          ),
        );
        return;
      }

      emit(InsightsLoaded(data: insightsData, period: event.period));
    } catch (e) {
      log('❌ [InsightsBloc] Error loading insights: $e');

      emit(
        InsightsError(
          message: 'Failed to load insights. Please try again.',
          period: event.period,
        ),
      );
    }
  }

  /// Handle changing the insights period
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<InsightsState> emit,
  ) async {
    log('📊 [InsightsBloc] Changing period to: ${event.period.name}');

    // Load insights for the new period
    add(LoadInsights(event.period));
  }

  /// Handle refreshing insights data
  Future<void> _onRefreshInsights(
    RefreshInsights event,
    Emitter<InsightsState> emit,
  ) async {
    try {
      // Get current period from state
      InsightsPeriod period = InsightsPeriod.week;

      if (state is InsightsLoaded) {
        period = (state as InsightsLoaded).period;
      } else if (state is InsightsEmpty) {
        period = (state as InsightsEmpty).period;
      } else if (state is InsightsError) {
        period = (state as InsightsError).period ?? InsightsPeriod.week;
      }

      log('🔄 [InsightsBloc] Refreshing insights for period: ${period.name}');

      // Reload insights
      add(LoadInsights(period));
    } catch (e) {
      log('❌ [InsightsBloc] Error refreshing insights: $e');

      emit(
        const InsightsError(
          message: 'Failed to refresh insights. Please try again.',
        ),
      );
    }
  }

  /// Get appropriate empty message based on period
  String _getEmptyMessage(InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.week:
        return 'No entries this week yet.\nStart journaling to see your insights! 📝';
      case InsightsPeriod.month:
        return 'No entries this month yet.\nStart journaling to see your insights! 📝';
    }
  }
}
