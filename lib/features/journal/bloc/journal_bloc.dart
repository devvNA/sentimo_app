import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/entities/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../../data/services/sentiment_service.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _journalRepository;
  final SentimentService _sentimentService;

  JournalBloc(this._journalRepository, this._sentimentService) : super(const JournalInitial()) {
    on<JournalLoadRequested>(_onJournalLoadRequested);
    on<JournalRefreshRequested>(_onJournalRefreshRequested);
    on<JournalCreateRequested>(_onJournalCreateRequested);
    on<JournalCreateRequestedWithSentiment>(_onJournalCreateRequestedWithSentiment);
    on<JournalUpdateRequested>(_onJournalUpdateRequested);
    on<JournalDeleteRequested>(_onJournalDeleteRequested);
    on<JournalSentimentUpdateRequested>(_onJournalSentimentUpdateRequested);
  }

  Future<void> _onJournalLoadRequested(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    log('📚 [JournalBloc] Loading journal entries...');
    emit(const JournalLoading());
    try {
      final entries = await _journalRepository.getJournalEntries();
      
      if (entries.isEmpty) {
        log('📭 [JournalBloc] No entries found');
        emit(const JournalEmpty());
      } else {
        log('✅ [JournalBloc] Loaded ${entries.length} entries');
        emit(JournalLoaded(entries));
      }
    } catch (e) {
      log('❌ [JournalBloc] Load error: $e');
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalRefreshRequested(
    JournalRefreshRequested event,
    Emitter<JournalState> emit,
  ) async {
    log('🔄 [JournalBloc] Refreshing journal entries...');
    try {
      final entries = await _journalRepository.getJournalEntries();
      
      if (entries.isEmpty) {
        log('📭 [JournalBloc] No entries after refresh');
        emit(const JournalEmpty());
      } else {
        log('✅ [JournalBloc] Refreshed ${entries.length} entries');
        emit(JournalLoaded(entries));
      }
    } catch (e) {
      log('❌ [JournalBloc] Refresh error: $e');
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalCreateRequested(
    JournalCreateRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(const JournalCreating());
    try {
      // Step 1: Create the journal entry without sentiment
      final entry = await _journalRepository.createJournalEntry(
        content: event.content,
      );
      
      emit(JournalCreated(entry));
      
      // Step 2: Analyze sentiment in the background
      _analyzeSentimentAsync(entry.id, event.content);
      
      // Step 3: Refresh to show the new entry
      add(const JournalRefreshRequested());
    } catch (e) {
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalCreateRequestedWithSentiment(
    JournalCreateRequestedWithSentiment event,
    Emitter<JournalState> emit,
  ) async {
    log('✏️ [JournalBloc] Creating entry with sentiment...');
    log('   Content length: ${event.content.length} chars');
    log('   Sentiment: ${event.sentimentLabel ?? "none"}');
    emit(const JournalCreating());
    try {
      // Create the journal entry WITH sentiment data
      final entry = await _journalRepository.createJournalEntry(
        content: event.content,
        sentimentLabel: event.sentimentLabel,
      );
      
      // If we have sentiment score and tags, update them
      if (event.sentimentScore != null || event.sentimentTags != null) {
        log('   Updating sentiment score: ${event.sentimentScore}');
        log('   Updating sentiment tags: ${event.sentimentTags}');
        await _journalRepository.updateJournalEntry(
          id: entry.id,
          sentimentScore: event.sentimentScore,
          sentimentTags: event.sentimentTags,
        );
      }
      
      log('✅ [JournalBloc] Entry created successfully: ${entry.id}');
      emit(JournalCreated(entry));
      
      // Refresh to show the new entry
      add(const JournalRefreshRequested());
    } catch (e) {
      log('❌ [JournalBloc] Create error: $e');
      emit(JournalError(_parseError(e.toString())));
    }
  }

  void _analyzeSentimentAsync(String entryId, String content) async {
    try {
      // Analyze sentiment using Gemini API with complete data
      final sentimentData = await _sentimentService.analyzeSentimentComplete(content);
      
      // Update the entry with sentiment, score, and tags
      add(JournalSentimentUpdateRequested(
        id: entryId,
        sentimentLabel: (sentimentData['sentiment'] as SentimentLabel).name,
        sentimentScore: sentimentData['score'] as double,
        sentimentTags: sentimentData['tags'] as List<String>,
      ));
    } catch (e) {
      // Silent fail - entry will show "Analyzing..." state
    }
  }

  Future<void> _onJournalUpdateRequested(
    JournalUpdateRequested event,
    Emitter<JournalState> emit,
  ) async {
    log('📝 [JournalBloc] Updating entry: ${event.id}');
    log('   Content length: ${event.content.length} chars');
    try {
      await _journalRepository.updateJournalEntry(
        id: event.id,
        content: event.content,
      );
      
      log('✅ [JournalBloc] Entry updated successfully');
      add(const JournalRefreshRequested());
    } catch (e) {
      log('❌ [JournalBloc] Update error: $e');
      emit(JournalError(_parseError(e.toString())));
    }
  }

  Future<void> _onJournalDeleteRequested(
    JournalDeleteRequested event,
    Emitter<JournalState> emit,
  ) async {
    log('🗑️ [JournalBloc] Deleting entry: ${event.id}');
    try {
      await _journalRepository.deleteJournalEntry(event.id);
      
      log('✅ [JournalBloc] Entry deleted successfully');
      add(const JournalRefreshRequested());
    } catch (e) {
      log('❌ [JournalBloc] Delete error: $e');
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
        sentimentScore: event.sentimentScore,
        sentimentTags: event.sentimentTags,
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
