import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/entities/journal_entry.dart';
import '../../../core/theme/app_theme.dart';

class EntryDetailPage extends StatelessWidget {
  final JournalEntry entry;

  const EntryDetailPage({
    super.key,
    required this.entry,
  });

  Color _getSentimentBgColor() {
    switch (entry.sentimentLabel) {
      case SentimentLabel.positive:
        return const Color(0xFF047857);
      case SentimentLabel.negative:
        return const Color(0xFF92400E);
      case SentimentLabel.mixed:
        return const Color(0xFF9A3412);
      case SentimentLabel.neutral:
      default:
        return const Color(0xFF1E3A8A);
    }
  }

  String _getSentimentMoodText() {
    switch (entry.sentimentLabel) {
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

  IconData _getSentimentIcon() {
    switch (entry.sentimentLabel) {
      case SentimentLabel.positive:
        return Icons.sentiment_satisfied_rounded;
      case SentimentLabel.negative:
        return Icons.sentiment_dissatisfied_rounded;
      case SentimentLabel.mixed:
        return Icons.sentiment_neutral_rounded;
      case SentimentLabel.neutral:
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(dateFormat.format(entry.createdAt.toLocal())),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content,
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            if (entry.sentimentLabel != null) ...[
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getSentimentBgColor(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getSentimentIcon(),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Overall Mood: ${_getSentimentMoodText()}',
                              style: TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        if (entry.sentimentScore != null)
                          Text(
                            '${entry.sentimentScore!.toStringAsFixed(1)}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (entry.sentimentScore != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: entry.sentimentScore! / 10,
                          minHeight: 8,
                          backgroundColor: AppTheme.darkBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSentimentBgColor(),
                          ),
                        ),
                      ),
                    ],
                    if (entry.sentimentTags != null &&
                        entry.sentimentTags!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.sentimentTags!
                            .map((tag) => _buildSentimentChip(tag))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.brightBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Analyzing emotions...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Created ${timeFormat.format(entry.createdAt.toLocal())}',
              style: TextStyle(
                color: AppTheme.darkTextSecondary,
                fontSize: 13,
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
}
