import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/entities/journal_entry.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom sheet showing journal entries for a selected date
class DayEntriesSheet extends StatelessWidget {
  final DateTime date;
  final List<JournalEntry> entries;

  const DayEntriesSheet({super.key, required this.date, required this.entries});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkTextSecondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: AppTheme.darkTextSecondary,
                    ),
                  ],
                ),
              ),

              const Divider(
                color: AppTheme.darkTextSecondary,
                height: 1,
                thickness: 0.5,
              ),

              // Entries list
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildEntryCard(entries[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppTheme.darkTextSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No entries for this day',
            style: TextStyle(fontSize: 16, color: AppTheme.darkTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Container(
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
          // Header with time and sentiment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('h:mm a').format(entry.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // Favorite indicator
          if (entry.isFavorite)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Favorite',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
