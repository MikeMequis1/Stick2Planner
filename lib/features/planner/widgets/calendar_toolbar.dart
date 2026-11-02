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

    final navigation = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('calendar-previous'),
          tooltip: AppStrings.previousPeriod,
          onPressed: onPreviousPeriod,
          icon: const Icon(Icons.chevron_left),
        ),
        Flexible(
          child: Text(
            periodLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          key: const Key('calendar-next'),
          tooltip: AppStrings.nextPeriod,
          onPressed: onNextPeriod,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          key: const Key('calendar-today'),
          onPressed: onToday,
          child: const Text(AppStrings.today),
        ),
        const SizedBox(width: 4),
        IconButton(
          key: const Key('calendar-mode-decrease'),
          tooltip: AppStrings.decreaseDays,
          onPressed: canDecreaseMode ? onDecreaseMode : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            mode.label,
            key: const Key('calendar-mode-label'),
            style: theme.textTheme.labelMedium,
          ),
        ),
        IconButton(
          key: const Key('calendar-mode-increase'),
          tooltip: AppStrings.increaseDays,
          onPressed: canIncreaseMode ? onIncreaseMode : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Flexible(child: navigation),
              const Spacer(),
              controls,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            navigation,
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: controls),
          ],
        );
      },
    );
  }
}
