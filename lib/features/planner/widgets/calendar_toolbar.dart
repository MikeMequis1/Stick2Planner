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
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: 220);

    final navigation = _ToolbarCapsule(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolbarIconButton(
            key: Key('calendar-previous'),
            tooltip: AppStrings.previousPeriod,
            onPressed: onPreviousPeriod,
            icon: Icons.chevron_left,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedSwitcher(
                duration: motion,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: Offset(0.08, 0),
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
            key: Key('calendar-next'),
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
            key: Key('calendar-today'),
            onPressed: onToday,
            style: TextButton.styleFrom(
              minimumSize: Size(0, 38),
              padding: EdgeInsets.symmetric(horizontal: 12),
              shape: StadiumBorder(),
            ),
            child: Text(AppStrings.today),
          ),
          _ToolbarDivider(color: scheme.outlineVariant),
          _ToolbarIconButton(
            key: Key('calendar-mode-decrease'),
            tooltip: AppStrings.decreaseDays,
            onPressed: canDecreaseMode ? onDecreaseMode : null,
            icon: Icons.remove,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              key: Key('calendar-mode-label'),
              child: AnimatedSwitcher(
                duration: motion,
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
            key: Key('calendar-mode-increase'),
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
              SizedBox(width: 16),
              Spacer(),
              controls,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: navigation),
            SizedBox(height: 8),
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
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        minimumSize: Size(36, 36),
        padding: EdgeInsets.zero,
        shape: CircleBorder(),
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
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}
