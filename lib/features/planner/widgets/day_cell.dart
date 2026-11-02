import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/entities/post_it.dart';
import '../widgets/post_it_tile.dart';

/// Célula de um dia: cabeçalho, cartões de um dia e indicador "+N mais".
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.items,
    required this.isSelected,
    required this.isToday,
    required this.compact,
    required this.onTap,
    required this.onPostItTap,
    required this.onShowAll,
  });

  final CalendarDay day;
  final List<PostIt> items;
  final bool isSelected;
  final bool isToday;
  final bool compact;
  final VoidCallback onTap;
  final ValueChanged<PostIt> onPostItTap;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = !day.isCurrentMonth;
    final borderColor = isSelected ? scheme.primary : scheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: isSelected
            ? scheme.primaryContainer.withValues(alpha: 0.28)
            : (muted ? scheme.surfaceContainerLowest : scheme.surface),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.8 : 0.6,
              ),
            ),
            padding: EdgeInsets.all(compact ? 2 : 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DayHeader(
                  date: day.date,
                  isSelected: isSelected,
                  isToday: isToday,
                  muted: muted,
                  compact: compact,
                ),
                Expanded(
                  child: _DayContent(
                    date: day.date,
                    items: items,
                    compact: compact,
                    onPostItTap: onPostItTap,
                    onShowAll: onShowAll,
                  ),
                ),
              ],
            ),
          ),
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
  });

  final DateOnly date;
  final bool isSelected;
  final bool isToday;
  final bool muted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = isSelected
        ? scheme.onPrimary
        : (muted ? scheme.outline : scheme.onSurface);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 1 : 4),
      child: Row(
        children: [
          Container(
            key: Key('day-number-${date.toIso8601String()}'),
            width: compact ? 17 : 24,
            height: compact ? 17 : 24,
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
                fontSize: compact ? 9.5 : 12,
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
    required this.items,
    required this.compact,
    required this.onPostItTap,
    required this.onShowAll,
  });

  final DateOnly date;
  final List<PostIt> items;
  final bool compact;
  final ValueChanged<PostIt> onPostItTap;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final itemHeight = compact ? 20.0 : 46.0;
    final gap = compact ? 2.0 : 4.0;
    final footerHeight = compact ? 14.0 : 18.0;

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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < visibleCount; index++)
              Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: SizedBox(
                  height: itemHeight,
                  child: PostItTile(
                    key: Key('post-it-${items[index].id}'),
                    postIt: items[index],
                    compact: compact,
                    onTap: () => onPostItTap(items[index]),
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
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
