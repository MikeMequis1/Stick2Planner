import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/routines_controller.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../../domain/usecases/routine_sections.dart';
import '../shared/hold_to_delete_button.dart';
import '../shared/reorder_helpers.dart';

/// Cria/edita uma rotina simples ou completa e suas atividades.
class RoutineEditorPage extends StatefulWidget {
  const RoutineEditorPage({super.key, this.existing});

  final Routine? existing;

  @override
  State<RoutineEditorPage> createState() => _RoutineEditorPageState();
}

class _RoutineEditorPageState extends State<RoutineEditorPage> {
  final Uuid _uuid = const Uuid();
  late final TextEditingController _name;
  late final TextEditingController _details;
  late Set<int> _weekdays;
  late List<_RoutineItemDraft> _items;
  late List<_SectionDraft> _sections;
  late RoutineMode _mode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _details = TextEditingController(text: existing?.details ?? '');
    _weekdays = existing == null ? {1, 2, 3, 4, 5} : {...existing.weekdays};
    _mode = existing?.mode ?? RoutineMode.simple;
    _items = existing == null || existing.items.isEmpty
        ? [_RoutineItemDraft.empty()]
        : [for (final item in existing.items) _RoutineItemDraft.from(item)];
    _sections = [
      for (final section in existing?.sections ?? const <RoutineSection>[])
        _SectionDraft.from(section),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    for (final item in _items) {
      item.dispose();
    }
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _items.add(_RoutineItemDraft.empty()));

  void _removeItem(int index) {
    final removed = _items.removeAt(index);
    removed.dispose();
    if (_items.isEmpty) _items.add(_RoutineItemDraft.empty());
    setState(() {});
  }

  void _reorderItems(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex.clamp(0, _items.length), item);
    });
  }

  void _addSection() {
    setState(() => _sections.add(_SectionDraft.empty(_uuid.v4())));
  }

  Future<void> _removeSection(int index) async {
    final section = _sections[index];
    if (section.hasTasks) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppStrings.routineSectionDelete),
          content: Text(AppStrings.routineSectionDeleteBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              key: const Key('routine-section-delete-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppStrings.delete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (!mounted) return;
    setState(() {
      _sections.removeAt(index).dispose();
    });
  }

  void _reorderSections(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final section = _sections.removeAt(oldIndex);
      _sections.insert(newIndex.clamp(0, _sections.length), section);
    });
  }

  Future<int?> _pickMinutes(String helpText, int? initial) async {
    final base = initial == null
        ? const TimeOfDay(hour: 8, minute: 0)
        : TimeOfDay(hour: initial ~/ 60, minute: initial % 60);
    final picked = await showTimePicker(
      context: context,
      initialTime: base,
      helpText: helpText,
    );
    if (picked == null) return null;
    return picked.hour * 60 + picked.minute;
  }

  Future<void> _setSectionBoundary(
    _SectionDraft draft, {
    required bool isStart,
  }) async {
    final minutes = await _pickMinutes(
      isStart ? AppStrings.routineSectionStart : AppStrings.routineSectionEnd,
      isStart ? draft.startMinutes : draft.endMinutes,
    );
    if (minutes == null) return;
    final nextStart = isStart ? minutes : draft.startMinutes;
    final nextEnd = isStart ? draft.endMinutes : minutes;
    if (nextStart != null && nextEnd != null && nextEnd <= nextStart) {
      _showMessage(AppStrings.routineSectionEndBeforeStart);
      return;
    }
    if (nextStart != null &&
        draft.intervals.length > 1 &&
        nextStart >= draft.intervals[1].startMinutes) {
      _showMessage(AppStrings.routineSectionInvalidInterval);
      return;
    }
    if (nextEnd != null &&
        draft.intervals.length > 1 &&
        nextEnd <= draft.intervals[draft.intervals.length - 2].endMinutes) {
      _showMessage(AppStrings.routineSectionInvalidInterval);
      return;
    }

    final updated = configureSection(
      draft.toDomain(),
      startMinutes: nextStart,
      endMinutes: nextEnd,
      idGenerator: _uuid.v4,
      now: DateTime.now().toUtc(),
    );
    _applySection(draft, updated);
  }

  Future<void> _addSectionTime(_SectionDraft draft) async {
    final minutes = await _pickMinutes(
      AppStrings.routineSectionAddTime,
      draft.intervals.isEmpty ? null : draft.intervals.first.startMinutes + 60,
    );
    if (minutes == null) return;
    try {
      final updated = addSectionTime(
        draft.toDomain(),
        minutes: minutes,
        idGenerator: _uuid.v4,
        now: DateTime.now().toUtc(),
      );
      _applySection(draft, updated);
    } on RoutineSectionValidationException {
      _showMessage(AppStrings.routineSectionInvalidInterval);
    }
  }

  Future<void> _editSectionTime(_SectionDraft draft, int currentMinutes) async {
    final minutes = await _pickMinutes(
      AppStrings.routineEditTime,
      currentMinutes,
    );
    if (minutes == null) return;
    try {
      final updated = moveSectionTime(
        draft.toDomain(),
        fromMinutes: currentMinutes,
        toMinutes: minutes,
        now: DateTime.now().toUtc(),
      );
      _applySection(draft, updated);
    } on RoutineSectionValidationException {
      _showMessage(AppStrings.routineSectionInvalidInterval);
    }
  }

  Future<void> _removeSectionTime(_SectionDraft draft, int minutes) async {
    final rightIndex = draft.intervals.indexWhere(
      (interval) => interval.startMinutes == minutes,
    );
    if (rightIndex <= 0) return;
    final left = draft.intervals[rightIndex - 1];
    final right = draft.intervals[rightIndex];
    String? keepId;
    if (left.hasTask && right.hasTask) {
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppStrings.routineMergeTitle),
          content: Text(AppStrings.routineMergeBody),
          actions: [
            TextButton(
              key: const Key('routine-merge-left'),
              onPressed: () => Navigator.of(dialogContext).pop('left'),
              child: Text(AppStrings.routineKeepLeft),
            ),
            FilledButton(
              key: const Key('routine-merge-right'),
              onPressed: () => Navigator.of(dialogContext).pop('right'),
              child: Text(AppStrings.routineKeepRight),
            ),
          ],
        ),
      );
      if (choice == null) return;
      if (choice == 'right') {
        left.title.text = right.title.text;
        left.details.text = right.details.text;
        left.completedDates = {...right.completedDates};
      }
      keepId = left.id;
    }
    try {
      final updated = removeSectionTime(
        draft.toDomain(),
        minutes: minutes,
        keepIntervalId: keepId,
        now: DateTime.now().toUtc(),
      );
      _applySection(draft, updated);
    } on RoutineSectionValidationException {
      _showMessage(AppStrings.routineSectionInvalidInterval);
    } on RoutineSectionMergeException {
      _showMessage(AppStrings.routineMergeBody);
    }
  }

  void _clearIntervalTask(_SectionDraft draft, _IntervalDraft interval) {
    setState(() {
      interval.title.clear();
      interval.details.clear();
      interval.completedDates = {};
    });
  }

  void _applySection(_SectionDraft draft, RoutineSection updated) {
    setState(() {
      draft.startMinutes = updated.startMinutes;
      draft.endMinutes = updated.endMinutes;
      final existing = {
        for (final interval in draft.intervals) interval.id: interval,
      };
      final next = <_IntervalDraft>[];
      for (final interval in updated.intervals) {
        final current = existing.remove(interval.id);
        if (current == null) {
          next.add(
            _IntervalDraft(
              id: interval.id,
              startMinutes: interval.startMinutes,
              endMinutes: interval.endMinutes,
              completedDates: {...interval.completedDates},
            ),
          );
        } else {
          current.startMinutes = interval.startMinutes;
          current.endMinutes = interval.endMinutes;
          current.title.text = interval.title ?? '';
          current.details.text = interval.details ?? '';
          current.completedDates = {...interval.completedDates};
          next.add(current);
        }
      }
      for (final removed in existing.values) {
        removed.dispose();
      }
      draft.intervals = next;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final controller = AppScope.of(context).routines;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.saveRoutine(
        id: widget.existing?.id,
        name: _name.text,
        details: _details.text,
        mode: _mode,
        weekdays: _weekdays,
        items: [
          for (final item in _items)
            RoutineItemInput(
              id: item.id,
              title: item.title.text,
              details: item.details.text,
            ),
        ],
        sections: _mode == RoutineMode.complete
            ? [for (final section in _sections) section.toDomain()]
            : const [],
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FormatException catch (error) {
      final message = switch (error.message) {
        'routine_empty_name' => AppStrings.routineNameRequired,
        'routine_no_weekdays' => AppStrings.routineNoDays,
        'routine_name_too_long' => AppStrings.routineNameRequired,
        _ => AppStrings.errorSave,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on RoutineSectionValidationException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(_sectionErrorMessage(error.errors.first))),
      );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _sectionErrorMessage(RoutineSectionValidationError error) =>
      switch (error) {
        RoutineSectionValidationError.titleEmpty =>
          AppStrings.routineSectionTitleRequired,
        RoutineSectionValidationError.missingBoundary =>
          AppStrings.routineSectionMissingBoundary,
        RoutineSectionValidationError.endBeforeStart =>
          AppStrings.routineSectionEndBeforeStart,
        RoutineSectionValidationError.taskTitleTooLong =>
          AppStrings.errorTitleLong,
        _ => AppStrings.routineSectionInvalidInterval,
      };

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.routineDeleteTitle),
        content: Text(AppStrings.routineDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('routine-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final controller = AppScope.of(context).routines;
    try {
      await controller.deleteRoutine(existing);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.errorDelete)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? AppStrings.routineNew
              : AppStrings.routineEdit,
        ),
        actions: [
          if (widget.existing != null)
            IconButton(
              key: const Key('routine-delete'),
              tooltip: AppStrings.delete,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            key: const Key('routine-save'),
            onPressed: _saving ? null : _save,
            child: Text(AppStrings.save),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 900 ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('routine-name'),
                      controller: _name,
                      maxLength: 80,
                      decoration: InputDecoration(
                        labelText: AppStrings.routineName,
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('routine-details'),
                      controller: _details,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppStrings.routineDescription,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.routineMode,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<RoutineMode>(
                      key: const Key('routine-mode'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: RoutineMode.simple,
                          label: Text(AppStrings.routineSimple),
                        ),
                        ButtonSegment(
                          value: RoutineMode.complete,
                          label: Text(AppStrings.routineComplete),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: widget.existing != null
                          ? null
                          : (selection) =>
                                setState(() => _mode = selection.first),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _mode == RoutineMode.simple
                          ? AppStrings.routineSimpleHelp
                          : AppStrings.routineCompleteHelp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.routineDays,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (var day = 1; day <= 7; day++)
                          FilterChip(
                            key: Key('routine-day-$day'),
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
                    if (widget.existing != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.routineCreatedOn(
                              DateFormats.shortDate(
                                DateOnly.fromDateTime(
                                  widget.existing!.createdAt.toLocal(),
                                ),
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_mode == RoutineMode.simple)
                      _buildSimpleItems(theme)
                    else
                      _buildCompleteSections(theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleItems(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.routineActivities,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              key: const Key('routine-add-item'),
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.routineAddItem),
            ),
          ],
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          proxyDecorator: reorderProxyDecorator,
          itemCount: _items.length,
          onReorderItem: _reorderItems,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Padding(
              key: ObjectKey(item),
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: Key('routine-item-title-$index'),
                              controller: item.title,
                              decoration: InputDecoration(
                                labelText: AppStrings.routineItemTitle,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          ReorderHandle(
                            key: Key('routine-item-handle-$index'),
                            index: index,
                          ),
                          HoldToDeleteButton(
                            key: Key('routine-item-delete-$index'),
                            semanticLabel: AppStrings.holdToDelete,
                            onDelete: () => _removeItem(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        key: Key('routine-item-details-$index'),
                        controller: item.details,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppStrings.routineItemDescription,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompleteSections(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.routineComplete,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              key: const Key('routine-add-section'),
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.routineSectionNew),
            ),
          ],
        ),
        if (_sections.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.routineNoItems,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: reorderProxyDecorator,
            itemCount: _sections.length,
            onReorderItem: _reorderSections,
            itemBuilder: (context, index) => Padding(
              key: ObjectKey(_sections[index]),
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSectionCard(theme, index),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard(ThemeData theme, int index) {
    final section = _sections[index];
    final scheme = theme.colorScheme;
    final intermediate = section.intervals.length > 1
        ? section.intervals.sublist(1).map((i) => i.startMinutes).toList()
        : const <int>[];
    return Card(
      key: Key('routine-section-${section.id}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: Key('routine-section-title-$index'),
                    controller: section.title,
                    decoration: InputDecoration(
                      labelText: AppStrings.routineSectionTitle,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                ReorderHandle(index: index),
                HoldToDeleteButton(
                  key: Key('routine-section-delete-${section.id}'),
                  semanticLabel: AppStrings.holdToDelete,
                  onDelete: () => _removeSection(index),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: Key('routine-section-start-$index'),
                    onPressed: () =>
                        _setSectionBoundary(section, isStart: true),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      section.startMinutes == null
                          ? AppStrings.routineSectionStart
                          : DateFormats.clockTime(section.startMinutes!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: Key('routine-section-end-$index'),
                    onPressed: () =>
                        _setSectionBoundary(section, isStart: false),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      section.endMinutes == null
                          ? AppStrings.routineSectionEnd
                          : DateFormats.clockTime(section.endMinutes!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!section.configured)
              Text(
                AppStrings.routineSectionNoTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.routineActivities,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  TextButton.icon(
                    key: Key('routine-section-add-time-$index'),
                    onPressed: () => _addSectionTime(section),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(AppStrings.routineSectionAddTime),
                  ),
                ],
              ),
              for (final minutes in intermediate)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormats.clockTime(minutes),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      IconButton(
                        key: Key('routine-time-edit-${section.id}-$minutes'),
                        tooltip: AppStrings.routineEditTime,
                        onPressed: () => _editSectionTime(section, minutes),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      IconButton(
                        key: Key('routine-time-remove-${section.id}-$minutes'),
                        tooltip: AppStrings.routineRemoveTime,
                        onPressed: () => _removeSectionTime(section, minutes),
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                      ),
                    ],
                  ),
                ),
              if (section.intervals.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppStrings.routineSectionNoIntervals,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (
                  var intervalIndex = 0;
                  intervalIndex < section.intervals.length;
                  intervalIndex++
                )
                  _buildIntervalRow(
                    theme,
                    section,
                    section.intervals[intervalIndex],
                    intervalIndex,
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalRow(
    ThemeData theme,
    _SectionDraft section,
    _IntervalDraft interval,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timelapse,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${DateFormats.clockTime(interval.startMinutes)} – '
                  '${DateFormats.clockTime(interval.endMinutes)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (interval.hasTask)
                  TextButton(
                    key: Key('routine-interval-clear-${interval.id}'),
                    onPressed: () => _clearIntervalTask(section, interval),
                    child: Text(AppStrings.routineNoTask),
                  ),
              ],
            ),
            TextField(
              key: Key('routine-interval-title-${section.id}-$index'),
              controller: interval.title,
              decoration: InputDecoration(
                labelText: AppStrings.routineTaskTitle,
                hintText: AppStrings.routineNoTask,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: Key('routine-interval-details-${section.id}-$index'),
              controller: interval.details,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: AppStrings.routineTaskDetails,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RoutineItemDraft {
  _RoutineItemDraft({this.id, required String title, String? details})
    : title = TextEditingController(text: title),
      details = TextEditingController(text: details ?? '');

  factory _RoutineItemDraft.empty() => _RoutineItemDraft(title: '');

  factory _RoutineItemDraft.from(RoutineItem item) =>
      _RoutineItemDraft(id: item.id, title: item.title, details: item.details);

  final String? id;
  final TextEditingController title;
  final TextEditingController details;

  void dispose() {
    title.dispose();
    details.dispose();
  }
}

final class _SectionDraft {
  _SectionDraft({
    required this.id,
    String title = '',
    this.startMinutes,
    this.endMinutes,
    List<_IntervalDraft>? intervals,
    this.createdAt,
  }) : title = TextEditingController(text: title),
       intervals = intervals ?? [];

  factory _SectionDraft.empty(String id) => _SectionDraft(id: id);

  factory _SectionDraft.from(RoutineSection section) => _SectionDraft(
    id: section.id,
    title: section.title,
    startMinutes: section.startMinutes,
    endMinutes: section.endMinutes,
    createdAt: section.createdAt,
    intervals: [
      for (final interval in section.intervals)
        _IntervalDraft(
          id: interval.id,
          startMinutes: interval.startMinutes,
          endMinutes: interval.endMinutes,
          title: interval.title,
          details: interval.details,
          completedDates: {...interval.completedDates},
        ),
    ],
  );

  final String id;
  final TextEditingController title;
  int? startMinutes;
  int? endMinutes;
  List<_IntervalDraft> intervals;
  final DateTime? createdAt;

  bool get configured => startMinutes != null && endMinutes != null;
  bool get hasTasks => intervals.any((interval) => interval.hasTask);

  RoutineSection toDomain() => RoutineSection(
    id: id,
    routineId: '',
    title: title.text.trim(),
    position: 0,
    startMinutes: startMinutes,
    endMinutes: endMinutes,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    intervals: [
      for (var index = 0; index < intervals.length; index++)
        intervals[index].toDomain(id, index),
    ],
  );

  void dispose() {
    title.dispose();
    for (final interval in intervals) {
      interval.dispose();
    }
  }
}

final class _IntervalDraft {
  _IntervalDraft({
    required this.id,
    required this.startMinutes,
    required this.endMinutes,
    String? title,
    String? details,
    Set<DateOnly>? completedDates,
  }) : title = TextEditingController(text: title ?? ''),
       details = TextEditingController(text: details ?? ''),
       completedDates = completedDates ?? {};

  final String id;
  int startMinutes;
  int endMinutes;
  final TextEditingController title;
  final TextEditingController details;
  Set<DateOnly> completedDates;

  bool get hasTask => title.text.trim().isNotEmpty;

  RoutineInterval toDomain(String sectionId, int position) => RoutineInterval(
    id: id,
    sectionId: sectionId,
    startMinutes: startMinutes,
    endMinutes: endMinutes,
    position: position,
    title: title.text.trim().isEmpty ? null : title.text.trim(),
    details: details.text.trim().isEmpty ? null : details.text.trim(),
    completedDates: completedDates,
    updatedAt: DateTime.now().toUtc(),
  );

  void dispose() {
    title.dispose();
    details.dispose();
  }
}
