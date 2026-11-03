import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../app/planner_view_mode.dart';

/// Cabeçalho da agenda: navegação de período, "Hoje" e ajuste de dias.
class CalendarToolbar extends StatelessWidget {
  const CalendarToolbar({
    super.key,
    required this.periodLabel,
    required this.mode,
    required this.canDecreaseMode,
    required this.canIncreaseMode,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.onToday,
    required this.onDecreaseMode,
    required this.onIncreaseMode,
  });

  final String periodLabel;
  final AgendaViewMode mode;
  final bool canDecreaseMode;
  final bool canIncreaseMode;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onToday;
  final VoidCallback onDecreaseMode;
  final VoidCallback onIncreaseMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final navigation = _ToolbarCapsule(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIconButton(
            key: const Key('calendar-previous'),
            tooltip: AppStrings.previousPeriod,
            onPressed: onPreviousPeriod,
            icon: Icons.chevron_left,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Text(
                  periodLabel,
                  key: ValueKey(periodLabel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          _ToolbarIconButton(
            key: const Key('calendar-next'),
            tooltip: AppStrings.nextPeriod,
            onPressed: onNextPeriod,
            icon: Icons.chevron_right,
          ),
        ],
      ),
    );

    final controls = _ToolbarCapsule(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            key: const Key('calendar-today'),
            onPressed: onToday,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const StadiumBorder(),
            ),
            child: const Text(AppStrings.today),
          ),
          _ToolbarDivider(color: scheme.outlineVariant),
          _ToolbarIconButton(
            key: const Key('calendar-mode-decrease'),
            tooltip: AppStrings.decreaseDays,
            onPressed: canDecreaseMode ? onDecreaseMode : null,
            icon: Icons.remove,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              key: const Key('calendar-mode-label'),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  mode.label,
                  key: ValueKey(mode),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          _ToolbarIconButton(
            key: const Key('calendar-mode-increase'),
            tooltip: AppStrings.increaseDays,
            onPressed: canIncreaseMode ? onIncreaseMode : null,
            icon: Icons.add,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Flexible(child: navigation),
              const SizedBox(width: 16),
              const Spacer(),
              controls,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: navigation),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(fit: BoxFit.scaleDown, child: controls),
            ),
          ],
        );
      },
    );
  }
}

class _ToolbarCapsule extends StatelessWidget {
  const _ToolbarCapsule({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}
