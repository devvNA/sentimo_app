import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dashed_border_container.dart';
import '../../../core/widgets/journal_entry_card.dart';
import '../../journal/bloc/journal_bloc.dart';
import '../../journal/bloc/journal_event.dart';
import '../../journal/bloc/journal_state.dart';
import '../../journal/presentation/new_entry_page.dart';
import '../../profile/presentation/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(const JournalLoadRequested());
  }

  Future<void> _onRefresh() async {
    context.read<JournalBloc>().add(const JournalRefreshRequested());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Your Journal')),
      body: BlocConsumer<JournalBloc, JournalState>(
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
          }
        },
        builder: (context, state) {
          if (state is JournalLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.softBlue),
            );
          }

          if (state is JournalEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: DashedBorderContainer(
                  color: AppTheme.darkTextSecondary.withValues(alpha: 0.4),
                  strokeWidth: 2.0,
                  dashWidth: 10.0,
                  dashSpace: 6.0,
                  borderRadius: 20.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 60,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 72,
                          color: AppTheme.darkTextSecondary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Your Journal is Empty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the \'+\' button to write your first entry\nand start your journey of reflection.',
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
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.brightBlue,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return JournalEntryCard(
                    entry: entry,
                    onTap: () {
                      // Navigate to edit mode
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<JournalBloc>(),
                            child: NewEntryPage(entry: entry),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<JournalBloc>(),
                child: const NewEntryPage(),
              ),
            ),
          );
        },
        backgroundColor: AppTheme.brightBlue,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1,
              width: double.infinity,
              color: AppTheme.darkTextSecondary.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
