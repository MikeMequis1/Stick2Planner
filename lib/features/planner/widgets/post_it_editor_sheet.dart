import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_strings.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/post_it.dart';
import '../../../domain/entities/tag.dart';
import '../../../domain/usecases/validate_post_it.dart';
import '../../tags/tag_presentation.dart';
import '../../tags/tags_page.dart';
import 'post_it_presentation.dart';
import 'validation_messages.dart';

/// Abre o formulário de criação/edição.
Future<void> showPostItEditorSheet(
  BuildContext context, {
  required PlannerController controller,
  required DateOnly initialDate,
  PostIt? existing,
  PostItType initialType = PostItType.task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => PostItEditorSheet(
      controller: controller,
      initialDate: initialDate,
      existing: existing,
      initialType: initialType,
    ),
  );
}

class PostItEditorSheet extends StatefulWidget {
  const PostItEditorSheet({
    super.key,
    required this.controller,
    required this.initialDate,
    this.existing,
    this.initialType = PostItType.task,
  });

  final PlannerController controller;
  final DateOnly initialDate;
  final PostIt? existing;
  final PostItType initialType;

  @override
  State<PostItEditorSheet> createState() => _PostItEditorSheetState();
}

class _PostItEditorSheetState extends State<PostItEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  late PostItType _type;
  late bool _isHighlight;
  late DateOnly? _startDate;
  DateOnly? _endDate;
  late EventRecurrence _recurrence;
  late int _recurrenceInterval;
  TimeOfDay? _time;
  int? _reminderMinutes;
  late List<String> _selectedTagIds;
  bool _saving = false;
  List<String> _errors = const [];

  bool get _isRecurring => widget.existing?.isRecurring ?? false;

  bool get _isEvent => _type == PostItType.event;

  bool get _isRecurringType => _type == PostItType.recurringTodo;

  bool get _isResolved =>
      widget.existing != null && widget.existing!.status != PostItStatus.active;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _detailsController = TextEditingController(text: existing?.details ?? '');
    _type = existing?.type ?? widget.initialType;
    _isHighlight = existing?.isHighlight ?? false;
    _startDate = existing == null ? widget.initialDate : existing.startDate;
    _endDate = existing?.endDate;
    _recurrence = existing?.recurrence ?? EventRecurrence.none;
    _recurrenceInterval = existing?.recurrenceInterval ?? 1;
    final minutes = existing?.timeMinutes;
    _time = minutes == null
        ? null
        : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    _reminderMinutes = existing?.reminderMinutes;
    _selectedTagIds = [...?existing?.tagIds];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _changeType(PostItType type) {
    if (_isRecurring || type == _type) return;
    setState(() {
      _type = type;
      if (type == PostItType.event) {
        _startDate ??= widget.initialDate;
        if (_endDate != null &&
            _startDate != null &&
            _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
        if (_endDate != null && _endDate!.isSameDay(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = null;
        _isHighlight = false;
        _recurrence = EventRecurrence.none;
        _recurrenceInterval = 1;
        _time = null;
        _reminderMinutes = null;
        if (type == PostItType.recurringTodo) {
          _startDate = null;
        } else {
          _startDate ??= widget.initialDate;
        }
      }
    });
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? widget.initialDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.toLocalDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale('pt', 'BR'),
      helpText: AppStrings.fieldStartDate,
    );
    if (picked == null) return;
    final date = DateOnly.fromDateTime(picked);
    setState(() {
      _startDate = date;
      if (_endDate != null && _endDate!.isBefore(date)) {
        _endDate = _isEvent ? date : null;
      }
      if (_endDate != null && _endDate!.isSameDay(date)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final start = _startDate ?? widget.initialDate;
    final initial = _endDate ?? start;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.toLocalDateTime(),
      firstDate: start.toLocalDateTime(),
      lastDate: DateTime(2100),
      locale: Locale('pt', 'BR'),
      helpText: AppStrings.fieldEndDate,
    );
    if (picked == null) return;
    setState(() {
      final date = DateOnly.fromDateTime(picked);
      _endDate = date.isSameDay(start) ? null : date;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      helpText: AppStrings.eventTime,
    );
    if (picked == null) return;
    setState(() => _time = picked);
  }

  void _showDoneInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.fieldHighlight),
        content: Text(AppStrings.doneInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  /// Card único de descrição do tipo, no mesmo padrão do antigo card de
  /// Pendência. Ele acompanha a seleção de tipo e o estado Feito.
  Widget _typeDescriptionCard(ThemeData theme) {
    final highlighted = _isHighlight && _isEvent;
    final description = highlighted
        ? AppStrings.doneInfo
        : postItTypeDescription(_type);
    final icon = highlighted ? Icons.edit_outlined : postItTypeIcon(_type);
    return Card(
      key: const Key('editor-type-description'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                key: const Key('editor-type-description-text'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recurrenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<EventRecurrence>(
          key: const Key('editor-recurrence'),
          initialValue: _recurrence,
          decoration: InputDecoration(
            labelText: AppStrings.eventRepeat,
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: EventRecurrence.none,
              child: Text(AppStrings.repeatNone),
            ),
            DropdownMenuItem(
              value: EventRecurrence.daily,
              child: Text(AppStrings.repeatDaily),
            ),
            DropdownMenuItem(
              value: EventRecurrence.weekly,
              child: Text(AppStrings.repeatWeekly),
            ),
            DropdownMenuItem(
              value: EventRecurrence.monthly,
              child: Text(AppStrings.repeatMonthly),
            ),
            DropdownMenuItem(
              value: EventRecurrence.yearly,
              child: Text(AppStrings.repeatYearly),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _recurrence = value;
              if (value == EventRecurrence.weekly) {
                _recurrenceInterval = _recurrenceInterval.clamp(1, 12);
              } else if (value == EventRecurrence.monthly) {
                _recurrenceInterval = _recurrenceInterval.clamp(1, 24);
              } else {
                _recurrenceInterval = 1;
              }
            });
          },
        ),
        if (_recurrence == EventRecurrence.weekly) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: const Key('editor-recurrence-weeks'),
            initialValue: _recurrenceInterval.clamp(1, 12),
            decoration: InputDecoration(
              labelText: AppStrings.repeatEveryWeeks,
              border: OutlineInputBorder(),
            ),
            items: [
              for (var value = 1; value <= 12; value++)
                DropdownMenuItem(value: value, child: Text('$value')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _recurrenceInterval = value);
              }
            },
          ),
        ],
        if (_recurrence == EventRecurrence.monthly) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: const Key('editor-recurrence-months'),
            initialValue: _recurrenceInterval.clamp(1, 24),
            decoration: InputDecoration(
              labelText: AppStrings.repeatEveryMonths,
              border: OutlineInputBorder(),
            ),
            items: [
              for (var value = 1; value <= 24; value++)
                DropdownMenuItem(value: value, child: Text('$value')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _recurrenceInterval = value);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _tagsSection(List<Tag> tags) {
    final selected = _selectedTagIds.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.settingsTags,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            IconButton(
              key: const Key('editor-manage-tags'),
              tooltip: AppStrings.tagManage,
              visualDensity: VisualDensity.compact,
              onPressed: _openTags,
              icon: const Icon(Icons.settings_outlined, size: 18),
            ),
          ],
        ),
        if (tags.isEmpty)
          Text(
            AppStrings.tagsEmpty,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                TagChip(
                  key: Key('editor-tag-${tag.id}'),
                  tag: tag,
                  selected: selected.contains(tag.id),
                  onTap: () => setState(() {
                    if (!_selectedTagIds.remove(tag.id)) {
                      _selectedTagIds.add(tag.id);
                    }
                  }),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _openTags() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TagsPage()));
    if (mounted) {
      setState(() {
        final available = AppScope.of(context).tags.byIdMap.keys.toSet();
        _selectedTagIds.removeWhere((id) => !available.contains(id));
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errors = const [];
    });

    try {
      final title = _titleController.text;
      final details = _detailsController.text;
      final existing = widget.existing;
      final startDate = _isResolved
          ? existing?.startDate
          : (_isRecurringType ? existing?.startDate : _startDate);
      final endDate = _isResolved
          ? existing?.endDate
          : (_isEvent ? _endDate : null);
      final canSchedule = _isEvent || _type == PostItType.task;
      final timeMinutes = _isResolved
          ? existing?.timeMinutes
          : (canSchedule && _time != null
                ? _time!.hour * 60 + _time!.minute
                : null);
      final reminderMinutes = _isResolved
          ? existing?.reminderMinutes
          : (timeMinutes == null ? null : _reminderMinutes);
      final recurrence = _isResolved
          ? (existing?.recurrence ?? EventRecurrence.none)
          : (_isEvent ? _recurrence : EventRecurrence.none);
      final recurrenceInterval = _isResolved
          ? (existing?.recurrenceInterval ?? 1)
          : (_isEvent ? _recurrenceInterval : 1);

      if (existing == null) {
        await widget.controller.createPostIt(
          title: title,
          type: _type,
          isHighlight: _isHighlight,
          details: details,
          startDate: startDate,
          endDate: endDate,
          recurrence: recurrence,
          recurrenceInterval: recurrenceInterval,
          timeMinutes: timeMinutes,
          reminderMinutes: reminderMinutes,
          tagIds: _selectedTagIds,
        );
      } else {
        await widget.controller.updatePostIt(
          existing,
          title: title,
          type: _type,
          isHighlight: _isHighlight,
          details: details,
          startDate: startDate,
          endDate: endDate,
          recurrence: recurrence,
          recurrenceInterval: recurrenceInterval,
          timeMinutes: timeMinutes,
          reminderMinutes: reminderMinutes,
          tagIds: _selectedTagIds,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } on PostItValidationException catch (error) {
      if (!mounted) return;
      setState(() {
        _errors = error.errors.map(postItValidationMessage).toList();
      });
    } on Object {
      if (!mounted) return;
      setState(() => _errors = [AppStrings.errorSave]);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = MediaQuery.sizeOf(context).height - bottomInset;
    final availableTags = AppScope.of(context).tags.tags;

    return AnimatedPadding(
      duration: Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight * 0.95),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null
                    ? AppStrings.newPostIt
                    : AppStrings.editPostIt,
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              if (_isRecurring)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldType,
                    border: OutlineInputBorder(),
                  ),
                  child: Text(AppStrings.recurringType),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final type in PostItType.values)
                      ChoiceChip(
                        key: Key('editor-type-${type.name}'),
                        avatar: Icon(postItTypeIcon(type), size: 18),
                        label: Text(switch (type) {
                          PostItType.task => AppStrings.taskType,
                          PostItType.event => AppStrings.eventType,
                          PostItType.recurringTodo => AppStrings.recurringShort,
                        }),
                        selected: _type == type,
                        showCheckmark: false,
                        onSelected: (_) => _changeType(type),
                      ),
                  ],
                ),
              SizedBox(height: 8),
              _typeDescriptionCard(theme),
              SizedBox(height: 16),
              TextField(
                key: Key('editor-title'),
                controller: _titleController,
                maxLength: 120,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppStrings.fieldTitle,
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                key: Key('editor-details'),
                controller: _detailsController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: AppStrings.fieldDetails,
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              _tagsSection(availableTags),
              if (_isResolved)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_clock_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.resolvedFieldsHidden,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!_isRecurringType) ...[
                SizedBox(height: 8),
                Text(
                  _isEvent ? AppStrings.fieldStartDate : AppStrings.fieldDate,
                  style: theme.textTheme.labelMedium,
                ),
                SizedBox(height: 4),
                if (!_isEvent)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppStrings.fieldNoDate),
                    value: _startDate == null,
                    onChanged: (withoutDate) {
                      setState(() {
                        _startDate = withoutDate ? null : (widget.initialDate);
                      });
                    },
                  ),
                if (_isEvent || _startDate != null)
                  _DateField(
                    key: Key('editor-start-date'),
                    label: AppStrings.fieldStartDate,
                    date: _startDate,
                    onTap: _pickStartDate,
                  ),
                if (_isEvent) ...[
                  SizedBox(height: 8),
                  _DateField(
                    key: Key('editor-end-date'),
                    label: AppStrings.fieldEndDate,
                    date: _endDate ?? _startDate,
                    onTap: _pickEndDate,
                  ),
                ],
                if (_isEvent || _type == PostItType.task) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('editor-time'),
                          onPressed: _pickTime,
                          icon: const Icon(Icons.schedule),
                          label: Text(
                            _time == null
                                ? AppStrings.eventTimeAdd
                                : '${AppStrings.eventTime}: '
                                      '${DateFormats.clockTime(_time!.hour * 60 + _time!.minute)}',
                          ),
                        ),
                      ),
                      if (_time != null)
                        IconButton(
                          key: const Key('editor-time-clear'),
                          tooltip: AppStrings.eventTimeClear,
                          onPressed: () => setState(() {
                            _time = null;
                            _reminderMinutes = null;
                          }),
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                  if (_time != null) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<int?>(
                            key: const Key('editor-reminder'),
                            isExpanded: true,
                            value: _reminderMinutes,
                            hint: Text(AppStrings.reminderNone),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text(AppStrings.reminderNone),
                              ),
                              for (final minutes in <int>{
                                5,
                                10,
                                15,
                                30,
                                60,
                                ?_reminderMinutes,
                              })
                                DropdownMenuItem<int?>(
                                  value: minutes,
                                  child: Text(
                                    AppStrings.reminderMinutes(minutes),
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _reminderMinutes = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                if (_isEvent) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.edit_outlined),
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(AppStrings.fieldHighlight),
                        IconButton(
                          key: const Key('editor-done-info'),
                          tooltip: AppStrings.doneInfo,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _showDoneInfo,
                          icon: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    value: _isHighlight,
                    onChanged: (value) => setState(() => _isHighlight = value),
                  ),
                  _recurrenceSection(),
                ],
              ],
              if (_errors.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final error in _errors)
                        Text(
                          error,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              FilledButton.icon(
                key: Key('editor-save'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.save_outlined),
                label: Text(AppStrings.save),
              ),
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: Text(AppStrings.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateOnly? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.calendar_today_outlined),
        title: Text(label),
        subtitle: Text(
          date == null ? AppStrings.undated : DateFormats.shortDate(date!),
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Icon(Icons.edit_outlined),
        onTap: onTap,
      ),
    );
  }
}
