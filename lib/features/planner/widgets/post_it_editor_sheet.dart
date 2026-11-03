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
    ),
  );
}

class PostItEditorSheet extends StatefulWidget {
  const PostItEditorSheet({
    super.key,
    required this.controller,
    required this.initialDate,
    this.existing,
  });

  final PlannerController controller;
  final DateOnly initialDate;
  final PostIt? existing;

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
    _type = existing?.type ?? PostItType.task;
    _isHighlight = existing?.isHighlight ?? false;
    _startDate = existing == null
        ? widget.initialDate
        : existing.startDate;
    _endDate = existing?.endDate;
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
      locale: const Locale('pt', 'BR'),
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
      locale: const Locale('pt', 'BR'),
      helpText: AppStrings.fieldEndDate,
    );
    if (picked == null) return;
    setState(() {
      final date = DateOnly.fromDateTime(picked);
      _endDate = date.isSameDay(start) ? null : date;
    });
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
      setState(() => _errors = const [AppStrings.errorSave]);
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
    final availableHeight =
        MediaQuery.sizeOf(context).height - bottomInset;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: availableHeight * 0.95,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
              const SizedBox(height: 16),
              if (_isRecurring)
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: AppStrings.fieldType,
                    border: OutlineInputBorder(),
                  ),
                  child: const Text(AppStrings.recurringType),
                )
              else
                SegmentedButton<PostItType>(
                  showSelectedIcon: false,
                  segments: const [
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
              const SizedBox(height: 16),
              TextField(
                key: const Key('editor-title'),
                controller: _titleController,
                maxLength: 120,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: AppStrings.fieldTitle,
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('editor-details'),
                controller: _detailsController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: AppStrings.fieldDetails,
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              if (!_isRecurringType) ...[
                const SizedBox(height: 8),
                Text(
                  _isEvent
                      ? AppStrings.fieldStartDate
                      : AppStrings.fieldDate,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                if (!_isEvent)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.fieldNoDate),
                    value: _startDate == null,
                    onChanged: (withoutDate) {
                      setState(() {
                        _startDate = withoutDate
                            ? null
                            : (widget.initialDate);
                      });
                    },
                  ),
                if (_isEvent || _startDate != null)
                  _DateField(
                    key: const Key('editor-start-date'),
                    label: AppStrings.fieldStartDate,
                    date: _startDate,
                    onTap: _pickStartDate,
                  ),
                if (_isEvent) ...[
                  const SizedBox(height: 8),
                  _DateField(
                    key: const Key('editor-end-date'),
                    label: AppStrings.fieldEndDate,
                    date: _endDate ?? _startDate,
                    onTap: _pickEndDate,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.fieldHighlight),
                    subtitle: const Text(
                      '${AppStrings.highlightSymbol} ${AppStrings.highlightType}',
                    ),
                    value: _isHighlight,
                    onChanged: (value) =>
                        setState(() => _isHighlight = value),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.repeat,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('editor-save'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text(AppStrings.save),
              ),
              TextButton(
                onPressed: _saving
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
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
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(label),
        subtitle: Text(
          date == null ? AppStrings.undated : DateFormats.shortDate(date!),
          style: theme.textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.edit_outlined),
        onTap: onTap,
      ),
    );
  }
}
