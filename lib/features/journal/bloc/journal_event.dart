import 'package:equatable/equatable.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class JournalLoadRequested extends JournalEvent {
  const JournalLoadRequested();
}

class JournalRefreshRequested extends JournalEvent {
  const JournalRefreshRequested();
}

class JournalCreateRequested extends JournalEvent {
  final String content;

  const JournalCreateRequested(this.content);

  @override
  List<Object?> get props => [content];
}

class JournalCreateRequestedWithSentiment extends JournalEvent {
  final String content;
  final String? sentimentLabel;
  final double? sentimentScore;
  final List<String>? sentimentTags;
  final DateTime? createdAt;

  const JournalCreateRequestedWithSentiment({
    required this.content,
    this.sentimentLabel,
    this.sentimentScore,
    this.sentimentTags,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    content,
    sentimentLabel,
    sentimentScore,
    sentimentTags,
    createdAt,
  ];
}

class JournalUpdateRequested extends JournalEvent {
  final String id;
  final String content;

  const JournalUpdateRequested({required this.id, required this.content});

  @override
  List<Object?> get props => [id, content];
}

class JournalDeleteRequested extends JournalEvent {
  final String id;

  const JournalDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class JournalSentimentUpdateRequested extends JournalEvent {
  final String id;
  final String sentimentLabel;
  final double? sentimentScore;
  final List<String>? sentimentTags;

  const JournalSentimentUpdateRequested({
    required this.id,
    required this.sentimentLabel,
    this.sentimentScore,
    this.sentimentTags,
  });

  @override
  List<Object?> get props => [
    id,
    sentimentLabel,
    sentimentScore,
    sentimentTags,
  ];
}

class JournalEntryFavoriteToggled extends JournalEvent {
  final String entryId;
  final bool isFavorite;

  const JournalEntryFavoriteToggled({
    required this.entryId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [entryId, isFavorite];
}
