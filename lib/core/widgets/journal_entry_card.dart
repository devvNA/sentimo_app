import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entities/journal_entry.dart';
import '../theme/app_theme.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  Color _getSentimentColor() {
    switch (entry.sentimentLabel) {
      case SentimentLabel.positive:
        return AppTheme.mintGreen;
      case SentimentLabel.negative:
        return Colors.redAccent;
      case SentimentLabel.mixed:
        return Colors.orangeAccent;
      case SentimentLabel.neutral:
      default:
        return AppTheme.softBlue;
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
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (entry.sentimentLabel != null) ...[
                    Icon(
                      _getSentimentIcon(),
                      color: _getSentimentColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.sentimentLabel!.toDisplayString(),
                      style: TextStyle(
                        color: _getSentimentColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.pending_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Analyzing...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    dateFormat.format(entry.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
