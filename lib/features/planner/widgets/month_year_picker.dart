import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';

/// Seletor compacto de mês e ano no estilo do Google Calendar.
///
/// Retorna o primeiro dia do mês escolhido, deixando a agenda decidir qual dia
/// selecionar dentro dele.
Future<DateOnly?> showMonthYearPicker(
  BuildContext context, {
  required DateOnly initial,
}) {
  return showDialog<DateOnly>(
    context: context,
    builder: (dialogContext) => _MonthYearPickerDialog(initial: initial),
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({required this.initial});

  final DateOnly initial;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      key: const Key('month-year-picker'),
      title: Text(AppStrings.selectMonthYear),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('month-picker-previous-year'),
                  tooltip: AppStrings.previousYear,
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    '$_year',
                    key: const Key('month-picker-year'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('month-picker-next-year'),
                  tooltip: AppStrings.nextYear,
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.chooseMonth,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2.1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var month = 1; month <= 12; month++)
                  _MonthButton(
                    year: _year,
                    month: month,
                    selected:
                        _year == widget.initial.year &&
                        month == widget.initial.month,
                    onTap: () =>
                        Navigator.of(context).pop(DateOnly(_year, month, 1)),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('month-picker-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.year,
    required this.month,
    required this.selected,
    required this.onTap,
  });

  final int year;
  final int month;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('month-picker-$year-$month'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            DateFormats.monthName(year, month),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
