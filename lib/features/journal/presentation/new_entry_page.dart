import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';
import '../../profile/presentation/profile_page.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final int _selectedNavIndex = 1;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<JournalBloc>().add(
            JournalCreateRequested(_contentController.text.trim()),
          );
    }
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex) return;

    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final today = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(today),
        centerTitle: true,
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state is JournalCreated) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Entry saved! Analyzing sentiment...'),
                backgroundColor: AppTheme.brightBlue,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is JournalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isCreating = state is JournalCreating;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      autofocus: true,
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        hintStyle: TextStyle(
                          color: AppTheme.darkTextSecondary.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please write something';
                        }
                        if (value.trim().length < 10) {
                          return 'Entry must be at least 10 characters';
                        }
                        return null;
                      },
                      enabled: !isCreating,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.brightBlue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppTheme.brightBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI will analyze your emotions after saving',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isCreating ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brightBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isCreating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Entry',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'New Entry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
