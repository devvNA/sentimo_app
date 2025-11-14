import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentimo/core/widgets/error_view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/journal_repository.dart';
import '../bloc/bloc.dart';
import 'widgets/day_entries_sheet.dart';

/// Calendar page showing mood patterns over time
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CalendarBloc(journalRepository: context.read<JournalRepository>())
            ..add(LoadCalendarMonth(DateTime.now())),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mood Calendar'), centerTitle: true),
        body: BlocConsumer<CalendarBloc, CalendarState>(
          listener: (context, state) {
            if (state is DateSelected) {
              // Show bottom sheet with entries for selected date
              _showDayEntriesSheet(context, state);
            }
          },
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CalendarError) {
              return ErrorView(
                message: state.message,
                icon: Icons.calendar_today_outlined,
                onRetry: () {
                  context.read<CalendarBloc>().add(
                    const RetryCalendarOperation(),
                  );
                },
              );
            }

            if (state is CalendarLoaded || state is DateSelected) {
              final calendarState = state is DateSelected
                  ? state.previousState
                  : state as CalendarLoaded;

              return _buildCalendarView(context, calendarState);
            }

            // Initial state
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, CalendarLoaded state) {
    return Column(
      children: [
        // Month navigation header
        _buildMonthHeader(context, state),

        // Calendar
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: state.currentMonth,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });

                  // Load entries for selected date
                  context.read<CalendarBloc>().add(SelectDate(selectedDay));
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  // Today
                  todayDecoration: BoxDecoration(
                    color: AppTheme.brightBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  // Selected day
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.brightBlue,
                    shape: BoxShape.circle,
                  ),
                  // Default day
                  defaultTextStyle: const TextStyle(color: AppTheme.darkText),
                  // Weekend
                  weekendTextStyle: TextStyle(
                    color: AppTheme.darkText.withOpacity(0.7),
                  ),
                  // Outside month
                  outsideTextStyle: TextStyle(
                    color: AppTheme.darkTextSecondary.withOpacity(0.5),
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppTheme.darkTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  weekendStyle: TextStyle(
                    color: AppTheme.darkTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarCell(context, day, state);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildCalendarCell(
                      context,
                      day,
                      state,
                      isToday: true,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildCalendarCell(
                      context,
                      day,
                      state,
                      isSelected: true,
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context, CalendarLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              context.read<CalendarBloc>().add(const NavigateMonth(-1));
            },
          ),

          // Current month/year
          Text(
            _getMonthYearString(state.currentMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),

          // Next month button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              context.read<CalendarBloc>().add(const NavigateMonth(1));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(
    BuildContext context,
    DateTime day,
    CalendarLoaded state, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final sentimentData = state.getSentimentForDate(day);
    final hasEntries = sentimentData != null && sentimentData.hasEntries;

    Color backgroundColor = Colors.transparent;
    Color? borderColor;

    if (hasEntries) {
      // Color based on sentiment
      final sentiment = sentimentData.predominantSentiment;
      backgroundColor = _getSentimentColor(sentiment).withOpacity(0.3);
      borderColor = _getSentimentColor(sentiment);
    }

    if (isSelected) {
      borderColor = AppTheme.brightBlue;
    } else if (isToday) {
      borderColor = AppTheme.brightBlue.withOpacity(0.5);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || isToday
                    ? AppTheme.white
                    : AppTheme.darkText,
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (hasEntries)
            Positioned(
              bottom: 4,
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getSentimentColor(
                      sentimentData.predominantSentiment,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(
          top: BorderSide(
            color: AppTheme.darkTextSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Positive', AppTheme.mintGreen),
          _buildLegendItem('Neutral', AppTheme.darkTextSecondary),
          _buildLegendItem('Negative', const Color(0xFFCF6B6B)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkTextSecondary,
          ),
        ),
      ],
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return AppTheme.mintGreen;
      case 'negative':
        return const Color(0xFFCF6B6B); // Soft red
      case 'neutral':
      default:
        return AppTheme.darkTextSecondary;
    }
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showDayEntriesSheet(BuildContext context, DateSelected state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DayEntriesSheet(date: state.selectedDate, entries: state.entries),
    );
  }
}
