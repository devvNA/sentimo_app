import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../features/journal/bloc/journal_bloc.dart';
import '../entities/journal_entry.dart';
import '../theme/app_theme.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;

  const JournalEntryCard({super.key, required this.entry, this.onTap});

  Color _getSentimentBgColor() {
    switch (entry.sentimentLabel) {
      case SentimentLabel.positive:
        return const Color(0xFF047857);
      case SentimentLabel.negative:
        return const Color(0xFF951C04);
      case SentimentLabel.mixed:
        return const Color(0xFFBA8004);
      case SentimentLabel.neutral:
      default:
        return const Color(0xFF1E3A8A);
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
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      color: Color(0xFF17212F),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      BlocProvider.value(value: context.read<JournalBloc>()),
                ),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _getSentimentBgColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getSentimentIcon(), color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat
                              .format(entry.createdAt.toLocal())
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          timeFormat
                              .format(entry.createdAt.toLocal())
                              .toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.darkTextSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.content,
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
