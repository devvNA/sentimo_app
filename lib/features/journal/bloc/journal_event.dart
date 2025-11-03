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

class JournalUpdateRequested extends JournalEvent {
  final String id;
  final String content;

  const JournalUpdateRequested({
    required this.id,
    required this.content,
  });

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

  const JournalSentimentUpdateRequested({
    required this.id,
    required this.sentimentLabel,
  });

  @override
  List<Object?> get props => [id, sentimentLabel];
}
