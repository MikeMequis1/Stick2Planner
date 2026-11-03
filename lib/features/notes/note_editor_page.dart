import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/notes_controller.dart';
import '../../domain/entities/note.dart';

/// Edita notas de texto como um único Markdown e listas como linhas.
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.existing});

  final Note? existing;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _markdownController;
  late NoteType _type;
  late List<_LineDraft> _lines;
  final List<_LineDraft> _retiredLines = [];
  bool _saving = false;

  bool get _isText => _type == NoteType.text;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _type = existing?.type ?? NoteType.text;
    _markdownController = TextEditingController(
      text: existing == null || existing.type == NoteType.checklist
          ? ''
          : (existing.markdown ?? existing.plainText),
    );
    _lines = existing == null || existing.lines.isEmpty
        ? [_LineDraft.empty()]
        : [
            for (final line in existing.lines)
              _LineDraft(
                id: line.id,
                text: line.text,
                isChecked: line.isChecked,
              ),
          ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _markdownController.dispose();
    for (final line in [..._lines, ..._retiredLines]) {
      line.controller.dispose();
    }
    super.dispose();
  }

  void _changeType(NoteType next) {
    if (next == _type) return;
    if (next == NoteType.checklist) {
      final parts = _markdownController.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      _retiredLines.addAll(_lines);
      _lines = parts.isEmpty
          ? [_LineDraft.empty()]
          : [for (final part in parts) _LineDraft(text: part)];
      _markdownController.clear();
    } else {
      _markdownController.text = _lines
          .map((line) => line.controller.text.trimRight())
          .where((text) => text.trim().isNotEmpty)
          .join('\n');
      for (final line in _lines) {
        line.isChecked = false;
      }
    }
    setState(() => _type = next);
  }

  void _addLine() {
    setState(() => _lines.add(_LineDraft.empty()));
  }

  void _removeLine(int index) {
    final removed = _lines.removeAt(index);
    _retiredLines.add(removed);
    setState(() {});
  }

  void _moveLine(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _lines.length) return;
    setState(() {
      final line = _lines.removeAt(index);
      _lines.insert(target, line);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final notes = AppScope.of(context).notes;
    try {
      final inputs = [
        for (final line in _lines)
          NoteLineInput(
            id: line.id,
            text: line.controller.text,
            isChecked: line.isChecked,
          ),
      ];
      final markdown = _isText ? _markdownController.text : null;
      if (widget.existing == null) {
        await notes.createNote(
          title: _titleController.text,
          type: _type,
          markdown: markdown,
          lines: inputs,
        );
      } else {
        await notes.updateNote(
          widget.existing!,
          title: _titleController.text,
          type: _type,
          markdown: markdown,
          lines: inputs,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on NoteValidationException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noteTitleRequired)),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noteSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? AppStrings.newNote : AppStrings.editNote,
        ),
        actions: [
          TextButton(
            key: const Key('note-save'),
            onPressed: _saving ? null : _save,
            child: const Text(AppStrings.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('note-title'),
            controller: _titleController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: AppStrings.noteTitle,
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<NoteType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: NoteType.text,
                label: Text(AppStrings.noteTypeText),
              ),
              ButtonSegment(
                value: NoteType.checklist,
                label: Text(AppStrings.noteTypeChecklist),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => _changeType(selection.first),
          ),
          const SizedBox(height: 16),
          if (_isText) ...[
            TextField(
              key: const Key('note-markdown'),
              controller: _markdownController,
              minLines: 12,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.top,
              scrollPadding: const EdgeInsets.only(bottom: 160),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              decoration: const InputDecoration(
                hintText: AppStrings.markdownFieldHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.markdownHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            for (var index = 0; index < _lines.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _lines[index].isChecked,
                      onChanged: (value) => setState(
                        () => _lines[index].isChecked = value ?? false,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        key: Key('note-line-$index'),
                        controller: _lines[index].controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: AppStrings.lineHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.moveUp,
                      onPressed: index == 0
                          ? null
                          : () => _moveLine(index, -1),
                      icon: const Icon(Icons.arrow_upward, size: 18),
                    ),
                    IconButton(
                      tooltip: AppStrings.moveDown,
                      onPressed: index == _lines.length - 1
                          ? null
                          : () => _moveLine(index, 1),
                      icon: const Icon(Icons.arrow_downward, size: 18),
                    ),
                    IconButton(
                      tooltip: AppStrings.delete,
                      onPressed: () => _removeLine(index),
                      icon: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('note-add-line'),
                onPressed: _addLine,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addLine),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.selectLinesHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineDraft {
  _LineDraft({
    this.id,
    required String text,
    this.isChecked = false,
  }) : controller = TextEditingController(text: text);

  factory _LineDraft.empty() => _LineDraft(text: '');

  final String? id;
  final TextEditingController controller;
  bool isChecked;
}
