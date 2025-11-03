import 'package:equatable/equatable.dart';

enum SentimentLabel {
  positive,
  negative,
  neutral,
  mixed;

  static SentimentLabel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'positive':
        return SentimentLabel.positive;
      case 'negative':
        return SentimentLabel.negative;
      case 'mixed':
        return SentimentLabel.mixed;
      default:
        return SentimentLabel.neutral;
    }
  }

  String toDisplayString() {
    switch (this) {
      case SentimentLabel.positive:
        return 'Positive';
      case SentimentLabel.negative:
        return 'Negative';
      case SentimentLabel.mixed:
        return 'Mixed';
      case SentimentLabel.neutral:
        return 'Neutral';
    }
  }
}

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String content;
  final SentimentLabel? sentimentLabel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    this.sentimentLabel,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      sentimentLabel: json['sentiment_label'] != null
          ? SentimentLabel.fromString(json['sentiment_label'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'sentiment_label': sentimentLabel?.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? content,
    SentimentLabel? sentimentLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      sentimentLabel: sentimentLabel ?? this.sentimentLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, content, sentimentLabel, createdAt, updatedAt];
}
