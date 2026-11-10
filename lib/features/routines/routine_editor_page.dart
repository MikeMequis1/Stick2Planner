import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/routines_controller.dart';
import '../../domain/entities/routine.dart';

/// Cria/edita uma rotina e suas atividades.
class RoutineEditorPage extends StatefulWidget {
  const RoutineEditorPage({super.key, this.existing});

  final Routine? existing;

  @override
  State<RoutineEditorPage> createState() => _RoutineEditorPageState();
}

class _RoutineEditorPageState extends State<RoutineEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _details;
  late Set<int> _weekdays;
  late List<_RoutineItemDraft> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _details = TextEditingController(text: existing?.details ?? '');
    _weekdays = existing == null ? {1, 2, 3, 4, 5} : {...existing.weekdays};
    _items = existing == null || existing.items.isEmpty
        ? [_RoutineItemDraft.empty()]
        : [for (final item in existing.items) _RoutineItemDraft.from(item)];
  }

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    for (final item in _items) {
      item.dispose();
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

  void _moveItem(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _items.length) return;
    setState(() {
      final item = _items.removeAt(index);
      _items.insert(target, item);
    });
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
        weekdays: _weekdays,
        items: [
          for (final item in _items)
            RoutineItemInput(
              id: item.id,
              title: item.title.text,
              details: item.details.text,
            ),
        ],
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
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          Text(AppStrings.routineDays, style: theme.textTheme.labelLarge),
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
          const SizedBox(height: 20),
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
          for (var index = 0; index < _items.length; index++)
            Padding(
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
                              controller: _items[index].title,
                              decoration: InputDecoration(
                                labelText: AppStrings.routineItemTitle,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: AppStrings.moveUp,
                            onPressed: index == 0
                                ? null
                                : () => _moveItem(index, -1),
                            icon: const Icon(Icons.arrow_upward, size: 18),
                          ),
                          IconButton(
                            tooltip: AppStrings.moveDown,
                            onPressed: index == _items.length - 1
                                ? null
                                : () => _moveItem(index, 1),
                            icon: const Icon(Icons.arrow_downward, size: 18),
                          ),
                          IconButton(
                            tooltip: AppStrings.delete,
                            onPressed: () => _removeItem(index),
                            icon: const Icon(Icons.delete_outline, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        key: Key('routine-item-details-$index'),
                        controller: _items[index].details,
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
            ),
          const SizedBox(height: 80),
        ],
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
