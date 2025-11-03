import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/journal_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _journalRepository;

  JournalBloc(this._journalRepository) : super(const JournalInitial()) {
    on<JournalLoadRequested>(_onJournalLoadRequested);
    on<JournalRefreshRequested>(_onJournalRefreshRequested);
    on<JournalCreateRequested>(_onJournalCreateRequested);
    on<JournalUpdateRequested>(_onJournalUpdateRequested);
    on<JournalDeleteRequested>(_onJournalDeleteRequested);
    on<JournalSentimentUpdateRequested>(_onJournalSentimentUpdateRequested);
  }

  Future<void> _onJournalLoadRequested(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalLoading());
    try {
      final entries = await _journalRepository.getJournalEntries();
      
      if (entries.isEmpty) {
        emit(const JournalEmpty());
      } else {
        emit(JournalLoaded(entries));
      }
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalRefreshRequested(
    JournalRefreshRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final entries = await _journalRepository.getJournalEntries();
      
      if (entries.isEmpty) {
        emit(const JournalEmpty());
      } else {
        emit(JournalLoaded(entries));
      }
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalCreateRequested(
    JournalCreateRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalCreating());
    try {
      final entry = await _journalRepository.createJournalEntry(
        content: event.content,
      );
      
      emit(JournalCreated(entry));
      
      add(const JournalRefreshRequested());
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalUpdateRequested(
    JournalUpdateRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _journalRepository.updateJournalEntry(
        id: event.id,
        content: event.content,
      );
      
      add(const JournalRefreshRequested());
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalDeleteRequested(
    JournalDeleteRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _journalRepository.deleteJournalEntry(event.id);
      
      add(const JournalRefreshRequested());
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalSentimentUpdateRequested(
    JournalSentimentUpdateRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _journalRepository.updateJournalEntry(
        id: event.id,
        sentimentLabel: event.sentimentLabel,
      );
      
      add(const JournalRefreshRequested());
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  String _parseError(String error) {
    if (error.contains('User not authenticated')) {
      return 'Please sign in to access your journal';
    } else if (error.contains('permission denied')) {
      return 'You don\'t have permission to perform this action';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'An error occurred. Please try again.';
  }
}
