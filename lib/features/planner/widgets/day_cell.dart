import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_drag_data.dart';
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
  });

  final CalendarDay day;
  final List<PostIt> items;
  final bool isSelected;
  final bool isToday;
  final DateOnly today;
  final bool compact;
  final VoidCallback onTap;
  final ValueChanged<PostIt> onPostItTap;
  final VoidCallback onShowAll;
  final ValueChanged<PostIt> onMoveToDay;
  final void Function(PostIt postIt, int newIndex) onReorderTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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

        return Padding(
          padding: const EdgeInsets.all(1.5),
          child: Material(
            color: isDropTarget
                ? scheme.primaryContainer.withValues(alpha: 0.45)
                : (isSelected
                      ? scheme.primaryContainer.withValues(alpha: 0.28)
                      : (muted
                            ? scheme.surfaceContainerLowest
                            : scheme.surface)),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: isDropTarget ? 2 : (isSelected ? 1.8 : 0.6),
                  ),
                ),
                padding: EdgeInsets.all(compact ? 2 : 4),
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
        );
      },
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
          Container(
            key: Key('day-number-${date.toIso8601String()}'),
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
  });

  final DateOnly date;
  final DateOnly today;
  final List<PostIt> items;
  final bool compact;
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
    required this.onTap,
    required this.onReorderTo,
  });

  final PostIt postIt;
  final int index;
  final bool compact;
  final bool isPostponed;
  final VoidCallback onTap;
  final void Function(PostIt postIt, int newIndex) onReorderTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<PostItDragData>(
      onWillAcceptWithDetails: (details) =>
          details.data.postIt.id != postIt.id,
      onAcceptWithDetails: (details) =>
          onReorderTo(details.data.postIt, index),
      builder: (context, candidateData, rejectedData) {
        final tile = PostItTile(
          key: Key('post-it-${postIt.id}'),
          postIt: postIt,
          compact: compact,
          isPostponed: isPostponed,
          onTap: onTap,
        );

        return LongPressDraggable<PostItDragData>(
          data: PostItDragData(postIt),
          dragAnchorStrategy: childDragAnchorStrategy,
          feedback: _DragFeedback(postIt: postIt, compact: compact),
          childWhenDragging: Opacity(opacity: 0.35, child: tile),
          child: DecoratedBox(
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
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 200,
        height: compact ? 26 : 52,
        child: PostItTile(postIt: postIt, compact: compact),
      ),
    );
  }
}
