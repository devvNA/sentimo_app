import 'package:equatable/equatable.dart';
import '../../../core/entities/journal_entry.dart';

abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

class JournalInitial extends JournalState {
  const JournalInitial();
}

class JournalLoading extends JournalState {
  const JournalLoading();
}

class JournalLoaded extends JournalState {
  final List<JournalEntry> entries;

  const JournalLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class JournalCreating extends JournalState {
  const JournalCreating();
}

class JournalCreated extends JournalState {
  final JournalEntry entry;

  const JournalCreated(this.entry);

  @override
  List<Object?> get props => [entry];
}

class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}

class JournalEmpty extends JournalState {
  const JournalEmpty();
}
