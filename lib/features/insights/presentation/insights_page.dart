import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entities/insights_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/journal_repository.dart';
import '../bloc/bloc.dart';
import 'widgets/sentiment_distribution_chart.dart';
import 'widgets/sentiment_percentage_cards.dart';
import 'widgets/top_words_section.dart';

/// Page showing mood insights and analytics
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InsightsBloc(journalRepository: context.read<JournalRepository>())
            ..add(const LoadInsights(InsightsPeriod.week)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mood Insights'), centerTitle: true),
        body: BlocBuilder<InsightsBloc, InsightsState>(
          builder: (context, state) {
            if (state is InsightsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InsightsEmpty) {
              return _buildEmptyState(state);
            }

            if (state is InsightsError) {
              return _buildErrorState(state);
            }

            if (state is InsightsLoaded) {
              return _buildLoadedState(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, InsightsLoaded state) {
    return Column(
      children: [
        // Period selector
        _buildPeriodSelector(context, state.period),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                _buildSummaryCard(state.data),

                const SizedBox(height: 20),

                // Sentiment distribution chart
                SentimentDistributionChart(data: state.data),

                const SizedBox(height: 20),

                // Percentage cards
                SentimentPercentageCards(data: state.data),

                const SizedBox(height: 20),

                // Top words section
                if (state.data.topWords.isNotEmpty)
                  TopWordsSection(words: state.data.topWords),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context, InsightsPeriod current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkTextSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(
              context,
              'This Week',
              InsightsPeriod.week,
              current == InsightsPeriod.week,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPeriodButton(
              context,
              'This Month',
              InsightsPeriod.month,
              current == InsightsPeriod.month,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    String label,
    InsightsPeriod period,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.read<InsightsBloc>().add(ChangePeriod(period));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brightBlue : AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.white : AppTheme.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(InsightsData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPredominantColor(data.predominantSentiment).withOpacity(0.2),
            AppTheme.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPredominantColor(
            data.predominantSentiment,
          ).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            _getSentimentEmoji(data.predominantSentiment),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            data.summaryText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '${data.totalCount} ${data.totalCount == 1 ? 'entry' : 'entries'}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(InsightsEmpty state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 80,
              color: AppTheme.darkTextSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.darkTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to journal creation
                Navigator.pop(state as BuildContext);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Start Journaling'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(InsightsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.darkTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retry loading
                final period = state.period ?? InsightsPeriod.week;
                (state as BuildContext).read<InsightsBloc>().add(
                  LoadInsights(period),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPredominantColor(String sentiment) {
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
