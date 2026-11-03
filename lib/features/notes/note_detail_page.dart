import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/notes_controller.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../planner/widgets/post_it_presentation.dart';
import '../shared/empty_state.dart';
import 'note_editor_page.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final String noteId;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final Set<String> _selectedLines = {};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final notes = AppScope.of(context).notes;
    final planner = AppScope.of(context).planner;

    return ListenableBuilder(
      listenable: Listenable.merge([notes, planner]),
      builder: (context, _) {
        final note = notes.findById(widget.noteId);
        if (note == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.note_alt_outlined,
              title: AppStrings.noteDeleted,
              message: AppStrings.noNotes,
            ),
          );
        }

        final linkedPostIts = [
          for (final postIt in planner.postIts)
            if (postIt.noteId == note.id) postIt,
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(note.title),
            actions: [
              IconButton(
                key: const Key('note-edit'),
                tooltip: AppStrings.edit,
                onPressed: () => _edit(note),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: const Key('note-delete'),
                tooltip: AppStrings.deleteNote,
                onPressed: _busy ? null : () => _delete(note, linkedPostIts),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            note.type == NoteType.checklist
                                ? Icons.checklist
                                : Icons.notes,
                            size: 18,
                          ),
                          label: Text(
                            note.type == NoteType.checklist
                                ? AppStrings.noteTypeChecklist
                                : AppStrings.noteTypeMarkdown,
                          ),
                        ),
                        Chip(
                          label: Text(
                            DateFormats.shortDate(
                              DateOnly.fromDateTime(note.updatedAt),
                            ),
                          ),
                        ),
                        if (linkedPostIts.isNotEmpty)
                          Chip(
                            avatar: const Icon(
                              Icons.link,
                              size: 18,
                            ),
                            label: Text(
                              AppStrings.linkedPostItsCount(
                                linkedPostIts.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('note-create-task'),
                          onPressed: _busy
                              ? null
                              : () => _createTaskFromNote(note),
                          icon: const Icon(Icons.add_task),
                          label: const Text(AppStrings.createTaskFromNote),
                        ),
                        OutlinedButton.icon(
                          key: const Key('note-link-post-it'),
                          onPressed: _busy
                              ? null
                              : () => _linkToPostIt(note),
                          icon: const Icon(Icons.link),
                          label: const Text(AppStrings.linkToPostIt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (note.type == NoteType.text)
                      _MarkdownNoteBody(
                        markdown: note.markdown ?? note.plainText,
                        onCreateSnapshot: _busy
                            ? null
                            : () => _createSnapshotFromMarkdown(note),
                      )
                    else if (note.lines.isEmpty)
                      const EmptyState(
                        icon: Icons.notes,
                        title: AppStrings.noLines,
                        message: AppStrings.selectLinesHint,
                      )
                    else
                      for (final line in note.lines)
                        _NoteLineRow(
                          line: line,
                          selected: _selectedLines.contains(line.id),
                          checklist: true,
                          onSelect: () => setState(() {
                            if (_selectedLines.contains(line.id)) {
                              _selectedLines.remove(line.id);
                            } else {
                              _selectedLines.add(line.id);
                            }
                          }),
                          onChecked: (value) =>
                              _toggleLine(notes, note, line.id, value),
                        ),
                    if (note.type == NoteType.checklist &&
                        note.lines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.selectLinesHint,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (linkedPostIts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.noteLinkedPostIts,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      for (final postIt in linkedPostIts)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.sticky_note_2_outlined),
                            title: Text(postIt.title),
                            subtitle: Text(
                              '${postItTypeLabel(postIt)} · '
                              '${postItDateLabel(postIt)}',
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (note.type == NoteType.checklist && note.lines.isNotEmpty)
                Material(
                  elevation: _selectedLines.isEmpty ? 0 : 8,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 64),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: _selectedLines.isEmpty
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppStrings.selectLinesHint,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  AppStrings.selectedLines(
                                    _selectedLines.length,
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge,
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _selectedLines.clear()),
                                  child: const Text(
                                    AppStrings.clearSelection,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  key: const Key(
                                    'note-create-from-selection',
                                  ),
                                  onPressed: () =>
                                      _createPostItFromSelection(note),
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    AppStrings.createPostItFromSelection,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(Note note) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NoteEditorPage(existing: note),
      ),
    );
    if (mounted) setState(() => _selectedLines.clear());
  }

  Future<void> _toggleLine(
    NotesController notes,
    Note note,
    String lineId,
    bool checked,
  ) async {
    try {
      await notes.setLineChecked(note, lineId, checked);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noteSaveError)),
        );
      }
    }
  }

  Future<void> _createPostItFromSelection(Note note) async {
    final planner = AppScope.of(context).planner;
    final selected = [
      for (final line in note.lines)
        if (_selectedLines.contains(line.id)) line,
    ];
    if (selected.isEmpty) return;
    final excerpt = selected.map((line) => line.text).join('\n');
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _SnapshotDialog(
        initialTitle: selected.first.text,
        excerpt: excerpt,
      ),
    );
    if (title == null) return;

    setState(() => _busy = true);
    try {
      await planner.createPostIt(
        title: title,
        type: PostItType.task,
        noteExcerpt: excerpt,
      );
      if (!mounted) return;
      setState(() => _selectedLines.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedMessage)),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.createPostItError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createSnapshotFromMarkdown(Note note) async {
    final planner = AppScope.of(context).planner;
    final markdown = note.markdown ?? note.plainText;
    if (markdown.trim().isEmpty) return;

    final selection = await showDialog<_MarkdownSnapshot>(
      context: context,
      builder: (dialogContext) => _MarkdownSnapshotDialog(
        initialTitle: note.title,
        markdown: markdown,
      ),
    );
    if (selection == null) return;

    setState(() => _busy = true);
    try {
      await planner.createPostIt(
        title: selection.title,
        type: PostItType.task,
        noteExcerpt: selection.excerpt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedMessage)),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.createPostItError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTaskFromNote(Note note) async {
    setState(() => _busy = true);
    try {
      await AppScope.of(context).planner.createPostIt(
        title: note.title,
        type: PostItType.task,
        noteId: note.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.savedMessage)),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.createPostItError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _linkToPostIt(Note note) async {
    final planner = AppScope.of(context).planner;
    final candidates = [
      for (final postIt in planner.postIts)
        if (!postIt.isEvent) postIt,
    ];
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectPostItEmpty)),
      );
      return;
    }

    final selected = await showDialog<PostIt>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.selectPostIt),
        content: SizedBox(
          width: 420.0.clamp(0, MediaQuery.sizeOf(context).width * 0.85),
          height: 360,
          child: ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final postIt = candidates[index];
              return ListTile(
                leading: Icon(postItIcon(postIt)),
                title: Text(postIt.title),
                subtitle: Text(postItDateLabel(postIt)),
                onTap: () => Navigator.of(dialogContext).pop(postIt),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) return;

    try {
      await planner.linkNote(selected, note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.statusUpdatedMessage)),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.linkNoteError)),
        );
      }
    }
  }

  Future<void> _delete(Note note, List<PostIt> linkedPostIts) async {
    final notes = AppScope.of(context).notes;
    final planner = AppScope.of(context).planner;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteNoteQuestion),
        content: Text(
          linkedPostIts.isEmpty
              ? AppStrings.deleteNoteExplanation
              : AppStrings.deleteNoteLinkedWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-note'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await notes.deleteNote(note);
      await planner.refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noteDeleteError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _MarkdownNoteBody extends StatelessWidget {
  const _MarkdownNoteBody({
    required this.markdown,
    required this.onCreateSnapshot,
  });

  final String markdown;
  final VoidCallback? onCreateSnapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = markdown.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              key: const Key('note-create-from-markdown'),
              onPressed: isEmpty ? null : onCreateSnapshot,
              icon: const Icon(Icons.content_copy, size: 18),
              label: const Text(AppStrings.createPostItFromMarkdown),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isEmpty)
          const EmptyState(
            icon: Icons.notes,
            title: AppStrings.noMarkdown,
            message: AppStrings.markdownHint,
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: MarkdownBody(
              data: markdown,
              selectable: true,
              // No caderno, Enter deve preservar a quebra de linha visível.
              softLineBreak: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge,
                blockSpacing: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _NoteLineRow extends StatelessWidget {
  const _NoteLineRow({
    required this.line,
    required this.selected,
    required this.checklist,
    required this.onSelect,
    required this.onChecked,
  });

  final NoteLine line;
  final bool selected;
  final bool checklist;
  final VoidCallback onSelect;
  final ValueChanged<bool> onChecked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Semantics(
          button: true,
          hint: AppStrings.selectLinesHint,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onLongPress: () {
              HapticFeedback.selectionClick();
              onSelect();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (checklist)
                    Checkbox(
                      value: line.isChecked,
                      onChanged: (value) => onChecked(value ?? false),
                    ),
                  Expanded(
                    child: Text(
                      line.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: checklist && line.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnapshotDialog extends StatefulWidget {
  const _SnapshotDialog({
    required this.initialTitle,
    required this.excerpt,
  });

  final String initialTitle;
  final String excerpt;

  @override
  State<_SnapshotDialog> createState() => _SnapshotDialogState();
}

class _SnapshotDialogState extends State<_SnapshotDialog> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTitle.trim().isEmpty
          ? ''
          : widget.initialTitle.trim().substring(
              0,
              widget.initialTitle.trim().length.clamp(0, 120),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.createPostItFromSelection),
      content: SizedBox(
        width: 520.0.clamp(0, MediaQuery.sizeOf(context).width * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('snapshot-title'),
              controller: _titleController,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: AppStrings.fieldTitle,
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.noteExcerptTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.excerpt,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noteSnapshotHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const Key('confirm-snapshot'),
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) return;
            Navigator.of(context).pop(title);
          },
          child: const Text(AppStrings.createPostItFromSelection),
        ),
      ],
    );
  }
}

/// Trecho escolhido numa nota Markdown para virar snapshot.
class _MarkdownSnapshot {
  const _MarkdownSnapshot({required this.title, required this.excerpt});

  final String title;
  final String excerpt;
}

class _MarkdownSnapshotDialog extends StatefulWidget {
  const _MarkdownSnapshotDialog({
    required this.initialTitle,
    required this.markdown,
  });

  final String initialTitle;
  final String markdown;

  @override
  State<_MarkdownSnapshotDialog> createState() =>
      _MarkdownSnapshotDialogState();
}

class _MarkdownSnapshotDialogState extends State<_MarkdownSnapshotDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final title = widget.initialTitle.trim();
    _titleController = TextEditingController(
      text: title.length > 120 ? title.substring(0, 120) : title,
    );
    _contentController = TextEditingController(text: widget.markdown);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _selectWholeNote() {
    _contentController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _contentController.text.length,
    );
  }

  void _confirm() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final full = _contentController.text;
    var excerpt = full;
    final selection = _contentController.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final start = selection.start.clamp(0, full.length);
      final end = selection.end.clamp(0, full.length);
      final selected = full.substring(start, end);
      if (selected.trim().isNotEmpty) excerpt = selected;
    }
    Navigator.of(context).pop(
      _MarkdownSnapshot(title: title, excerpt: excerpt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text(AppStrings.createPostItFromMarkdown),
      content: SizedBox(
        width: 560.0.clamp(0, MediaQuery.sizeOf(context).width * 0.85),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('snapshot-title'),
                controller: _titleController,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: AppStrings.fieldTitle,
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.snapshotSelectionHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('snapshot-markdown'),
                controller: _contentController,
                readOnly: true,
                minLines: 8,
                maxLines: 14,
                keyboardType: TextInputType.multiline,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('snapshot-whole-note'),
                  onPressed: _selectWholeNote,
                  child: const Text(AppStrings.selectWholeNote),
                ),
              ),
              Text(
                AppStrings.noteSnapshotHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const Key('confirm-markdown-snapshot'),
          onPressed: _confirm,
          child: const Text(AppStrings.createPostItFromSelection),
        ),
      ],
    );
  }
}
