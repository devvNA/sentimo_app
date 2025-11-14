import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/entities/insights_data.dart';
import '../../../../core/theme/app_theme.dart';

/// Pie chart showing sentiment distribution
class SentimentDistributionChart extends StatelessWidget {
  final InsightsData data;

  const SentimentDistributionChart({super.key, required this.data});

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
            'Sentiment Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),

                // Legend
                Expanded(flex: 2, child: _buildLegend()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];

    if (data.positiveCount > 0) {
      sections.add(
        PieChartSectionData(
          value: data.positivePercentage,
          title: '${data.positivePercentage.toStringAsFixed(0)}%',
          color: AppTheme.mintGreen,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
      );
    }

    if (data.neutralCount > 0) {
      sections.add(
        PieChartSectionData(
          value: data.neutralPercentage,
          title: '${data.neutralPercentage.toStringAsFixed(0)}%',
          color: AppTheme.darkTextSecondary,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
      );
    }

    if (data.negativeCount > 0) {
      sections.add(
        PieChartSectionData(
          value: data.negativePercentage,
          title: '${data.negativePercentage.toStringAsFixed(0)}%',
          color: const Color(0xFFCF6B6B),
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.positiveCount > 0)
          _buildLegendItem(
            '😊 Positive',
            AppTheme.mintGreen,
            data.positiveCount,
          ),
        if (data.positiveCount > 0 && data.neutralCount > 0)
          const SizedBox(height: 12),
        if (data.neutralCount > 0)
          _buildLegendItem(
            '😐 Neutral',
            AppTheme.darkTextSecondary,
            data.neutralCount,
          ),
        if (data.neutralCount > 0 && data.negativeCount > 0)
          const SizedBox(height: 12),
        if (data.negativeCount > 0)
          _buildLegendItem(
            '😔 Negative',
            const Color(0xFFCF6B6B),
            data.negativeCount,
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.darkText),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
