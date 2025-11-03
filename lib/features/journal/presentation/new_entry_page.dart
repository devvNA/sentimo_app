import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/entities/journal_entry.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/sentiment_service.dart';
import '../../profile/presentation/profile_page.dart';
import '../bloc/journal_bloc.dart';
import '../bloc/journal_event.dart';
import '../bloc/journal_state.dart';

class NewEntryPage extends StatefulWidget {
  final JournalEntry? entry; // Optional - for edit mode

  const NewEntryPage({super.key, this.entry});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final int _selectedIndex = 1;

  // Sentiment analysis state
  bool _isAnalyzing = false;
  SentimentLabel? _analyzedSentiment;
  double? _analyzedScore;
  List<String>? _analyzedTags;

  bool get _isEditMode => widget.entry != null;

  @override
  void initState() {
    super.initState();
    // Pre-populate data if editing
    if (_isEditMode) {
      _contentController.text = widget.entry!.content;

      // Load existing sentiment data
      _analyzedSentiment = widget.entry!.sentimentLabel;
      _analyzedScore = widget.entry!.sentimentScore;
      _analyzedTags = widget.entry!.sentimentTags;
    }
  }

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

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        log('💾 [NewEntryPage] Saving updated entry: ${widget.entry!.id}');
        
        // Update existing entry
        context.read<JournalBloc>().add(
          JournalUpdateRequested(
            id: widget.entry!.id,
            content: _contentController.text.trim(),
          ),
        );

        // Update sentiment if analyzed
        if (_analyzedSentiment != null) {
          log('   Including sentiment update: ${_analyzedSentiment!.name}');
          context.read<JournalBloc>().add(
            JournalSentimentUpdateRequested(
              id: widget.entry!.id,
              sentimentLabel: _analyzedSentiment!.name,
              sentimentScore: _analyzedScore,
              sentimentTags: _analyzedTags,
            ),
          );
        }
        
        // Wait a bit for the update to process
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          log('✅ [NewEntryPage] Navigating back to HomePage');
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Entry updated successfully!'),
              backgroundColor: AppTheme.brightBlue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        log('💾 [NewEntryPage] Saving new entry');
        
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
  }

  Future<void> _handleDelete() async {
    log('🗑️ [NewEntryPage] Delete confirmation dialog shown');
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete Entry',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this journal entry? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      log('✅ [NewEntryPage] Delete confirmed, deleting entry: ${widget.entry!.id}');
      context.read<JournalBloc>().add(JournalDeleteRequested(widget.entry!.id));
      Navigator.of(context).pop();
    } else {
      log('❌ [NewEntryPage] Delete cancelled by user');
    }
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
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
        return const Color.fromARGB(255, 252, 176, 35);
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
        title: Text(
          _isEditMode ? 'Edit Entry' : today,
          style: TextStyle(fontSize: 20),
        ),
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
                          color: AppTheme.darkTextSecondary.withValues(
                            alpha: 0.6,
                          ),
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
                          color: Color(0xFF101826),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 1.0,
                            color: AppTheme.darkTextSecondary.withValues(
                              alpha: 0.12,
                            ),
                          ),
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
                            // Always show Analyze button (unless loading)
                            if (!_isAnalyzing) ...[
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _handleAnalyze,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Color(0xFF122339),
                                    foregroundColor: AppTheme.brightBlue,
                                    side: BorderSide(
                                      color: AppTheme.brightBlue,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    size: 24,
                                  ),
                                  label: Text(
                                    _analyzedSentiment == null
                                        ? 'Analyze Sentiment'
                                        : 'Re-analyze Sentiment',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // Show loading state during analysis
                            if (_isAnalyzing) ...[
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.brightBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.brightBlue,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: AppTheme.brightBlue,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Analyzing your emotions...',
                                          style: TextStyle(
                                            color: AppTheme.brightBlue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // Show results below the button
                            if (_analyzedSentiment != null &&
                                !_isAnalyzing) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBackground.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getSentimentColor().withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          backgroundColor:
                                              AppTheme.darkBackground,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _getSentimentColor(),
                                              ),
                                        ),
                                      ),
                                    ],
                                    if (_analyzedTags != null &&
                                        _analyzedTags!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _analyzedTags!
                                            .map(
                                              (tag) => _buildSentimentChip(tag),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(thickness: 0.2, color: Colors.grey),
                            const SizedBox(height: 8),
                            // Show different buttons based on mode
                            if (_isEditMode) ...[
                              // Edit mode: Show 3 buttons (Delete, Edit Icon, Update)
                              Row(
                                children: [
                                  // Delete button
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFC82216),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.0,
                                          ),
                                        ),
                                      ),
                                      onPressed: (isSaving || _isAnalyzing)
                                          ? null
                                          : _handleDelete,
                                      child: const Icon(
                                        Icons.delete_forever,
                                        size: 28.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Update button
                                  Expanded(
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: (isSaving || _isAnalyzing)
                                            ? null
                                            : _handleSave,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.brightBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: isSaving
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check, size: 24),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Update',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Create mode: Show single Save button
                              SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (isSaving || _isAnalyzing)
                                      ? null
                                      : _handleSave,
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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
