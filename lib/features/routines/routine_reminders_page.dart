import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/routines_controller.dart';
import '../../core/date_formatting.dart';
import '../../domain/entities/routine.dart';

/// Configura lembretes locais de uma rotina ou de suas atividades.
class RoutineRemindersPage extends StatefulWidget {
  const RoutineRemindersPage({super.key, required this.routine});

  final Routine routine;

  @override
  State<RoutineRemindersPage> createState() => _RoutineRemindersPageState();
}

class _RoutineRemindersPageState extends State<RoutineRemindersPage> {
  late List<RoutineReminder> _reminders;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reminders = [...widget.routine.reminders];
  }

  List<_ReminderTarget> get _targets {
    final targets = <_ReminderTarget>[const _ReminderTarget(label: null)];
    for (final item in widget.routine.items) {
      targets.add(_ReminderTarget(label: item.title, itemId: item.id));
    }
    for (final section in widget.routine.sections) {
      for (final interval in section.intervals) {
        if (!interval.hasTask) continue;
        targets.add(
          _ReminderTarget(
            label: '${section.title} · ${interval.title}',
            intervalId: interval.id,
          ),
        );
      }
    }
    return targets;
  }

  Future<void> _addOrEdit([RoutineReminder? existing]) async {
    final result = await showDialog<RoutineReminder>(
      context: context,
      builder: (dialogContext) => _ReminderEditorDialog(
        routine: widget.routine,
        targets: _targets,
        existing: existing,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final index = _reminders.indexWhere((item) => item.id == result.id);
      if (index < 0) {
        _reminders.add(result);
      } else {
        _reminders[index] = result;
      }
    });
  }

  Future<void> _delete(RoutineReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.reminderDelete),
        content: Text(_targetLabel(reminder)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _reminders.removeWhere((item) => item.id == reminder.id));
  }

  String _targetLabel(RoutineReminder reminder) {
    for (final target in _targets) {
      if (target.itemId != null && target.itemId == reminder.itemId) {
        return target.label!;
      }
      if (target.intervalId != null &&
          target.intervalId == reminder.intervalId) {
        return target.label!;
      }
    }
    return AppStrings.reminderWholeRoutine;
  }

  Future<void> _save() async {
    final controller = AppScope.of(context).routines;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.saveRoutine(
        id: widget.routine.id,
        name: widget.routine.name,
        details: widget.routine.details,
        mode: widget.routine.mode,
        weekdays: widget.routine.weekdays,
        items: [
          for (final item in widget.routine.items)
            RoutineItemInput(
              id: item.id,
              title: item.title,
              details: item.details,
            ),
        ],
        sections: widget.routine.sections,
        reminders: _reminders,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.reminders),
        actions: [
          TextButton(
            key: const Key('save-reminders'),
            onPressed: _saving ? null : _save,
            child: Text(AppStrings.save),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-reminder'),
        onPressed: _saving ? null : () => _addOrEdit(),
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(AppStrings.addReminder),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (_reminders.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.noReminders,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final reminder in _reminders)
              Card(
                key: Key('reminder-${reminder.id}'),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    reminder.paused
                        ? Icons.pause_circle_outline
                        : reminder.enabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  ),
                  title: Text(_targetLabel(reminder)),
                  subtitle: Text(
                    reminder.mode == RoutineReminderMode.frequency
                        ? '${reminder.timesPerDay}x · '
                              '${DateFormats.clockTime(reminder.startMinutes)}'
                              '–${DateFormats.clockTime(reminder.endMinutes)}'
                        : reminder.effectiveTimes
                              .map(DateFormats.clockTime)
                              .join(', '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: AppStrings.edit,
                        onPressed: () => _addOrEdit(reminder),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: AppStrings.delete,
                        onPressed: () => _delete(reminder),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

final class _ReminderTarget {
  const _ReminderTarget({required this.label, this.itemId, this.intervalId});

  final String? label;
  final String? itemId;
  final String? intervalId;

  String? get key => itemId ?? intervalId ?? 'routine';
}

class _ReminderEditorDialog extends StatefulWidget {
  const _ReminderEditorDialog({
    required this.routine,
    required this.targets,
    this.existing,
  });

  final Routine routine;
  final List<_ReminderTarget> targets;
  final RoutineReminder? existing;

  @override
  State<_ReminderEditorDialog> createState() => _ReminderEditorDialogState();
}

class _ReminderEditorDialogState extends State<_ReminderEditorDialog> {
  late RoutineReminderMode _mode;
  late int _timesPerDay;
  late int _startMinutes;
  late int _endMinutes;
  late Set<int> _weekdays;
  late List<int> _times;
  late bool _enabled;
  late bool _paused;
  late String? _targetKey;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _mode = existing?.mode ?? RoutineReminderMode.frequency;
    _timesPerDay = existing?.timesPerDay ?? 3;
    _startMinutes = existing?.startMinutes ?? 8 * 60;
    _endMinutes = existing?.endMinutes ?? 20 * 60;
    _weekdays = existing == null
        ? {...widget.routine.weekdays}
        : {...existing.weekdays};
    _times = [...?existing?.times]..sort();
    _enabled = existing?.enabled ?? true;
    _paused = existing?.paused ?? false;
    _targetKey = existing?.intervalId ?? existing?.itemId ?? 'routine';
  }

  Future<void> _pickTime({
    required int initial,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null) return;
    onPicked(picked.hour * 60 + picked.minute);
  }

  void _submit() {
    final target = widget.targets.cast<_ReminderTarget?>().firstWhere(
      (item) => item?.key == _targetKey,
      orElse: () => null,
    );
    if (_mode == RoutineReminderMode.times && _times.isEmpty) return;
    if (_mode == RoutineReminderMode.frequency &&
        (_timesPerDay < 1 || _endMinutes <= _startMinutes)) {
      return;
    }
    if (_weekdays.isEmpty) return;
    final now = DateTime.now().toUtc();
    Navigator.of(context).pop(
      RoutineReminder(
        id: widget.existing?.id ?? const Uuid().v4(),
        routineId: widget.routine.id,
        itemId: target?.itemId,
        intervalId: target?.intervalId,
        mode: _mode,
        timesPerDay: _timesPerDay,
        startMinutes: _startMinutes,
        endMinutes: _endMinutes,
        times: _times,
        weekdays: {..._weekdays},
        enabled: _enabled,
        paused: _paused,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        widget.existing == null ? AppStrings.addReminder : AppStrings.edit,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                key: const Key('reminder-target'),
                initialValue: _targetKey,
                decoration: InputDecoration(
                  labelText: AppStrings.reminderTarget,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final target in widget.targets)
                    DropdownMenuItem(
                      value: target.key,
                      child: Text(
                        target.label ?? AppStrings.reminderWholeRoutine,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _targetKey = value),
              ),
              const SizedBox(height: 12),
              SegmentedButton<RoutineReminderMode>(
                key: const Key('reminder-mode'),
                segments: [
                  ButtonSegment(
                    value: RoutineReminderMode.frequency,
                    label: Text(AppStrings.reminderByFrequency),
                  ),
                  ButtonSegment(
                    value: RoutineReminderMode.times,
                    label: Text(AppStrings.reminderByTimes),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) =>
                    setState(() => _mode = value.first),
              ),
              const SizedBox(height: 12),
              if (_mode == RoutineReminderMode.frequency) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppStrings.reminderTimesPerDay}: $_timesPerDay',
                      ),
                    ),
                    IconButton(
                      onPressed: _timesPerDay > 1
                          ? () => setState(() => _timesPerDay--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      onPressed: _timesPerDay < 48
                          ? () => setState(() => _timesPerDay++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickTime(
                          initial: _startMinutes,
                          onPicked: (value) =>
                              setState(() => _startMinutes = value),
                        ),
                        child: Text(
                          '${AppStrings.reminderPeriodStart}: '
                          '${DateFormats.clockTime(_startMinutes)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickTime(
                          initial: _endMinutes,
                          onPicked: (value) =>
                              setState(() => _endMinutes = value),
                        ),
                        child: Text(
                          '${AppStrings.reminderPeriodEnd}: '
                          '${DateFormats.clockTime(_endMinutes)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.reminderTimes,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickTime(
                        initial: _times.isEmpty ? 8 * 60 : _times.last + 60,
                        onPicked: (value) => setState(() {
                          _times = ({..._times, value}.toList()..sort());
                        }),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.reminderAddTime),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final minutes in _times)
                      InputChip(
                        label: Text(DateFormats.clockTime(minutes)),
                        onDeleted: () => setState(() => _times.remove(minutes)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(AppStrings.reminderDays, style: theme.textTheme.labelLarge),
              Wrap(
                spacing: 6,
                children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(AppStrings.weekdayShort(day)),
                      selected: _weekdays.contains(day),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _weekdays.add(day);
                        } else {
                          _weekdays.remove(day);
                        }
                      }),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.reminderEnabled),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.reminderPaused),
                value: _paused,
                onChanged: (value) => setState(() => _paused = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const Key('save-reminder'),
          onPressed: _submit,
          child: Text(AppStrings.save),
        ),
      ],
    );
  }
}
