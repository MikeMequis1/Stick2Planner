import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/calendar/event_bar_layout.dart';
import '../../../domain/entities/post_it.dart';
import '../../shared/desktop_context_menu.dart';
import 'adaptive_draggable.dart';
import 'day_cell.dart';
import 'event_bar.dart';
import 'post_it_context_menu.dart';
import 'post_it_drag_data.dart';

/// Linha da grade: faixa de eventos multi-dia + células de dia.
///
/// O arraste do corpo do evento move o registro; as alças laterais iniciam o
/// redimensionamento (com prévia textual da nova data).
class WeekRow extends StatefulWidget {
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
    required this.onMovePostIt,
    required this.onReorderTo,
    required this.onResizeEvent,
    required this.onShowHiddenEvents,
    required this.onQuickCreateTask,
    required this.onQuickCreateEvent,
    this.focusedPostItId,
    this.onEventDragActive,
  });

  final CalendarWeek week;
  final DateOnly periodStart;
  final List<PostIt> postIts;
  final String? focusedPostItId;
  final ValueChanged<bool>? onEventDragActive;
  final DateOnly today;
  final DateOnly selectedDate;
  final bool compact;
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

  @override
  State<WeekRow> createState() => _WeekRowState();
}

class _WeekRowState extends State<WeekRow> {
  _ResizeState? _resize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barHeight = widget.compact ? 24.0 : 26.0;
        final barGap = 4.0;
        final maxLanes = widget.compact
            ? 1
            : ((constraints.maxHeight * 0.42) / (barHeight + barGap))
                  .floor()
                  .clamp(1, 3);
        final layout = layoutEventSegments(
          widget.postIts,
          widget.week,
          maxLanes: maxLanes,
        );
        final laneCount = layout.segments.isEmpty
            ? 0
            : layout.segments.map((segment) => segment.lane).reduce(math.max) +
                  1;
        final barAreaHeight = laneCount * (barHeight + barGap);
        final columnWidth = constraints.maxWidth / widget.week.days.length;
        final previewLabel = _resize == null
            ? null
            : _previewLabel(_resize!, columnWidth);

        return Builder(
          builder: (rowContext) {
            int? dayIndexAt(Offset globalPosition) {
              final box = rowContext.findRenderObject();
              if (box is! RenderBox || !box.hasSize) return null;
              final local = box.globalToLocal(globalPosition);
              final raw = (local.dx / columnWidth).floor();
              return raw.clamp(0, widget.week.days.length - 1).toInt();
            }

            return DragTarget<PostItDragData>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                final index = dayIndexAt(
                  details.data.pointerAt(details.offset),
                );
                if (index == null) return;
                widget.onMovePostIt(
                  details.data.postIt,
                  widget.week.days[index].date,
                );
              },
              builder: (context, candidateData, rejectedData) {
                final highlight = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  color: highlight
                      ? theme.colorScheme.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (barAreaHeight > 0)
                        SizedBox(
                          height: barAreaHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              for (final segment in layout.segments)
                                _buildSegment(
                                  segment: segment,
                                  theme: theme,
                                  columnWidth: columnWidth,
                                  barHeight: barHeight,
                                  barGap: barGap,
                                ),
                              if (previewLabel != null)
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) => Opacity(
                                      opacity: value.clamp(0, 1),
                                      child: Transform.scale(
                                        scale: 0.85 + 0.15 * value,
                                        child: child,
                                      ),
                                    ),
                                    child: Material(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 120,
                                          ),
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          child: Text(
                                            previewLabel,
                                            key: ValueKey(previewLabel),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (layout.hiddenSegments.isNotEmpty &&
                                  previewLabel == null)
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) => Opacity(
                                      opacity: value.clamp(0, 1),
                                      child: Transform.scale(
                                        scale: 0.85 + 0.15 * value,
                                        child: child,
                                      ),
                                    ),
                                    child: Material(
                                      color: theme.colorScheme.surface
                                          .withValues(alpha: 0.82),
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        key: Key(
                                          'hidden-events-${widget.week.start.toIso8601String()}',
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () {
                                          final hidden = <String, PostIt>{
                                            for (final segment
                                                in layout.hiddenSegments)
                                              segment.postIt.id: segment.postIt,
                                          }.values.toList(growable: false);
                                          widget.onShowHiddenEvents(hidden);
                                        },
                                        child: SizedBox(
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            child: Center(
                                              child: Text(
                                                AppStrings.hiddenEvents(
                                                  layout.hiddenCount,
                                                ),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
                            for (final day in widget.week.days)
                              Expanded(
                                child: DayCell(
                                  key: ValueKey(
                                    'day-${day.date.toIso8601String()}',
                                  ),
                                  day: day,
                                  items: singleDayItemsOn(
                                    widget.postIts,
                                    day.date,
                                  ),
                                  isSelected: day.date.isSameDay(
                                    widget.selectedDate,
                                  ),
                                  isToday: day.date.isSameDay(widget.today),
                                  today: widget.today,
                                  compact: widget.compact,
                                  onTap: () => widget.onDaySelected(day.date),
                                  onPostItTap: widget.onPostItTap,
                                  onShowAll: () => widget.onShowDay(day.date),
                                  onMoveToDay: (postIt) =>
                                      widget.onMovePostIt(postIt, day.date),
                                  onReorderTo: (postIt, index) => widget
                                      .onReorderTo(postIt, day.date, index),
                                  onQuickCreateTask: widget.onQuickCreateTask,
                                  onQuickCreateEvent: widget.onQuickCreateEvent,
                                  itemsFor: (date) =>
                                      itemsCoveringDate(widget.postIts, date),
                                  focusedPostItId: widget.focusedPostItId,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSegment({
    required CalendarEventSegment segment,
    required ThemeData theme,
    required double columnWidth,
    required double barHeight,
    required double barGap,
  }) {
    final postIt = segment.postIt;
    final recurring = postIt.isRecurringEvent;
    final activeResize = _resize;
    final resizing = !recurring && activeResize?.postIt.id == postIt.id;
    final resizingThisEdge =
        resizing &&
        (activeResize!.isStart
            ? !segment.continuesBefore
            : !segment.continuesAfter);

    var left = segment.startColumn * columnWidth + 2;
    var width = math.max(2.0, segment.columnSpan * columnWidth - 4);
    if (resizingThisEdge) {
      final dx = activeResize.dx;
      if (activeResize.isStart) {
        final delta = dx.clamp(-(left - 2), width - 8).toDouble();
        left += delta;
        width -= delta;
      } else {
        final maxWidth = (widget.week.days.length * columnWidth - 2) - left;
        width = (width + dx).clamp(8.0, math.max(8.0, maxWidth)).toDouble();
      }
    }

    final bar = EventBar(
      key: ValueKey(
        postIt.isRecurringEvent
            ? 'event-bar-${postIt.id}-'
                  '${postIt.startDate?.toIso8601String() ?? ''}-'
                  '${widget.week.start.toIso8601String()}'
            : 'event-bar-${postIt.id}-${widget.week.start.toIso8601String()}',
      ),
      postIt: postIt,
      isFocused: widget.focusedPostItId == postIt.id,
      continuesBefore: segment.continuesBefore,
      continuesAfter: segment.continuesAfter,
      showTitle:
          !segment.continuesBefore ||
          (postIt.startDate?.isBefore(widget.periodStart) ?? false),
      compact: widget.compact,
      onTap: () => widget.onPostItTap(postIt),
    );

    return Positioned(
      left: left,
      top: segment.lane * (barHeight + barGap),
      width: width,
      height: barHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DesktopContextMenuRegion(
            onOpen: (position) => showPostItContextMenuAt(
              context,
              postIt,
              globalPosition: position,
            ),
            child: AnimatedScale(
              scale: resizingThisEdge ? 1.03 : 1,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              child: AdaptivePostItDraggable(
                data: PostItDragData(postIt),
                maxSimultaneousDrags: recurring ? 0 : null,
                onDragStarted: () => widget.onEventDragActive?.call(true),
                onDragEnd: (_) => widget.onEventDragActive?.call(false),
                onDraggableCanceled: () =>
                    widget.onEventDragActive?.call(false),
                feedback: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.86, end: 1),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 220,
                      height: barHeight,
                      child: EventBar(
                        postIt: postIt,
                        continuesBefore: false,
                        continuesAfter: false,
                        showTitle: true,
                        compact: widget.compact,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 0.25),
                  duration: const Duration(milliseconds: 180),
                  builder: (context, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: bar,
                ),
                child: bar,
              ),
            ),
          ),
          if (!recurring && !segment.continuesBefore)
            Align(
              alignment: Alignment.centerLeft,
              child: _ResizeHandle(
                key: Key(
                  recurring
                      ? 'event-resize-start-${postIt.id}-'
                            '${postIt.startDate?.toIso8601String() ?? ''}'
                      : 'event-resize-start-${postIt.id}',
                ),
                tooltip: AppStrings.resizeStart,
                isStart: true,
                compact: widget.compact,
                active: _resize?.postIt.id == postIt.id && _resize!.isStart,
                onStart: () => _startResize(postIt, isStart: true),
                onUpdate: (dx) => _updateResize(dx),
                onEnd: () => _commitResize(columnWidth),
                onCancel: _cancelResize,
              ),
            ),
          if (!recurring && !segment.continuesAfter)
            Align(
              alignment: Alignment.centerRight,
              child: _ResizeHandle(
                key: Key(
                  recurring
                      ? 'event-resize-end-${postIt.id}-'
                            '${postIt.startDate?.toIso8601String() ?? ''}'
                      : 'event-resize-end-${postIt.id}',
                ),
                tooltip: AppStrings.resizeEnd,
                isStart: false,
                compact: widget.compact,
                active: _resize?.postIt.id == postIt.id && !_resize!.isStart,
                onStart: () => _startResize(postIt, isStart: false),
                onUpdate: (dx) => _updateResize(dx),
                onEnd: () => _commitResize(columnWidth),
                onCancel: _cancelResize,
              ),
            ),
        ],
      ),
    );
  }

  void _startResize(PostIt postIt, {required bool isStart}) {
    setState(() {
      _resize = _ResizeState(postIt: postIt, isStart: isStart, dx: 0);
    });
  }

  void _updateResize(double dx) {
    final current = _resize;
    if (current == null) return;
    setState(() {
      _resize = _ResizeState(
        postIt: current.postIt,
        isStart: current.isStart,
        dx: current.dx + dx,
      );
    });
  }

  void _commitResize(double columnWidth) {
    final current = _resize;
    setState(() => _resize = null);
    if (current == null) return;

    final days = (current.dx / columnWidth).round();
    if (days == 0) return;

    final start = current.postIt.startDate;
    final end = current.postIt.effectiveEndDate;
    if (start == null || end == null) return;

    var newStart = start;
    var newEnd = end;
    if (current.isStart) {
      newStart = start.addDays(days);
      if (newStart.isAfter(end)) newStart = end;
    } else {
      newEnd = end.addDays(days);
      if (newEnd.isBefore(start)) newEnd = start;
    }
    if (newStart.isSameDay(start) && newEnd.isSameDay(end)) return;

    widget.onResizeEvent(current.postIt, newStart, newEnd);
  }

  void _cancelResize() {
    setState(() => _resize = null);
  }

  String _previewLabel(_ResizeState state, double columnWidth) {
    final days = (state.dx / columnWidth).round();
    final start = state.postIt.startDate;
    final end = state.postIt.effectiveEndDate;
    if (start == null || end == null) return '';

    DateOnly preview;
    if (state.isStart) {
      preview = start.addDays(days);
      if (preview.isAfter(end)) preview = end;
    } else {
      preview = end.addDays(days);
      if (preview.isBefore(start)) preview = start;
    }
    final label = state.isStart
        ? AppStrings.fieldStartDate
        : AppStrings.fieldEndDate;
    return '$label: ${DateFormats.shortDate(preview)}';
  }
}

class _ResizeState {
  const _ResizeState({
    required this.postIt,
    required this.isStart,
    required this.dx,
  });

  final PostIt postIt;
  final bool isStart;
  final double dx;
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    super.key,
    required this.tooltip,
    required this.isStart,
    required this.compact,
    required this.active,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
  });

  final String tooltip;
  final bool isStart;
  final bool compact;
  final bool active;
  final VoidCallback onStart;
  final ValueChanged<double> onUpdate;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => onStart(),
          onHorizontalDragUpdate: (details) => onUpdate(details.delta.dx),
          onHorizontalDragEnd: (_) => onEnd(),
          onHorizontalDragCancel: onCancel,
          child: Semantics(
            label: tooltip,
            button: true,
            child: SizedBox(
              width: 24,
              height: 24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? scheme.primary.withValues(alpha: 0.30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(isStart ? 8 : 2),
                    right: Radius.circular(isStart ? 2 : 8),
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  width: active ? (compact ? 4 : 5) : (compact ? 3 : 4),
                  height: active ? (compact ? 14 : 18) : (compact ? 10 : 14),
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
