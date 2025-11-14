import 'package:equatable/equatable.dart';

/// Type of quick check-in
enum CheckInType {
  emoji,
  rating;

  static CheckInType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'emoji':
        return CheckInType.emoji;
      case 'rating':
        return CheckInType.rating;
      default:
        return CheckInType.emoji;
    }
  }
}

/// Represents a quick mood check-in entry
class QuickCheckIn extends Equatable {
  /// Unique identifier
  final String id;

  /// User ID who created the check-in
  final String userId;

  /// Type of check-in (emoji or rating)
  final CheckInType type;

  /// Value: emoji character (😄😊😐😔😢) or rating number (1-5)
  final String value;

  /// Optional brief note (max 100 characters)
  final String? note;

  /// Timestamp when check-in was created
  final DateTime createdAt;

  const QuickCheckIn({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    this.note,
    required this.createdAt,
  });

  /// Creates QuickCheckIn from JSON
  factory QuickCheckIn.fromJson(Map<String, dynamic> json) {
    return QuickCheckIn(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: CheckInType.fromString(json['type'] as String),
      value: json['value'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts QuickCheckIn to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'value': value,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Returns the sentiment label based on emoji or rating
  String get sentimentLabel {
    if (type == CheckInType.emoji) {
      // Map emoji to sentiment
      switch (value) {
        case '😄':
        case '😊':
          return 'positive';
        case '😐':
          return 'neutral';
        case '😔':
        case '😢':
          return 'negative';
        default:
          return 'neutral';
      }
    } else {
      // Map rating to sentiment
      final rating = int.tryParse(value) ?? 3;
      if (rating >= 4) return 'positive';
      if (rating == 3) return 'neutral';
      return 'negative';
    }
  }

  /// Returns a display-friendly value
  String get displayValue {
    if (type == CheckInType.emoji) {
      return value;
    } else {
      return '$value/5';
    }
  }

  /// Returns true if check-in has a note
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Creates a copy with updated values
  QuickCheckIn copyWith({
    String? id,
    String? userId,
    CheckInType? type,
    String? value,
    String? note,
    DateTime? createdAt,
  }) {
    return QuickCheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, type, value, note, createdAt];
}

/// Valid emoji values for check-ins
class CheckInEmojis {
  static const String veryHappy = '😄';
  static const String happy = '😊';
  static const String neutral = '😐';
  static const String sad = '😔';
  static const String verySad = '😢';

  static const List<String> all = [veryHappy, happy, neutral, sad, verySad];

  static bool isValid(String emoji) => all.contains(emoji);
}

/// Valid rating values for check-ins
class CheckInRatings {
  static const int min = 1;
  static const int max = 5;

  static bool isValid(int rating) => rating >= min && rating <= max;
}
