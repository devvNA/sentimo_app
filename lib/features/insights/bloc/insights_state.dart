import 'package:equatable/equatable.dart';

import '../../../core/entities/insights_data.dart';

/// Base class for insights states
abstract class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when insights is first created
class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

/// State when insights data is being loaded
class InsightsLoading extends InsightsState {
  final InsightsPeriod period;

  const InsightsLoading(this.period);

  @override
  List<Object?> get props => [period];
}

/// State when insights data has been successfully loaded
class InsightsLoaded extends InsightsState {
  final InsightsData data;
  final InsightsPeriod period;

  const InsightsLoaded({required this.data, required this.period});

  @override
  List<Object?> get props => [data, period];

  /// Check if there are any entries
  bool get hasEntries => data.hasEntries;

  /// Get total entry count
  int get totalCount => data.totalCount;

  /// Get predominant sentiment
  String get predominantSentiment => data.predominantSentiment;

  /// Create a copy with updated values
  InsightsLoaded copyWith({InsightsData? data, InsightsPeriod? period}) {
    return InsightsLoaded(
      data: data ?? this.data,
      period: period ?? this.period,
    );
  }
}

/// State when there are no entries for the selected period
class InsightsEmpty extends InsightsState {
  final String message;
  final InsightsPeriod period;

  const InsightsEmpty({required this.message, required this.period});

  @override
  List<Object?> get props => [message, period];
}

/// State when an error occurs
class InsightsError extends InsightsState {
  final String message;
  final InsightsPeriod? period;

  const InsightsError({required this.message, this.period});

  @override
  List<Object?> get props => [message, period];
}
