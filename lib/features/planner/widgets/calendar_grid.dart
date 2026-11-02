import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/entities/post_it.dart';
import 'week_row.dart';

/// Grade completa do período visível.
class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.period,
    required this.postIts,
    required this.today,
    required this.selectedDate,
    required this.onDaySelected,
    required this.onPostItTap,
    required this.onShowDay,
    required this.onMovePostIt,
    required this.onReorderTo,
    required this.onResizeEvent,
  });

  final CalendarPeriod period;
  final List<PostIt> postIts;
  final DateOnly today;
  final DateOnly selectedDate;
  final ValueChanged<DateOnly> onDaySelected;
  final ValueChanged<PostIt> onPostItTap;
  final ValueChanged<DateOnly> onShowDay;
  final void Function(PostIt postIt, DateOnly targetDate) onMovePostIt;
  final void Function(PostIt postIt, DateOnly date, int newIndex) onReorderTo;
  final void Function(PostIt postIt, DateOnly startDate, DateOnly endDate)
  onResizeEvent;

  static const _minimumHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxHeight < _minimumHeight;
        final height = needsScroll
            ? _minimumHeight
            : constraints.maxHeight;

        final content = SizedBox(
          height: height,
          child: Column(
            children: [
              _WeekdayHeader(
                days: period.weeks.first.days,
                compact: period.isMonth,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Column(
                  children: [
                    for (var index = 0; index < period.weeks.length; index++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: index == period.weeks.length - 1 ? 0 : 6,
                          ),
                          child: WeekRow(
                            week: period.weeks[index],
                            periodStart: period.start,
                            postIts: postIts,
                            today: today,
                            selectedDate: selectedDate,
                            compact: period.isMonth,
                            onDaySelected: onDaySelected,
                            onPostItTap: onPostItTap,
                            onShowDay: onShowDay,
                            onMovePostIt: onMovePostIt,
                            onReorderTo: onReorderTo,
                            onResizeEvent: onResizeEvent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (!needsScroll) return content;
        return SingleChildScrollView(
          child: SizedBox(
            height: math.max(_minimumHeight, constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.days, required this.compact});

  final List<CalendarDay> days;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: compact ? 18 : 20,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: Center(
                child: Text(
                  DateFormats.weekdayShort(day.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
