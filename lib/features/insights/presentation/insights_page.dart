import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentimo/core/widgets/error_view.dart';

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
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: BlocBuilder<InsightsBloc, InsightsState>(
            builder: (context, state) {
              if (state is InsightsLoading) {
                return _buildLoadingState();
              }

              if (state is InsightsEmpty) {
                return _buildEmptyState(context, state);
              }

              if (state is InsightsError) {
                return _buildErrorState(context, state);
              }

              if (state is InsightsLoaded) {
                return _buildLoadedState(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brightBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your mood patterns...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, InsightsLoaded state) {
    return Column(
      children: [
        // Header with title and period selector
        _buildHeader(context, state.period),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Summary card - hero element
                _buildSummaryCard(state.data),

                const SizedBox(height: 24),

                // Section header for distribution
                _buildSectionHeader('Mood Distribution'),

                const SizedBox(height: 12),

                // Sentiment distribution chart
                SentimentDistributionChart(data: state.data),

                const SizedBox(height: 24),

                // Section header for breakdown
                _buildSectionHeader('Detailed Breakdown'),

                const SizedBox(height: 12),

                // Percentage cards
                SentimentPercentageCards(data: state.data),

                const SizedBox(height: 24),

                // Top words section
                if (state.data.topWords.isNotEmpty) ...[
                  _buildSectionHeader('Frequently Used Words'),
                  const SizedBox(height: 12),
                  TopWordsSection(words: state.data.topWords),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, InsightsPeriod currentPeriod) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkCard.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon and back button
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.brightBlue.withOpacity(0.2),
                      AppTheme.mintGreen.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: AppTheme.brightBlue,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Insights',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      'Track your emotional journey',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Period selector
          _buildPeriodSelector(context, currentPeriod),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.darkText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, InsightsPeriod current) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.darkCard,
          width: 1,
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
          const SizedBox(width: 6),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.brightBlue,
                    AppTheme.brightBlue.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.brightBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.white : AppTheme.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(InsightsData data) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPredominantColor(data.predominantSentiment).withOpacity(0.15),
            AppTheme.darkCard.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPredominantColor(data.predominantSentiment)
              .withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPredominantColor(data.predominantSentiment)
                .withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large emoji
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Text(
              _getSentimentEmoji(data.predominantSentiment),
              style: const TextStyle(fontSize: 56),
            ),
          ),

          const SizedBox(height: 20),

          // Summary text
          Text(
            data.summaryText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
              height: 1.6,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Entry count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.darkTextSecondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: AppTheme.darkTextSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${data.totalCount} ${data.totalCount == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, InsightsEmpty state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friendly icon with background
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.brightBlue.withOpacity(0.1),
                    AppTheme.mintGreen.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.darkCard,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 64,
                color: AppTheme.darkTextSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // Friendly title
            Text(
              'No Insights Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              state.message,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.darkTextSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // CTA button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.create_rounded, size: 20),
              label: const Text(
                'Start Journaling',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, InsightsError state) {
    return ErrorView(
      message: state.message,
      icon: Icons.insights_outlined,
      onRetry: () {
        context.read<InsightsBloc>().add(const RetryInsightsOperation());
      },
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
