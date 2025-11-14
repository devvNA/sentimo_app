import 'package:equatable/equatable.dart';

/// Time period for insights
enum InsightsPeriod {
  week,
  month;

  String toDisplayString() {
    switch (this) {
      case InsightsPeriod.week:
        return 'This Week';
      case InsightsPeriod.month:
        return 'This Month';
    }
  }

  /// Returns the number of days in this period
  int get days {
    switch (this) {
      case InsightsPeriod.week:
        return 7;
      case InsightsPeriod.month:
        return 30;
    }
  }
}

/// Represents word frequency data
class WordFrequency extends Equatable {
  /// The word
  final String word;

  /// Number of times the word appears
  final int count;

  const WordFrequency({required this.word, required this.count});

  factory WordFrequency.fromJson(Map<String, dynamic> json) {
    return WordFrequency(
      word: json['word'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'word': word, 'count': count};
  }

  @override
  List<Object?> get props => [word, count];
}

/// Represents mood insights summary data
class InsightsData extends Equatable {
  /// Number of positive entries
  final int positiveCount;

  /// Number of negative entries
  final int negativeCount;

  /// Number of neutral entries
  final int neutralCount;

  /// Percentage of positive entries (0-100)
  final double positivePercentage;

  /// Percentage of negative entries (0-100)
  final double negativePercentage;

  /// Percentage of neutral entries (0-100)
  final double neutralPercentage;

  /// Top 3 most frequently used words
  final List<WordFrequency> topWords;

  /// Generated summary text
  final String summaryText;

  /// Start date of the period
  final DateTime startDate;

  /// End date of the period
  final DateTime endDate;

  const InsightsData({
    required this.positiveCount,
    required this.negativeCount,
    required this.neutralCount,
    required this.positivePercentage,
    required this.negativePercentage,
    required this.neutralPercentage,
    required this.topWords,
    required this.summaryText,
    required this.startDate,
    required this.endDate,
  });

  /// Creates empty InsightsData
  factory InsightsData.empty(DateTime startDate, DateTime endDate) {
    return InsightsData(
      positiveCount: 0,
      negativeCount: 0,
      neutralCount: 0,
      positivePercentage: 0.0,
      negativePercentage: 0.0,
      neutralPercentage: 0.0,
      topWords: const [],
      summaryText: 'No entries yet for this period. Start journaling!',
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Creates InsightsData from sentiment counts
  factory InsightsData.fromCounts({
    required int positiveCount,
    required int negativeCount,
    required int neutralCount,
    required List<WordFrequency> topWords,
    required DateTime startDate,
    required DateTime endDate,
    required InsightsPeriod period,
  }) {
    final total = positiveCount + negativeCount + neutralCount;

    if (total == 0) {
      return InsightsData.empty(startDate, endDate);
    }

    final positivePercentage = (positiveCount / total) * 100;
    final negativePercentage = (negativeCount / total) * 100;
    final neutralPercentage = (neutralCount / total) * 100;

    // Generate summary text
    String summaryText;
    final periodName = period == InsightsPeriod.week ? 'week' : 'month';

    if (positivePercentage > 50) {
      summaryText = 'This $periodName you were mostly positive! 🌟';
    } else if (negativePercentage > 50) {
      summaryText =
          'This $periodName was challenging. Remember, tough times pass. 💪';
    } else if (neutralPercentage > 50) {
      summaryText = 'This $periodName you maintained balance. ⚖️';
    } else {
      summaryText = 'This $periodName had mixed emotions. 🎭';
    }

    return InsightsData(
      positiveCount: positiveCount,
      negativeCount: negativeCount,
      neutralCount: neutralCount,
      positivePercentage: positivePercentage,
      negativePercentage: negativePercentage,
      neutralPercentage: neutralPercentage,
      topWords: topWords,
      summaryText: summaryText,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    return InsightsData(
      positiveCount: json['positive_count'] as int,
      negativeCount: json['negative_count'] as int,
      neutralCount: json['neutral_count'] as int,
      positivePercentage: (json['positive_percentage'] as num).toDouble(),
      negativePercentage: (json['negative_percentage'] as num).toDouble(),
      neutralPercentage: (json['neutral_percentage'] as num).toDouble(),
      topWords: (json['top_words'] as List)
          .map((w) => WordFrequency.fromJson(w as Map<String, dynamic>))
          .toList(),
      summaryText: json['summary_text'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive_count': positiveCount,
      'negative_count': negativeCount,
      'neutral_count': neutralCount,
      'positive_percentage': positivePercentage,
      'negative_percentage': negativePercentage,
      'neutral_percentage': neutralPercentage,
      'top_words': topWords.map((w) => w.toJson()).toList(),
      'summary_text': summaryText,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  /// Total number of entries
  int get totalCount => positiveCount + negativeCount + neutralCount;

  /// Returns true if there are any entries
  bool get hasEntries => totalCount > 0;

  /// Returns the predominant sentiment
  String get predominantSentiment {
    if (positiveCount > negativeCount && positiveCount > neutralCount) {
      return 'positive';
    } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }

  @override
  List<Object?> get props => [
    positiveCount,
    negativeCount,
    neutralCount,
    positivePercentage,
    negativePercentage,
    neutralPercentage,
    topWords,
    summaryText,
    startDate,
    endDate,
  ];
}
