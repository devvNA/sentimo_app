import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dashed_border_container.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../../data/repositories/quick_checkin_repository.dart';
import '../../../data/repositories/streak_repository.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../favorites/presentation/widgets/journal_entry_card.dart';
import '../../insights/presentation/insights_page.dart';
import '../../journal/bloc/journal_bloc.dart';
import '../../journal/bloc/journal_event.dart';
import '../../journal/bloc/journal_state.dart';
import '../../journal/presentation/new_entry_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../quick_checkin/bloc/bloc.dart';
import '../../quick_checkin/presentation/widgets/quick_checkin_button.dart';
import '../../search/bloc/bloc.dart';
import '../../search/presentation/widgets/filter_chip_bar.dart';
import '../../search/presentation/widgets/search_bar_widget.dart';
import '../../streak/bloc/bloc.dart';
import '../../streak/presentation/widgets/streak_milestone_dialog.dart';
import '../../streak/presentation/widgets/streak_widget.dart';

/// Enhanced HomePage with all new features integrated
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<JournalBloc>().add(const JournalLoadRequested());
    context.read<StreakBloc>().add(const CheckStreakExpiry());
  }

  Future<void> _onRefresh() async {
    context.read<JournalBloc>().add(const JournalRefreshRequested());
    context.read<StreakBloc>().add(const RefreshStreak());
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 1) {
      // Push NewEntryPage as modal
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<JournalBloc>(),
            child: const NewEntryPage(),
          ),
        ),
      );
    } else if (index == 2) {
      // Navigate to ProfilePage (replace)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<JournalBloc>(),
            child: const ProfilePage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              StreakBloc(streakRepository: context.read<StreakRepository>())
                ..add(const LoadStreak()),
        ),
        BlocProvider(
          create: (context) => QuickCheckInBloc(
            checkInRepository: context.read<QuickCheckInRepository>(),
            streakRepository: context.read<StreakRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => SearchFilterBloc(
            journalRepository: context.read<JournalRepository>(),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Journal'),
          actions: [
            // Calendar button
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CalendarPage()));
              },
              tooltip: 'Calendar',
            ),
            // Insights button
            IconButton(
              icon: const Icon(Icons.insights),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const InsightsPage()));
              },
              tooltip: 'Insights',
            ),
            // Favorites button
            IconButton(
              icon: const Icon(Icons.star_border),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                );
              },
              tooltip: 'Favorites',
            ),
          ],
        ),
        body: BlocListener<StreakBloc, StreakState>(
          listener: (context, state) {
            // Show milestone dialog when reached
            if (state is StreakMilestoneReached) {
              StreakMilestoneDialog.show(
                context,
                state.milestone,
                state.congratsMessage,
              );
            }
          },
          child: BlocConsumer<JournalBloc, JournalState>(
            listener: (context, state) {
              if (state is JournalError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is JournalCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Journal entry created successfully!'),
                    backgroundColor: AppTheme.mintGreen,
                  ),
                );
                // Update streak after creating entry
                context.read<StreakBloc>().add(const UpdateStreak());
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  // Streak widget header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: const StreakWidget(),
                  ),

                  // Search bar
                  const SearchBarWidget(),

                  const SizedBox(height: 12),

                  // Filter chip bar
                  const FilterChipBar(),

                  const SizedBox(height: 12),

                  // Content
                  Expanded(child: _buildContent(state)),
                ],
              );
            },
          ),
        ),
        floatingActionButton: const QuickCheckInButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                width: double.infinity,
                color: AppTheme.darkTextSecondary.withOpacity(0.12),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.book_outlined,
                      label: 'Journal',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.add_circle_outline,
                      label: 'New Entry',
                      index: 1,
                      isSelected: _selectedIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      index: 2,
                      isSelected: _selectedIndex == 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(JournalState state) {
    if (state is JournalLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.softBlue));
    }

    if (state is JournalEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: DashedBorderContainer(
            color: AppTheme.darkTextSecondary.withOpacity(0.4),
            strokeWidth: 2.0,
            dashWidth: 10.0,
            dashSpace: 6.0,
            borderRadius: 20.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 72,
                    color: AppTheme.darkTextSecondary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Your Journal is Empty',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap the Quick Check-in button to log your mood\nor create a full journal entry.',
                    style: TextStyle(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state is JournalLoaded) {
      return BlocBuilder<SearchFilterBloc, SearchFilterState>(
        builder: (context, searchState) {
          // Show filtered results if search is active
          if (searchState is SearchFilterLoaded) {
            return _buildFilteredList(searchState);
          }

          if (searchState is SearchFilterEmpty) {
            return _buildEmptySearchState(searchState);
          }

          // Show all entries by default
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.brightBlue,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.entries.length,
              itemBuilder: (context, index) {
                final entry = state.entries[index];
                return JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<JournalBloc>(),
                          child: NewEntryPage(entry: entry),
                        ),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    // Toggle favorite
                    context.read<JournalBloc>().add(
                      JournalEntryFavoriteToggled(
                        entryId: entry.id,
                        isFavorite: !entry.isFavorite,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFilteredList(SearchFilterLoaded state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.brightBlue,
      child: Column(
        children: [
          // Result count header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${state.results.length} ${state.results.length == 1 ? 'result' : 'results'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final entry = state.results[index];
                return JournalEntryCard(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<JournalBloc>(),
                          child: NewEntryPage(entry: entry),
                        ),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    context.read<JournalBloc>().add(
                      JournalEntryFavoriteToggled(
                        entryId: entry.id,
                        isFavorite: !entry.isFavorite,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(SearchFilterEmpty state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.darkTextSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: const TextStyle(
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? AppTheme.brightBlue
                : AppTheme.darkTextSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.brightBlue
                  : AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
