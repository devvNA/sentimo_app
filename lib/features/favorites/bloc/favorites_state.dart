import 'package:equatable/equatable.dart';

import '../../../core/entities/journal_entry.dart';

/// Base class for favorites states
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when favorites is first created
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// State when favorites are being loaded
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// State when favorites have been successfully loaded
class FavoritesLoaded extends FavoritesState {
  final List<JournalEntry> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];

  /// Get total count of favorites
  int get count => favorites.length;

  /// Check if favorites list is empty
  bool get isEmpty => favorites.isEmpty;

  /// Check if favorites list has entries
  bool get hasEntries => favorites.isNotEmpty;

  /// Create a copy with updated favorites list
  FavoritesLoaded copyWith({List<JournalEntry>? favorites}) {
    return FavoritesLoaded(favorites ?? this.favorites);
  }
}

/// State when a favorite is being toggled
class FavoriteToggling extends FavoritesState {
  final String entryId;
  final bool isFavorite;
  final FavoritesState previousState;

  const FavoriteToggling({
    required this.entryId,
    required this.isFavorite,
    required this.previousState,
  });

  @override
  List<Object?> get props => [entryId, isFavorite, previousState];
}

/// State when a favorite has been successfully toggled
class FavoriteToggled extends FavoritesState {
  final String entryId;
  final bool isFavorite;
  final JournalEntry updatedEntry;

  const FavoriteToggled({
    required this.entryId,
    required this.isFavorite,
    required this.updatedEntry,
  });

  @override
  List<Object?> get props => [entryId, isFavorite, updatedEntry];
}

/// State when an error occurs
class FavoritesError extends FavoritesState {
  final String message;
  final FavoritesState? previousState;

  const FavoritesError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
