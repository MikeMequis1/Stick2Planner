import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/post_it.dart';
import '../../../domain/usecases/validate_post_it.dart';
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
  bool _saving = false;
  List<String> _errors = const [];

  bool get _isRecurring => widget.existing?.isRecurring ?? false;

  bool get _isEvent => _type == PostItType.event;

  bool get _isRecurringType => _type == PostItType.recurringTodo;

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

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errors = const [];
    });

    try {
      final title = _titleController.text;
      final details = _detailsController.text;
      final startDate = _isRecurringType
          ? widget.existing?.startDate
          : _startDate;
      final endDate = _isEvent ? _endDate : null;

      if (widget.existing == null) {
        await widget.controller.createPostIt(
          title: title,
          type: _type,
          isHighlight: _isHighlight,
          details: details,
          startDate: startDate,
          endDate: endDate,
          recurrence: _isEvent ? _recurrence : EventRecurrence.none,
          recurrenceInterval: _isEvent ? _recurrenceInterval : 1,
        );
      } else {
        await widget.controller.updatePostIt(
          widget.existing!,
          title: title,
          type: _type,
          isHighlight: _isHighlight,
          details: details,
          startDate: startDate,
          endDate: endDate,
          recurrence: _isEvent ? _recurrence : EventRecurrence.none,
          recurrenceInterval: _isEvent ? _recurrenceInterval : 1,
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
                SegmentedButton<PostItType>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: PostItType.task,
                      label: Text(AppStrings.taskType),
                    ),
                    ButtonSegment(
                      value: PostItType.event,
                      label: Text(AppStrings.eventType),
                    ),
                    ButtonSegment(
                      value: PostItType.recurringTodo,
                      label: Text(AppStrings.recurringShort),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      _changeType(selection.first),
                ),
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
              if (!_isRecurringType) ...[
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppStrings.fieldHighlight),
                    subtitle: Text(
                      '${AppStrings.highlightSymbol} ${AppStrings.highlightType}',
                    ),
                    value: _isHighlight,
                    onChanged: (value) => setState(() => _isHighlight = value),
                  ),
                  _recurrenceSection(),
                ],
              ] else ...[
                SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.repeat, color: theme.colorScheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.recurringHelp,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
