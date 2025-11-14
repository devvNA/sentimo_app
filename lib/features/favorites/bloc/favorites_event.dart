import 'package:equatable/equatable.dart';

/// Base class for favorites events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to toggle favorite status of an entry
class ToggleFavorite extends FavoritesEvent {
  final String entryId;
  final bool isFavorite;

  const ToggleFavorite({required this.entryId, required this.isFavorite});

  @override
  List<Object?> get props => [entryId, isFavorite];
}

/// Event to load all favorite entries
class LoadFavorites extends FavoritesEvent {
  final int limit;
  final int offset;

  const LoadFavorites({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to refresh favorites list
class RefreshFavorites extends FavoritesEvent {
  const RefreshFavorites();
}

/// Event to retry failed favorites operation
class RetryFavoritesOperation extends FavoritesEvent {
  const RetryFavoritesOperation();
}
