import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/calendar/event_bar_layout.dart';
import '../../../domain/entities/post_it.dart';
import 'day_cell.dart';
import 'event_bar.dart';

/// Linha da grade: faixa de eventos multi-dia + sete (ou N) células de dia.
class WeekRow extends StatelessWidget {
  const WeekRow({
    super.key,
    required this.week,
    required this.periodStart,
    required this.postIts,
    required this.today,
    required this.selectedDate,
    required this.compact,
    required this.onDaySelected,
    required this.onPostItTap,
    required this.onShowDay,
  });

  final CalendarWeek week;
  final DateOnly periodStart;
  final List<PostIt> postIts;
  final DateOnly today;
  final DateOnly selectedDate;
  final bool compact;
  final ValueChanged<DateOnly> onDaySelected;
  final ValueChanged<PostIt> onPostItTap;
  final ValueChanged<DateOnly> onShowDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barHeight = compact ? 18.0 : 26.0;
        final barGap = 4.0;
        final maxLanes = ((constraints.maxHeight * 0.42) / (barHeight + barGap))
            .floor()
            .clamp(1, 3);
        final layout = layoutEventSegments(
          postIts,
          week,
          maxLanes: maxLanes,
        );
        final laneCount = layout.segments.isEmpty
            ? 0
            : layout.segments
                      .map((segment) => segment.lane)
                      .reduce(math.max) +
                  1;
        final barAreaHeight =
            laneCount * (barHeight + barGap) +
            (layout.hiddenCount > 0 ? 14 : 0);
        final columnWidth = constraints.maxWidth / week.days.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (barAreaHeight > 0)
              SizedBox(
                height: barAreaHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final segment in layout.segments)
                      Positioned(
                        left: segment.startColumn * columnWidth + 2,
                        top: segment.lane * (barHeight + barGap),
                        width: math.max(
                          2,
                          segment.columnSpan * columnWidth - 4,
                        ),
                        height: barHeight,
                        child: EventBar(
                          key: ValueKey(
                            'event-bar-${segment.postIt.id}-'
                            '${week.start.toIso8601String()}',
                          ),
                          postIt: segment.postIt,
                          continuesBefore: segment.continuesBefore,
                          continuesAfter: segment.continuesAfter,
                          showTitle:
                              !segment.continuesBefore ||
                              (segment.postIt.startDate?.isBefore(
                                    periodStart,
                                  ) ??
                                  false),
                          compact: compact,
                          onTap: () => onPostItTap(segment.postIt),
                        ),
                      ),
                    if (layout.hiddenCount > 0)
                      Positioned(
                        right: 4,
                        bottom: 0,
                        child: Text(
                          AppStrings.hiddenEvents(layout.hiddenCount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (barAreaHeight > 0) const SizedBox(height: 4),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final day in week.days)
                    Expanded(
                      child: DayCell(
                        key: ValueKey(
                          'day-${day.date.toIso8601String()}',
                        ),
                        day: day,
                        items: singleDayItemsOn(postIts, day.date),
                        isSelected: day.date.isSameDay(selectedDate),
                        isToday: day.date.isSameDay(today),
                        compact: compact,
                        onTap: () => onDaySelected(day.date),
                        onPostItTap: onPostItTap,
                        onShowAll: () => onShowDay(day.date),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
