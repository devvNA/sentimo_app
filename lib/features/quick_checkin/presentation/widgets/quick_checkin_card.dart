import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/entities/quick_checkin.dart';
import '../../../../core/theme/app_theme.dart';

/// Compact card for displaying quick check-ins
class QuickCheckInCard extends StatelessWidget {
  final QuickCheckIn checkIn;
  final VoidCallback? onDelete;

  const QuickCheckInCard({super.key, required this.checkIn, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSentimentColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji or rating display
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getSentimentColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                checkIn.displayValue,
                style: TextStyle(
                  fontSize: checkIn.type == CheckInType.emoji ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                Text(
                  DateFormat('MMM d, h:mm a').format(checkIn.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (checkIn.hasNote) ...[
                  const SizedBox(height: 6),
                  Text(
                    checkIn.note!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: AppTheme.darkTextSecondary,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Color _getSentimentColor() {
    final sentiment = checkIn.sentimentLabel;
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
}
