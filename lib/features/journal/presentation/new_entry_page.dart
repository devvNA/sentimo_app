import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/entities/journal_entry.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/sentiment_service.dart';
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

  // Sentiment analysis state
  bool _isAnalyzing = false;
  SentimentLabel? _analyzedSentiment;
  double? _analyzedScore;
  List<String>? _analyzedTags;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    if (_contentController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write at least 10 characters to analyze'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analyzedSentiment = null;
      _analyzedScore = null;
      _analyzedTags = null;
    });

    try {
      final sentimentService = context.read<SentimentService>();
      final result = await sentimentService.analyzeSentimentComplete(
        _contentController.text.trim(),
      );

      setState(() {
        _analyzedSentiment = result['sentiment'] as SentimentLabel;
        _analyzedScore = result['score'] as double;
        _analyzedTags = result['tags'] as List<String>;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Create journal entry request with sentiment data
      context.read<JournalBloc>().add(
            JournalCreateRequestedWithSentiment(
              content: _contentController.text.trim(),
              sentimentLabel: _analyzedSentiment?.name,
              sentimentScore: _analyzedScore,
              sentimentTags: _analyzedTags,
            ),
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

  String _getSentimentMoodText() {
    switch (_analyzedSentiment) {
      case SentimentLabel.positive:
        return 'Mostly Positive';
      case SentimentLabel.negative:
        return 'Mostly Negative';
      case SentimentLabel.mixed:
        return 'Mixed Emotions';
      case SentimentLabel.neutral:
      default:
        return 'Neutral';
    }
  }

  Color _getSentimentColor() {
    switch (_analyzedSentiment) {
      case SentimentLabel.positive:
        return const Color(0xFF10B981);
      case SentimentLabel.negative:
        return const Color(0xFFEF4444);
      case SentimentLabel.mixed:
        return const Color(0xFFF59E0B);
      case SentimentLabel.neutral:
      default:
        return const Color(0xFF6B7280);
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
                content: const Text('Entry saved successfully!'),
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
          final isSaving = state is JournalCreating;

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
                      enabled: !isSaving && !_isAnalyzing,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            if (_analyzedSentiment == null && !_isAnalyzing) ...[
                              SizedBox(
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: _handleAnalyze,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.brightBlue,
                                    side: BorderSide(
                                      color: AppTheme.brightBlue,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.auto_awesome, size: 24),
                                  label: const Text(
                                    'Analyze Sentiment',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (_isAnalyzing) ...[
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.brightBlue,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Analyzing your emotions...',
                                      style: TextStyle(
                                        color: AppTheme.darkText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (_analyzedSentiment != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Overall Mood: ${_getSentimentMoodText()}',
                                    style: TextStyle(
                                      color: AppTheme.darkText,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (_analyzedScore != null)
                                    Text(
                                      '${_analyzedScore!.toStringAsFixed(1)}/10',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              if (_analyzedScore != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _analyzedScore! / 10,
                                    minHeight: 8,
                                    backgroundColor: AppTheme.darkBackground,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getSentimentColor(),
                                    ),
                                  ),
                                ),
                              ],
                              if (_analyzedTags != null && _analyzedTags!.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _analyzedTags!
                                      .map((tag) => _buildSentimentChip(tag))
                                      .toList(),
                                ),
                              ],
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (isSaving || _isAnalyzing) ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.brightBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isSaving
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
                ),
              ],
            ),
          );
        },
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
                  isSelected: _selectedNavIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'New Entry',
                  index: 1,
                  isSelected: _selectedNavIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 2,
                  isSelected: _selectedNavIndex == 2,
                ),
              ],
            ),
          ),
        ),
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
        label.substring(0, 1).toUpperCase() + label.substring(1),
        style: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
