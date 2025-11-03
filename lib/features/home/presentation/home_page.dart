import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<JournalBloc>(),
            child: const NewEntryPage(),
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
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
                child: Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.darkTextSecondary.withValues(alpha: 0.3),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: AppTheme.darkTextSecondary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your Journal is Empty',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the \'+\' button to write your first entry\nand start your journey of reflection.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                  return JournalEntryCard(entry: entry, onTap: () {});
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            color: isSelected ? AppTheme.brightBlue : AppTheme.darkTextSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.brightBlue : AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
