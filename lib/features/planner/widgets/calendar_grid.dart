import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/entities/post_it.dart';
import 'day_preview_registry.dart';
import 'week_row.dart';

/// Grade completa do período visível.
class CalendarGrid extends StatefulWidget {
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
    required this.onShowHiddenEvents,
    required this.onQuickCreateTask,
    required this.onQuickCreateEvent,
    this.focusedPostItId,
    this.onEventDragActive,
  });

  final CalendarPeriod period;
  final List<PostIt> postIts;
  final String? focusedPostItId;
  final ValueChanged<bool>? onEventDragActive;
  final DateOnly today;
  final DateOnly selectedDate;
  final ValueChanged<DateOnly> onDaySelected;
  final ValueChanged<PostIt> onPostItTap;
  final ValueChanged<DateOnly> onShowDay;
  final void Function(PostIt postIt, DateOnly targetDate) onMovePostIt;
  final void Function(PostIt postIt, DateOnly date, int newIndex) onReorderTo;
  final void Function(PostIt postIt, DateOnly startDate, DateOnly endDate)
  onResizeEvent;
  final ValueChanged<List<PostIt>> onShowHiddenEvents;
  final ValueChanged<DateOnly> onQuickCreateTask;
  final ValueChanged<DateOnly> onQuickCreateEvent;

  static const _minimumHeight = 160.0;

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  final DayPreviewRegistry _previewRegistry = DayPreviewRegistry();

  @override
  Widget build(BuildContext context) {
    final period = widget.period;
    final postIts = widget.postIts;
    final today = widget.today;
    final selectedDate = widget.selectedDate;
    final focusedPostItId = widget.focusedPostItId;
    final onEventDragActive = widget.onEventDragActive;
    final onDaySelected = widget.onDaySelected;
    final onPostItTap = widget.onPostItTap;
    final onShowDay = widget.onShowDay;
    final onMovePostIt = widget.onMovePostIt;
    final onReorderTo = widget.onReorderTo;
    final onResizeEvent = widget.onResizeEvent;
    final onShowHiddenEvents = widget.onShowHiddenEvents;
    final onQuickCreateTask = widget.onQuickCreateTask;
    final onQuickCreateEvent = widget.onQuickCreateEvent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxHeight < CalendarGrid._minimumHeight;
        final height = needsScroll
            ? CalendarGrid._minimumHeight
            : constraints.maxHeight;

        final content = SizedBox(
          height: height,
          child: DayPreviewScope(
            registry: _previewRegistry,
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
                              onShowHiddenEvents: onShowHiddenEvents,
                              onQuickCreateTask: onQuickCreateTask,
                              onQuickCreateEvent: onQuickCreateEvent,
                              focusedPostItId: focusedPostItId,
                              onEventDragActive: onEventDragActive,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (!needsScroll) return content;
        return SingleChildScrollView(
          child: SizedBox(
            height: math.max(
              CalendarGrid._minimumHeight,
              constraints.maxHeight,
            ),
            child: content,
          ),
        );
      },
    );
  }

  String? get focusedPostItId => widget.focusedPostItId;
  ValueChanged<bool>? get onEventDragActive => widget.onEventDragActive;
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
