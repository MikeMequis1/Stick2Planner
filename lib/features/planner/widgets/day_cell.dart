import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_drag_data.dart';
import 'post_it_presentation.dart';
import 'post_it_tile.dart';

/// Célula de um dia: alvo de soltura, cartões arrastáveis e overflow.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.items,
    required this.isSelected,
    required this.isToday,
    required this.today,
    required this.compact,
    required this.onTap,
    required this.onPostItTap,
    required this.onShowAll,
    required this.onMoveToDay,
    required this.onReorderTo,
    required this.onQuickCreateTask,
    required this.onQuickCreateEvent,
    this.focusedPostItId,
  });

  final CalendarDay day;
  final List<PostIt> items;
  final String? focusedPostItId;
  final bool isSelected;
  final bool isToday;
  final DateOnly today;
  final bool compact;
  final VoidCallback onTap;
  final ValueChanged<PostIt> onPostItTap;
  final VoidCallback onShowAll;
  final ValueChanged<PostIt> onMoveToDay;
  final void Function(PostIt postIt, int newIndex) onReorderTo;
  final ValueChanged<DateOnly> onQuickCreateTask;
  final ValueChanged<DateOnly> onQuickCreateEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return DragTarget<PostItDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        onMoveToDay(details.data.postIt);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final muted = !day.isCurrentMonth;
        final borderColor = isDropTarget
            ? scheme.primary
            : (isSelected ? scheme.primary : scheme.outlineVariant);
        final dayLabel = [
          DateFormats.fullDate(day.date),
          if (isToday) AppStrings.today,
          if (isSelected) AppStrings.selectedDay,
        ].join(' · ');

        return Semantics(
          container: true,
          button: true,
          label: dayLabel,
          onTap: onTap,
          child: _DayTapRegion(
            date: day.date,
            items: items,
            today: today,
            onTap: onTap,
            onQuickCreateTask: onQuickCreateTask,
            onQuickCreateEvent: onQuickCreateEvent,
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: AnimatedScale(
                scale: isDropTarget ? 1.04 : (isSelected ? 1.025 : 1),
                duration: motion,
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: motion,
                  curve: Curves.easeOut,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDropTarget
                        ? scheme.primaryContainer.withValues(alpha: 0.45)
                        : (isSelected
                              ? scheme.primaryContainer.withValues(alpha: 0.28)
                              : (muted
                                    ? scheme.surfaceContainerLowest
                                    : scheme.surface)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: isDropTarget ? 2 : (isSelected ? 1.8 : 0.6),
                    ),
                    boxShadow: isSelected || isDropTarget
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(
                                alpha: isDropTarget ? 0.32 : 0.18,
                              ),
                              blurRadius: isDropTarget ? 16 : 10,
                            ),
                          ]
                        : const [],
                  ),
                  padding: EdgeInsets.all(compact ? 1 : 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tight = constraints.maxHeight < 24;
                      final showHeader = constraints.maxHeight >= 12;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showHeader)
                            _DayHeader(
                              date: day.date,
                              isSelected: isSelected,
                              isToday: isToday,
                              muted: muted,
                              compact: compact || tight,
                              dense: tight,
                            ),
                          Expanded(
                            child: _DayContent(
                              date: day.date,
                              today: today,
                              items: items,
                              compact: compact || tight,
                              focusedPostItId: focusedPostItId,
                              onPostItTap: onPostItTap,
                              onShowAll: onShowAll,
                              onReorderTo: onReorderTo,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayTapRegion extends StatefulWidget {
  const _DayTapRegion({
    required this.date,
    required this.items,
    required this.today,
    required this.onTap,
    required this.onQuickCreateTask,
    required this.onQuickCreateEvent,
    required this.child,
  });

  final DateOnly date;
  final List<PostIt> items;
  final DateOnly today;
  final VoidCallback onTap;
  final ValueChanged<DateOnly> onQuickCreateTask;
  final ValueChanged<DateOnly> onQuickCreateEvent;
  final Widget child;

  @override
  State<_DayTapRegion> createState() => _DayTapRegionState();
}

class _DayTapRegionState extends State<_DayTapRegion> {
  static const _multiTapWindow = Duration(milliseconds: 300);
  static const _previewWidth = 280.0;
  static const _previewHeight = 224.0;

  Timer? _tapTimer;
  int _tapCount = 0;
  OverlayEntry? _previewEntry;

  @override
  void dispose() {
    _tapTimer?.cancel();
    _removePreview();
    super.dispose();
  }

  void _resetTapCount() {
    _tapTimer?.cancel();
    _tapCount = 0;
  }

  void _handleTapUp(TapUpDetails details) {
    _tapTimer?.cancel();
    _tapCount++;
    widget.onTap();

    if (_tapCount >= 3) {
      _tapCount = 0;
      HapticFeedback.mediumImpact();
      widget.onQuickCreateEvent(widget.date);
      return;
    }

    _tapTimer = Timer(_multiTapWindow, () {
      final count = _tapCount;
      _tapCount = 0;
      if (count == 2) {
        HapticFeedback.lightImpact();
        widget.onQuickCreateTask(widget.date);
      }
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _resetTapCount();
    HapticFeedback.selectionClick();
    _showPreview();
  }

  void _handleLongPressEnd(LongPressEndDetails details) => _removePreview();

  void _handleLongPressCancel() => _removePreview();

  void _showPreview() {
    _removePreview();
    final overlay = Overlay.maybeOf(context);
    final renderObject = context.findRenderObject();
    if (overlay == null || renderObject is! RenderBox) return;
    if (!renderObject.hasSize) return;

    final origin = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final screen = MediaQuery.sizeOf(context);
    final maxLeft = screen.width - _previewWidth - 8;
    final left = (origin.dx + size.width / 2 - _previewWidth / 2)
        .clamp(8.0, maxLeft < 8 ? 8.0 : maxLeft)
        .toDouble();
    final maxTop = screen.height - _previewHeight - 8;
    var top = origin.dy + size.height + 8;
    if (top > maxTop) top = origin.dy - _previewHeight - 8;
    top = top.clamp(8.0, maxTop < 8 ? 8.0 : maxTop).toDouble();

    _previewEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        width: _previewWidth,
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Opacity(
              opacity: value.clamp(0, 1),
              child: Transform.scale(scale: 0.92 + 0.08 * value, child: child),
            ),
            child: _DayPreviewCard(date: widget.date, items: widget.items),
          ),
        ),
      ),
    );
    overlay.insert(_previewEntry!);
  }

  void _removePreview() {
    _previewEntry?.remove();
    _previewEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _handleTapUp,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: _handleLongPressCancel,
      child: widget.child,
    );
  }
}

class _DayPreviewCard extends StatelessWidget {
  const _DayPreviewCard({required this.date, required this.items});

  final DateOnly date;
  final List<PostIt> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final visible = items.take(4).toList(growable: false);

    return Material(
      key: const Key('day-preview'),
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: scheme.surfaceContainerHigh,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormats.fullDate(date),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(
                AppStrings.emptyDay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else ...[
              for (final postIt in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        postItIcon(postIt),
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          postIt.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: postIt.status == PostItStatus.active
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (items.length > visible.length)
                Text(
                  AppStrings.moreItems(items.length - visible.length),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.muted,
    required this.compact,
    this.dense = false,
  });

  final DateOnly date;
  final bool isSelected;
  final bool isToday;
  final bool muted;
  final bool compact;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = isSelected
        ? scheme.onPrimary
        : (muted ? scheme.outline : scheme.onSurface);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 4),
      child: Row(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.15 : 1,
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              key: Key('day-number-${date.toIso8601String()}'),
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOut,
              width: dense ? 12 : (compact ? 15 : 24),
              height: dense ? 12 : (compact ? 15 : 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : null,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: scheme.primary, width: 1.2)
                    : null,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: dense ? 7.5 : (compact ? 9.5 : 12),
                  height: 1,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: foreground,
                ),
              ),
            ),
          ),
          if (isToday && !compact) ...[
            const SizedBox(width: 4),
            Semantics(
              label: AppStrings.today,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.date,
    required this.today,
    required this.items,
    required this.compact,
    required this.onPostItTap,
    required this.onShowAll,
    required this.onReorderTo,
    this.focusedPostItId,
  });

  final DateOnly date;
  final DateOnly today;
  final List<PostIt> items;
  final bool compact;
  final String? focusedPostItId;
  final ValueChanged<PostIt> onPostItTap;
  final VoidCallback onShowAll;
  final void Function(PostIt postIt, int newIndex) onReorderTo;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final itemHeight = compact ? 18.0 : 46.0;
    final gap = compact ? 1.0 : 4.0;
    final footerHeight = compact ? 12.0 : 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        if (available < 12) return const SizedBox.shrink();

        var visibleCount = items.length;
        var showFooter = false;

        final allHeight = visibleCount * (itemHeight + gap);
        if (allHeight > available) {
          visibleCount = ((available - footerHeight) / (itemHeight + gap))
              .floor()
              .clamp(0, items.length);
          showFooter = available >= footerHeight && visibleCount < items.length;
        }

        return ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < visibleCount; index++)
                  Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: SizedBox(
                      height: itemHeight,
                      child: _DraggableItem(
                        postIt: items[index],
                        index: index,
                        compact: compact,
                        isPostponed: items[index].isPostponedOn(today),
                        isFocused: focusedPostItId == items[index].id,
                        onTap: () => onPostItTap(items[index]),
                        onReorderTo: onReorderTo,
                      ),
                    ),
                  ),
                if (showFooter)
                  SizedBox(
                    height: footerHeight,
                    child: InkWell(
                      key: Key('day-overflow-${date.toIso8601String()}'),
                      onTap: onShowAll,
                      borderRadius: BorderRadius.circular(4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.moreItems(items.length - visibleCount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 9 : null,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DraggableItem extends StatelessWidget {
  const _DraggableItem({
    required this.postIt,
    required this.index,
    required this.compact,
    required this.isPostponed,
    required this.isFocused,
    required this.onTap,
    required this.onReorderTo,
  });

  final PostIt postIt;
  final int index;
  final bool compact;
  final bool isPostponed;
  final bool isFocused;
  final VoidCallback onTap;
  final void Function(PostIt postIt, int newIndex) onReorderTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<PostItDragData>(
      onWillAcceptWithDetails: (details) => details.data.postIt.id != postIt.id,
      onAcceptWithDetails: (details) => onReorderTo(details.data.postIt, index),
      builder: (context, candidateData, rejectedData) {
        final tile = PostItTile(
          key: Key('post-it-${postIt.id}'),
          postIt: postIt,
          compact: compact,
          isPostponed: isPostponed,
          isFocused: isFocused,
          onTap: onTap,
        );

        return LongPressDraggable<PostItDragData>(
          data: PostItDragData(postIt),
          delay: const Duration(milliseconds: 200),
          dragAnchorStrategy: childDragAnchorStrategy,
          feedback: _DragFeedback(postIt: postIt, compact: compact),
          childWhenDragging: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0.35),
            duration: const Duration(milliseconds: 160),
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: tile,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: candidateData.isNotEmpty
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: tile,
          ),
        );
      },
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.postIt, required this.compact});

  final PostIt postIt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 200,
          height: compact ? 26 : 52,
          child: PostItTile(postIt: postIt, compact: compact),
        ),
      ),
    );
  }
}
