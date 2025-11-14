import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/entities/journal_entry.dart';
import '../../../../core/theme/app_theme.dart';
import 'favorite_button.dart';

/// Card for displaying journal entry with favorite button
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSentimentColor(
              entry.sentimentLabel?.name ?? 'neutral',
            ).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and favorite button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(entry.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(entry.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (entry.sentimentLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSentimentColor(
                            entry.sentimentLabel!.name,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getSentimentEmoji(entry.sentimentLabel!.name),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    if (onFavoriteToggle != null) ...[
                      const SizedBox(width: 8),
                      FavoriteButton(
                        isFavorite: entry.isFavorite,
                        onPressed: onFavoriteToggle!,
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              entry.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkText,
                height: 1.5,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),

            // Tags if available
            if (entry.sentimentTags != null && entry.sentimentTags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.sentimentTags!
                      .take(3)
                      .map((tag) => _buildTag(tag))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 11, color: AppTheme.darkTextSecondary),
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return AppTheme.mintGreen;
      case 'negative':
        return const Color(0xFFCF6B6B);
      case 'neutral':
      default:
        return AppTheme.darkTextSecondary;
    }
  }

  String _getSentimentEmoji(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😔';
      case 'neutral':
      default:
        return '😐';
    }
  }
}
