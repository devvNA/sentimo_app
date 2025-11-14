import 'package:flutter/material.dart';

import '../../../../core/entities/insights_data.dart';
import '../../../../core/theme/app_theme.dart';

/// Cards showing sentiment percentages
class SentimentPercentageCards extends StatelessWidget {
  final InsightsData data;

  const SentimentPercentageCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            '😊',
            'Positive',
            data.positiveCount,
            data.positivePercentage,
            AppTheme.mintGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            '😐',
            'Neutral',
            data.neutralCount,
            data.neutralPercentage,
            AppTheme.darkTextSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            '😔',
            'Negative',
            data.negativeCount,
            data.negativePercentage,
            const Color(0xFFCF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    String emoji,
    String label,
    int count,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$count ${count == 1 ? 'entry' : 'entries'}',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
