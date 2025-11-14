import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/bloc.dart';

/// Horizontal scrollable filter chip bar
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchFilterBloc, SearchFilterState>(
      builder: (context, state) {
        String? currentSentiment;
        DateTime? startDate;
        DateTime? endDate;
        int activeCount = 0;

        if (state is SearchFilterLoaded) {
          currentSentiment = state.filters.sentimentFilter;
          startDate = state.filters.startDate;
          endDate = state.filters.endDate;
          activeCount = state.activeFilterCount;
        }

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Active filter count badge
              if (activeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),

              // Filter chips
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSentimentChip(
                      context,
                      'All',
                      null,
                      currentSentiment == null,
                    ),
                    const SizedBox(width: 8),
                    _buildSentimentChip(
                      context,
                      '😊 Positive',
                      'positive',
                      currentSentiment == 'positive',
                    ),
                    const SizedBox(width: 8),
                    _buildSentimentChip(
                      context,
                      '😐 Neutral',
                      'neutral',
                      currentSentiment == 'neutral',
                    ),
                    const SizedBox(width: 8),
                    _buildSentimentChip(
                      context,
                      '😔 Negative',
                      'negative',
                      currentSentiment == 'negative',
                    ),
                    const SizedBox(width: 8),
                    _buildDateRangeChip(
                      context,
                      startDate != null || endDate != null,
                    ),
                  ],
                ),
              ),

              // Clear filters button
              if (activeCount > 0)
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    context.read<SearchFilterBloc>().add(const ClearFilters());
                  },
                  color: AppTheme.darkTextSecondary,
                  tooltip: 'Clear all filters',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentimentChip(
    BuildContext context,
    String label,
    String? sentiment,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<SearchFilterBloc>().add(SentimentFilterChanged(sentiment));
      },
      backgroundColor: AppTheme.darkCard,
      selectedColor: AppTheme.brightBlue.withOpacity(0.3),
      checkmarkColor: AppTheme.white,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.darkTextSecondary,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected
            ? AppTheme.brightBlue
            : AppTheme.darkTextSecondary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDateRangeChip(BuildContext context, bool hasDateFilter) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range, size: 16),
          const SizedBox(width: 4),
          Text(hasDateFilter ? 'Date Range' : 'Filter by Date'),
        ],
      ),
      selected: hasDateFilter,
      onSelected: (selected) {
        _showDateRangePicker(context);
      },
      backgroundColor: AppTheme.darkCard,
      selectedColor: AppTheme.brightBlue.withOpacity(0.3),
      checkmarkColor: AppTheme.white,
      labelStyle: TextStyle(
        color: hasDateFilter ? AppTheme.white : AppTheme.darkTextSecondary,
        fontSize: 12,
      ),
      side: BorderSide(
        color: hasDateFilter
            ? AppTheme.brightBlue
            : AppTheme.darkTextSecondary.withOpacity(0.3),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DateRangePickerSheet(),
    );
  }
}

class _DateRangePickerSheet extends StatefulWidget {
  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Date Range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 20),

          // Quick select buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSelectButton('Today', () {
                final today = DateTime.now();
                setState(() {
                  _startDate = DateTime(today.year, today.month, today.day);
                  _endDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                    23,
                    59,
                    59,
                  );
                });
              }),
              _buildQuickSelectButton('This Week', () {
                final now = DateTime.now();
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                setState(() {
                  _startDate = DateTime(
                    weekStart.year,
                    weekStart.month,
                    weekStart.day,
                  );
                  _endDate = DateTime.now();
                });
              }),
              _buildQuickSelectButton('This Month', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = DateTime(now.year, now.month, 1);
                  _endDate = DateTime.now();
                });
              }),
            ],
          ),

          const SizedBox(height: 20),

          // Date display
          Row(
            children: [
              Expanded(
                child: _buildDateDisplay('Start Date', _startDate, () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateDisplay('End Date', _endDate, () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                }),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    context.read<SearchFilterBloc>().add(
                      const DateRangeFilterChanged(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SearchFilterBloc>().add(
                      DateRangeFilterChanged(
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: const BorderSide(color: AppTheme.darkTextSecondary),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildDateDisplay(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.darkTextSecondary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: TextStyle(
                fontSize: 14,
                color: date != null
                    ? AppTheme.white
                    : AppTheme.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
