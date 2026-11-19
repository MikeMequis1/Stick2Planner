import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';

enum _DashboardPeriod {
  seven(7, '7 dias', '7 days'),
  thirty(30, '30 dias', '30 days'),
  ninety(90, '90 dias', '90 days'),
  all(0, 'Tudo', 'All');

  const _DashboardPeriod(this.days, this.pt, this.en);
  final int days;
  final String pt;
  final String en;

  String get label => AppStrings.isEnglish ? en : pt;
}

/// Dashboard de execução de rotinas, baseado no histórico persistido.
class RoutineDashboardPage extends StatefulWidget {
  const RoutineDashboardPage({super.key});

  @override
  State<RoutineDashboardPage> createState() => _RoutineDashboardPageState();
}

class _RoutineDashboardPageState extends State<RoutineDashboardPage> {
  _DashboardPeriod _period = _DashboardPeriod.thirty;
  String? _targetKey;

  @override
  Widget build(BuildContext context) {
    final routines = AppScope.of(context).routines;
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.dashboard)),
      body: ListenableBuilder(
        listenable: routines,
        builder: (context, _) {
          final entries = _targetEntries(routines.routines);
          final selected = entries
              .where((entry) => entry.key == _targetKey)
              .firstOrNull;
          final executions = _filteredExecutions(routines.executions, selected);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final period in _DashboardPeriod.values)
                    ChoiceChip(
                      label: Text(period.label),
                      selected: _period == period,
                      onSelected: (_) => setState(() => _period = period),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _targetKey,
                decoration: InputDecoration(
                  labelText: AppStrings.dashboardActivity,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(AppStrings.dashboardAllActivities),
                  ),
                  for (final entry in entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _targetKey = value),
              ),
              const SizedBox(height: 16),
              _summary(context, executions),
              const SizedBox(height: 16),
              _chartCard(
                context,
                title: AppStrings.dashboardEvolution,
                child: _LineChart(values: _dailySeries(executions)),
              ),
              const SizedBox(height: 12),
              _chartCard(
                context,
                title: AppStrings.dashboardByPeriod,
                child: _BarChart(values: _bucketSeries(executions)),
              ),
              const SizedBox(height: 12),
              _chartCard(
                context,
                title: AppStrings.dashboardHeatmap,
                child: _Heatmap(
                  counts: _dailyCounts(executions),
                  days: math.min(_period.days == 0 ? 180 : _period.days, 180),
                ),
              ),
              const SizedBox(height: 12),
              _activityTotals(context, routines.routines, executions),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  List<_TargetEntry> _targetEntries(List<Routine> routines) => [
    for (final routine in routines) ...[
      _TargetEntry(
        key: 'routine:${routine.id}',
        label: routine.name,
        routineId: routine.id,
      ),
      for (final item in routine.items)
        _TargetEntry(
          key: 'item:${item.id}',
          label: '${routine.name} · ${item.title}',
          routineId: routine.id,
          itemId: item.id,
        ),
      for (final section in routine.sections)
        for (final interval in section.intervals)
          if (interval.hasTask)
            _TargetEntry(
              key: 'interval:${interval.id}',
              label: '${routine.name} · ${section.title} · ${interval.title}',
              routineId: routine.id,
              intervalId: interval.id,
            ),
    ],
  ];

  List<RoutineExecution> _filteredExecutions(
    List<RoutineExecution> executions,
    _TargetEntry? target,
  ) {
    final today = DateOnly.fromDateTime(DateTime.now());
    final from = _period.days == 0 ? null : today.addDays(-(_period.days - 1));
    return [
      for (final execution in executions)
        if ((from == null || !execution.date.isBefore(from)) &&
            (target == null ||
                (target.itemId != null && execution.itemId == target.itemId) ||
                (target.intervalId != null &&
                    execution.intervalId == target.intervalId) ||
                (target.itemId == null &&
                    target.intervalId == null &&
                    execution.routineId == target.routineId)))
          execution,
    ];
  }

  Map<DateOnly, int> _dailyCounts(List<RoutineExecution> executions) {
    final counts = <DateOnly, int>{};
    for (final execution in executions) {
      counts.update(execution.date, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  List<int> _dailySeries(List<RoutineExecution> executions) {
    final today = DateOnly.fromDateTime(DateTime.now());
    final days = _period.days == 0 ? 90 : _period.days;
    final counts = _dailyCounts(executions);
    return [
      for (var offset = days - 1; offset >= 0; offset--)
        counts[today.addDays(-offset)] ?? 0,
    ];
  }

  List<int> _bucketSeries(List<RoutineExecution> executions) {
    final daily = _dailySeries(executions);
    if (daily.length <= 14) return daily;
    final bucket = (daily.length / 12).ceil();
    return [
      for (var start = 0; start < daily.length; start += bucket)
        daily
            .sublist(start, math.min(start + bucket, daily.length))
            .fold(0, (total, value) => total + value),
    ];
  }

  Widget _summary(BuildContext context, List<RoutineExecution> executions) {
    final counts = _dailyCounts(executions);
    final activeDays = counts.length;
    final total = executions.length;
    final average = activeDays == 0 ? 0.0 : total / activeDays;
    final schedule = [
      for (var offset = 0; offset < 60; offset++)
        DateOnly.fromDateTime(DateTime.now()).addDays(-offset),
    ];
    var streak = 0;
    for (final date in schedule) {
      if ((counts[date] ?? 0) == 0) break;
      streak++;
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metric(context, AppStrings.dashboardExecutions, '$total'),
        _metric(context, AppStrings.dashboardActiveDays, '$activeDays'),
        _metric(context, AppStrings.dashboardStreak, '$streak'),
        _metric(
          context,
          AppStrings.dashboardAverage,
          average.toStringAsFixed(1),
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            SizedBox(height: 120, child: child),
          ],
        ),
      ),
    );
  }

  Widget _activityTotals(
    BuildContext context,
    List<Routine> routines,
    List<RoutineExecution> filtered,
  ) {
    final counts = <String, int>{};
    for (final execution in filtered) {
      final key =
          execution.intervalId ?? execution.itemId ?? execution.routineId;
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }
    final labels = {
      for (final entry in _targetEntries(routines)) entry.key: entry.label,
    };
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppStrings.dashboardEmpty),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.dashboardActivities,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            for (final entry in entries.take(8))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(
                  labels.entries
                          .where(
                            (candidate) =>
                                candidate.key.endsWith(':${entry.key}'),
                          )
                          .firstOrNull
                          ?.value ??
                      entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text('${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}

final class _TargetEntry {
  const _TargetEntry({
    required this.key,
    required this.label,
    required this.routineId,
    this.itemId,
    this.intervalId,
  });

  final String key;
  final String label;
  final String routineId;
  final String? itemId;
  final String? intervalId;
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(
        values: values,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.values, required this.color});
  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max);
    if (maxValue <= 0) return;
    final gap = 3.0;
    final width = (size.width - gap * (values.length - 1)) / values.length;
    final paint = Paint()..color = color;
    for (var index = 0; index < values.length; index++) {
      final height = size.height * values[index] / maxValue;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          index * (width + gap),
          size.height - height,
          math.max(width, 1),
          height,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(
        values: values,
        color: Theme.of(context).colorScheme.secondary,
        gridColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });
  final List<int> values;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var row = 0; row <= 3; row++) {
      final y = size.height * row / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final maxValue = math.max(values.reduce(math.max), 1);
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final y = size.height - size.height * values[index] / maxValue;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.counts, required this.days});

  final Map<DateOnly, int> counts;
  final int days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateOnly.fromDateTime(DateTime.now());
    final values = [
      for (var offset = days - 1; offset >= 0; offset--)
        counts[today.addDays(-offset)] ?? 0,
    ];
    final maxValue = values.isEmpty ? 0 : values.reduce(math.max);
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: [
        for (final value in values)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: value == 0
                  ? scheme.surfaceContainerHighest
                  : scheme.primary.withValues(
                      alpha: 0.25 + 0.75 * value / math.max(maxValue, 1),
                    ),
            ),
          ),
      ],
    );
  }
}
