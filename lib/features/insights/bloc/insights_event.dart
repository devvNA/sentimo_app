import 'package:equatable/equatable.dart';

import '../../../core/entities/insights_data.dart';

/// Base class for insights events
abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load insights for a specific period
class LoadInsights extends InsightsEvent {
  final InsightsPeriod period;

  const LoadInsights(this.period);

  @override
  List<Object?> get props => [period];
}

/// Event to change the insights period (week/month)
class ChangePeriod extends InsightsEvent {
  final InsightsPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Event to refresh insights data
class RefreshInsights extends InsightsEvent {
  const RefreshInsights();
}

/// Event to retry failed insights operation
class RetryInsightsOperation extends InsightsEvent {
  const RetryInsightsOperation();
}
