import 'package:equatable/equatable.dart';

/// Represents aggregated sentiment data for a specific date
/// Used by the calendar view to display mood patterns
class SentimentData extends Equatable {
  /// The predominant sentiment for the day (positive, negative, neutral)
  final String predominantSentiment;

  /// Total number of entries (journal + check-ins) for the day
  final int entryCount;

  /// List of all sentiment labels for the day (for calculating predominant)
  final List<String> sentimentLabels;

  const SentimentData({
    required this.predominantSentiment,
    required this.entryCount,
    required this.sentimentLabels,
  });

  /// Creates SentimentData from a list of sentiment labels
  factory SentimentData.fromLabels(List<String> labels) {
    if (labels.isEmpty) {
      return const SentimentData(
        predominantSentiment: 'neutral',
        entryCount: 0,
        sentimentLabels: [],
      );
    }

    // Count occurrences of each sentiment
    final sentimentCounts = <String, int>{};
    for (final label in labels) {
      sentimentCounts[label] = (sentimentCounts[label] ?? 0) + 1;
    }

    // Find the most frequent sentiment
    String predominant = 'neutral';
    int maxCount = 0;
    sentimentCounts.forEach((sentiment, count) {
      if (count > maxCount) {
        maxCount = count;
        predominant = sentiment;
      }
    });

    return SentimentData(
      predominantSentiment: predominant,
      entryCount: labels.length,
      sentimentLabels: labels,
    );
  }

  /// Creates SentimentData from JSON
  factory SentimentData.fromJson(Map<String, dynamic> json) {
    return SentimentData(
      predominantSentiment: json['predominant_sentiment'] as String,
      entryCount: json['entry_count'] as int,
      sentimentLabels: List<String>.from(json['sentiment_labels'] as List),
    );
  }

  /// Converts SentimentData to JSON
  Map<String, dynamic> toJson() {
    return {
      'predominant_sentiment': predominantSentiment,
      'entry_count': entryCount,
      'sentiment_labels': sentimentLabels,
    };
  }

  /// Returns true if there are any entries for this day
  bool get hasEntries => entryCount > 0;

  /// Returns the percentage of the predominant sentiment
  double get predominantPercentage {
    if (entryCount == 0) return 0.0;
    final count = sentimentLabels
        .where((s) => s == predominantSentiment)
        .length;
    return (count / entryCount) * 100;
  }

  @override
  List<Object?> get props => [
    predominantSentiment,
    entryCount,
    sentimentLabels,
  ];
}

/// Represents calendar data for a specific date
class CalendarDayData extends Equatable {
  /// The date for this calendar day
  final DateTime date;

  /// Sentiment data for this day (null if no entries)
  final SentimentData? sentimentData;

  const CalendarDayData({required this.date, this.sentimentData});

  /// Returns true if this day has any entries
  bool get hasEntries => sentimentData != null && sentimentData!.hasEntries;

  /// Returns the predominant sentiment or 'neutral' if no entries
  String get sentiment => sentimentData?.predominantSentiment ?? 'neutral';

  /// Returns the entry count or 0 if no entries
  int get entryCount => sentimentData?.entryCount ?? 0;

  @override
  List<Object?> get props => [date, sentimentData];
}
