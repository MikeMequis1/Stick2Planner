import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/note.dart';
import '../shared/empty_state.dart';
import 'note_detail_page.dart';
import 'note_editor_page.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        final items = [...notes.notes]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.noteCount(items.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    key: const Key('add-note'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const NoteEditorPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.newNote),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.edit_note_outlined,
                        title: AppStrings.emptyNotes,
                        message: AppStrings.notesEmptyMessage,
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = items[index];
                          return Card(
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
                                '${note.lines.length} ${AppStrings.noteLines} · '
                                '${DateFormats.shortDate(DateOnly.fromDateTime(note.updatedAt))}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => NoteDetailPage(
                                    noteId: note.id,
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
}
