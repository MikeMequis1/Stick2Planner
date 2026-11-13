import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/note.dart';
import '../shared/desktop_context_menu.dart';
import '../shared/empty_state.dart';
import 'note_detail_page.dart';
import 'note_editor_page.dart';

enum _NoteContextAction { open, edit, delete }

/// Caderno privado, independente dos post-its.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = AppScope.of(context).notes;

    return ListenableBuilder(
      listenable: notes,
      builder: (context, _) {
        if (notes.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final items = [...notes.notes]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.noteCount(items.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacer(),
                  FilledButton.icon(
                    key: Key('add-note'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => NoteEditorPage(),
                      ),
                    ),
                    icon: Icon(Icons.add),
                    label: Text(AppStrings.newNote),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                        icon: Icons.edit_note_outlined,
                        title: AppStrings.emptyNotes,
                        message: AppStrings.notesEmptyMessage,
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = items[index];
                          return DesktopContextMenuRegion(
                            onOpen: (position) =>
                                _showContextMenu(context, note, position),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                key: Key('note-${note.id}'),
                                leading: Icon(
                                  note.type == NoteType.checklist
                                      ? Icons.checklist
                                      : Icons.notes,
                                ),
                                title: Text(note.title),
                                subtitle: Text(
                                  note.type == NoteType.text
                                      ? '${AppStrings.markdownLabel} · '
                                            '${DateFormats.shortDate(DateOnly.fromDateTime(note.updatedAt))}'
                                      : '${note.lines.length} ${AppStrings.noteLines} · '
                                            '${DateFormats.shortDate(DateOnly.fromDateTime(note.updatedAt))}',
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        NoteDetailPage(noteId: note.id),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    Note note,
    Offset globalPosition,
  ) async {
    final action = await showDesktopContextMenu<_NoteContextAction>(
      context,
      globalPosition: globalPosition,
      items: [
        PopupMenuItem(
          value: _NoteContextAction.open,
          child: Text(AppStrings.openNote),
        ),
        PopupMenuItem(
          value: _NoteContextAction.edit,
          child: Text(AppStrings.edit),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _NoteContextAction.delete,
          child: Text(AppStrings.delete),
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _NoteContextAction.open:
        await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => NoteDetailPage(noteId: note.id)),
        );
      case _NoteContextAction.edit:
        await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => NoteEditorPage(existing: note)),
        );
      case _NoteContextAction.delete:
        await _delete(context, note);
    }
  }

  Future<void> _delete(BuildContext context, Note note) async {
    final notes = AppScope.of(context).notes;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.deleteNoteQuestion),
        content: Text(AppStrings.deleteNoteExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await notes.deleteNote(note);
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.deletedMessage)),
      );
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.noteDeleteError)),
      );
    }
  }
}
