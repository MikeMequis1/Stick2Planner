import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

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
  final FocusNode _markdownFocus = FocusNode();
  late NoteType _type;
  late List<_LineDraft> _lines;
  final List<_LineDraft> _retiredLines = [];
  bool _saving = false;
  bool _showPreview = false;

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
    _markdownFocus.dispose();
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

  TextSelection _markdownSelection(TextEditingValue value) {
    final selection = value.selection;
    return selection.isValid
        ? selection
        : TextSelection.collapsed(offset: value.text.length);
  }

  void _applyMarkdownValue(String text, TextSelection selection) {
    _markdownController.value = TextEditingValue(
      text: text,
      selection: selection,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markdownFocus.requestFocus();
    });
  }

  /// Envolve a seleção (ou insere um espaço reservado selecionado).
  void _wrapMarkdown(String prefix, String suffix, String placeholder) {
    final value = _markdownController.value;
    final text = value.text;
    final selection = _markdownSelection(value);
    final start = selection.start;
    final end = selection.end;
    final selected = text.substring(start, end);
    final content = selected.isEmpty ? placeholder : selected;
    final replacement = '$prefix$content$suffix';
    final newText = text.replaceRange(start, end, replacement);
    final contentStart = start + prefix.length;
    final newSelection = selected.isEmpty
        ? TextSelection(
            baseOffset: contentStart,
            extentOffset: contentStart + content.length,
          )
        : TextSelection.collapsed(offset: start + replacement.length);
    _applyMarkdownValue(newText, newSelection);
  }

  /// Aplica prefixo em todas as linhas tocadas pela seleção.
  void _prefixMarkdownLines(String marker, {bool numbered = false}) {
    final value = _markdownController.value;
    final text = value.text;
    final selection = _markdownSelection(value);
    final start = selection.start;
    final end = selection.end;
    final lineStart = start == 0 ? 0 : text.lastIndexOf('\n', start - 1) + 1;
    final lineEnd = text.indexOf('\n', end);
    final blockEnd = lineEnd == -1 ? text.length : lineEnd;
    final block = text.substring(lineStart, blockEnd);

    final transformed = <String>[];
    final lines = block.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final raw = lines[index];
      final indent = RegExp(r'^\s*').firstMatch(raw)!.group(0)!;
      final body = raw.substring(indent.length);
      final stripped = body
          .replaceFirst(RegExp(r'^#{1,6}\s+'), '')
          .replaceFirst(RegExp(r'^([-*+]|\d+\.)\s+'), '')
          .replaceFirst(RegExp(r'^>\s+'), '');
      transformed.add(
        numbered ? '$indent${index + 1}. $stripped' : '$indent$marker$stripped',
      );
    }

    final replacement = transformed.join('\n');
    final newText = text.replaceRange(lineStart, blockEnd, replacement);
    _applyMarkdownValue(
      newText,
      TextSelection.collapsed(offset: lineStart + replacement.length),
    );
  }

  void _insertCodeBlock() {
    final value = _markdownController.value;
    final text = value.text;
    final selection = _markdownSelection(value);
    final start = selection.start;
    final end = selection.end;
    final selected = text.substring(start, end);

    if (selected.isEmpty) {
      const insertion = '```\n\n```';
      _applyMarkdownValue(
        text.replaceRange(start, end, insertion),
        TextSelection.collapsed(offset: start + 4),
      );
      return;
    }

    final replacement = '```\n$selected\n```';
    _applyMarkdownValue(
      text.replaceRange(start, end, replacement),
      TextSelection.collapsed(offset: start + replacement.length),
    );
  }

  Widget _buildMarkdownToolbar(ThemeData theme) {
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _MarkdownToolButton(
            key: const Key('note-md-h1'),
            label: 'H1',
            tooltip: AppStrings.markdownToolsHeading1,
            onPressed: () => _prefixMarkdownLines('# '),
          ),
          _MarkdownToolButton(
            key: const Key('note-md-h2'),
            label: 'H2',
            tooltip: AppStrings.markdownToolsHeading2,
            onPressed: () => _prefixMarkdownLines('## '),
          ),
          _MarkdownToolButton(
            key: const Key('note-md-h3'),
            label: 'H3',
            tooltip: AppStrings.markdownToolsHeading3,
            onPressed: () => _prefixMarkdownLines('### '),
          ),
          _MarkdownToolDivider(color: scheme.outlineVariant),
          _MarkdownToolIcon(
            key: const Key('note-md-bold'),
            icon: Icons.format_bold,
            tooltip: AppStrings.markdownToolsBold,
            onPressed: () => _wrapMarkdown('**', '**', 'negrito'),
          ),
          _MarkdownToolIcon(
            key: const Key('note-md-italic'),
            icon: Icons.format_italic,
            tooltip: AppStrings.markdownToolsItalic,
            onPressed: () => _wrapMarkdown('*', '*', 'itálico'),
          ),
          _MarkdownToolDivider(color: scheme.outlineVariant),
          _MarkdownToolIcon(
            key: const Key('note-md-bullet'),
            icon: Icons.format_list_bulleted,
            tooltip: AppStrings.markdownToolsBulletList,
            onPressed: () => _prefixMarkdownLines('- '),
          ),
          _MarkdownToolIcon(
            key: const Key('note-md-numbered'),
            icon: Icons.format_list_numbered,
            tooltip: AppStrings.markdownToolsNumberedList,
            onPressed: () => _prefixMarkdownLines('', numbered: true),
          ),
          _MarkdownToolDivider(color: scheme.outlineVariant),
          _MarkdownToolIcon(
            key: const Key('note-md-quote'),
            icon: Icons.format_quote,
            tooltip: AppStrings.markdownToolsQuote,
            onPressed: () => _prefixMarkdownLines('> '),
          ),
          _MarkdownToolIcon(
            key: const Key('note-md-link'),
            icon: Icons.link,
            tooltip: AppStrings.markdownToolsLink,
            onPressed: () => _wrapMarkdown(
              '[',
              '](https://)',
              AppStrings.markdownLinkPlaceholder,
            ),
          ),
          _MarkdownToolIcon(
            key: const Key('note-md-inline-code'),
            icon: Icons.code,
            tooltip: AppStrings.markdownToolsInlineCode,
            onPressed: () => _wrapMarkdown('`', '`', 'código'),
          ),
          _MarkdownToolIcon(
            key: const Key('note-md-code-block'),
            icon: Icons.terminal,
            tooltip: AppStrings.markdownToolsCodeBlock,
            onPressed: _insertCodeBlock,
          ),
          _MarkdownToolDivider(color: scheme.outlineVariant),
          _MarkdownToolIcon(
            key: const Key('note-md-preview'),
            icon: _showPreview
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            tooltip: _showPreview
                ? AppStrings.markdownToolsHidePreview
                : AppStrings.markdownToolsShowPreview,
            selected: _showPreview,
            onPressed: () => setState(() => _showPreview = !_showPreview),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview(ThemeData theme) {
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.markdownPreviewTitle,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _markdownController,
            builder: (context, value, _) {
              if (value.text.trim().isEmpty) {
                return Text(
                  AppStrings.markdownPreviewEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                );
              }
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: value.text,
                    selectable: true,
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      theme,
                    ).copyWith(p: theme.textTheme.bodyMedium, blockSpacing: 8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.noteSaveError)));
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
            _buildMarkdownToolbar(theme),
            if (_showPreview) ...[
              const SizedBox(height: 8),
              _buildMarkdownPreview(theme),
            ],
            const SizedBox(height: 8),
            TextField(
              key: const Key('note-markdown'),
              controller: _markdownController,
              focusNode: _markdownFocus,
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
                      onPressed: index == 0 ? null : () => _moveLine(index, -1),
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

class _MarkdownToolButton extends StatelessWidget {
  const _MarkdownToolButton({
    super.key,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(40, 36),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _MarkdownToolIcon extends StatelessWidget {
  const _MarkdownToolIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 36),
        padding: EdgeInsets.zero,
        foregroundColor: selected ? scheme.primary : null,
        backgroundColor: selected ? scheme.primaryContainer : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _MarkdownToolDivider extends StatelessWidget {
  const _MarkdownToolDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}

class _LineDraft {
  _LineDraft({this.id, required String text, this.isChecked = false})
    : controller = TextEditingController(text: text);

  factory _LineDraft.empty() => _LineDraft(text: '');

  final String? id;
  final TextEditingController controller;
  bool isChecked;
}
