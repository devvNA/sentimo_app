import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/journal_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC for managing favorites state and logic
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final JournalRepository _journalRepository;

  FavoritesBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(const FavoritesInitial()) {
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<RefreshFavorites>(_onRefreshFavorites);
  }

  /// Handle toggling favorite status
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      log(
        '⭐ [FavoritesBloc] Toggling favorite: ${event.entryId} to ${event.isFavorite}',
      );

      // Emit toggling state with optimistic update
      emit(
        FavoriteToggling(
          entryId: event.entryId,
          isFavorite: event.isFavorite,
          previousState: state,
        ),
      );

      // Toggle favorite in repository
      final updatedEntry = await _journalRepository.toggleFavorite(
        event.entryId,
        event.isFavorite,
      );

      log('✅ [FavoritesBloc] Favorite toggled successfully');

      // Emit toggled state
      emit(
        FavoriteToggled(
          entryId: event.entryId,
          isFavorite: event.isFavorite,
          updatedEntry: updatedEntry,
        ),
      );

      // If we're in favorites list view, refresh the list
      if (state is FavoritesLoaded || state is FavoriteToggled) {
        add(const RefreshFavorites());
      }
    } catch (e) {
      log('❌ [FavoritesBloc] Error toggling favorite: $e');

      // Rollback to previous state on error
      emit(
        FavoritesError(
          message: 'Failed to update favorite. Please try again.',
          previousState: state is FavoriteToggling
              ? (state as FavoriteToggling).previousState
              : state,
        ),
      );

      // Restore previous state after showing error
      if (state is FavoritesError &&
          (state as FavoritesError).previousState != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final previousState = (state as FavoritesError).previousState!;
        if (previousState is FavoritesLoaded) {
          emit(previousState);
        }
      }
    }
  }

  /// Handle loading favorites
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      log(
        '⭐ [FavoritesBloc] Loading favorites: limit=${event.limit}, offset=${event.offset}',
      );

      emit(const FavoritesLoading());

      final favorites = await _journalRepository.getFavoriteEntries(
        limit: event.limit,
        offset: event.offset,
      );

      log('✅ [FavoritesBloc] Loaded ${favorites.length} favorites');

      emit(FavoritesLoaded(favorites));
    } catch (e) {
      log('❌ [FavoritesBloc] Error loading favorites: $e');

      emit(
        FavoritesError(
          message: 'Failed to load favorites. Please try again.',
          previousState: state,
        ),
      );
    }
  }

  /// Handle refreshing favorites
  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      log('🔄 [FavoritesBloc] Refreshing favorites...');

      final favorites = await _journalRepository.getFavoriteEntries(limit: 50);

      log('✅ [FavoritesBloc] Favorites refreshed');

      emit(FavoritesLoaded(favorites));
    } catch (e) {
      log('❌ [FavoritesBloc] Error refreshing favorites: $e');

      emit(
        FavoritesError(
          message: 'Failed to refresh favorites. Please try again.',
          previousState: state,
        ),
      );
    }
  }
}
