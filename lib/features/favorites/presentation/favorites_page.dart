import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/journal_repository.dart';
import '../bloc/bloc.dart';
import 'widgets/journal_entry_card.dart';

/// Page showing favorite journal entries
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoritesBloc(journalRepository: context.read<JournalRepository>())
            ..add(const LoadFavorites()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
        body: BlocConsumer<FavoritesBloc, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FavoritesLoaded) {
              if (state.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FavoritesBloc>().add(const RefreshFavorites());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.favorites.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = state.favorites[index];
                    return JournalEntryCard(
                      entry: entry,
                      onFavoriteToggle: () {
                        context.read<FavoritesBloc>().add(
                          ToggleFavorite(
                            entryId: entry.id,
                            isFavorite: !entry.isFavorite,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: AppTheme.darkTextSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Star your favorite entries to find them here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
