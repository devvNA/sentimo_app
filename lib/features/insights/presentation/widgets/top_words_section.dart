import 'package:flutter/material.dart';

import '../../../../core/entities/insights_data.dart';
import '../../../../core/theme/app_theme.dart';

/// Section showing top frequently used words
class TopWordsSection extends StatelessWidget {
  final List<WordFrequency> words;

  const TopWordsSection({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Words',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Most frequently used words in your entries',
            style: TextStyle(fontSize: 12, color: AppTheme.darkTextSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: words.map((word) => _buildWordChip(word)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(WordFrequency word) {
    // Calculate size based on frequency (relative to max)
    final maxCount = words.map((w) => w.count).reduce((a, b) => a > b ? a : b);
    final relativeSize = (word.count / maxCount);
    final fontSize = 14 + (relativeSize * 8); // 14-22px

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.brightBlue.withOpacity(0.2 + (relativeSize * 0.3)),
            AppTheme.mintGreen.withOpacity(0.2 + (relativeSize * 0.3)),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.brightBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word.word,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${word.count}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
