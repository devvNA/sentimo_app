import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/journal_entry_card.dart';
import '../../journal/bloc/journal_bloc.dart';
import '../../journal/bloc/journal_event.dart';
import '../../journal/bloc/journal_state.dart';
import '../../journal/presentation/new_entry_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(const JournalLoadRequested());
  }

  Future<void> _onRefresh() async {
    context.read<JournalBloc>().add(const JournalRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
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
              child: CircularProgressIndicator(
                color: AppTheme.softBlue,
              ),
            );
          }

          if (state is JournalEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journal entries yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your emotional journey\nby creating your first entry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is JournalLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.softBlue,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return JournalEntryCard(
                    entry: entry,
                    onTap: () {
                      // TODO: Navigate to entry detail page
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        backgroundColor: AppTheme.softBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
