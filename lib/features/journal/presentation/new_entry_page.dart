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
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sentiment Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall Mood: Mostly Positive',
                            style: TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            '8.5/10',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.85,
                          minHeight: 8,
                          backgroundColor: AppTheme.darkBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.mintGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSentimentChip('Gratitude'),
                          _buildSentimentChip('Excitement'),
                          _buildSentimentChip('Optimism'),
                        ],
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildSentimentChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
