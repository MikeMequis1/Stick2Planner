import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../app/controllers/notes_controller.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Folha de detalhes com acesso às ações explícitas (alternativa aos gestos).
Future<void> showPostItDetailsSheet(
  BuildContext context, {
  required PostIt postIt,
  required PlannerController planner,
  required NotesController notesController,
  required ValueChanged<PostIt> onEdit,
  required ValueChanged<Note> onOpenNote,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final symbol = postItSymbol(postIt);
      final linkedNote = postIt.noteId == null
          ? null
          : notesController.findById(postIt.noteId!);

      Future<void> openNote() async {
        if (linkedNote == null) return;
        Navigator.of(sheetContext).pop();
        onOpenNote(linkedNote);
      }

      Future<void> linkNote() async {
        final candidates = notesController.notes;
        if (candidates.isEmpty) {
          _showMessage(context, AppStrings.noNotes);
          return;
        }
        final selected = await showDialog<Note>(
          context: sheetContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text(AppStrings.selectNote),
            content: SizedBox(
              width: 420.0.clamp(
                0,
                MediaQuery.sizeOf(dialogContext).width * 0.85,
              ),
              height: 360,
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final note = candidates[index];
                  return ListTile(
                    leading: Icon(
                      note.type == NoteType.checklist
                          ? Icons.checklist
                          : Icons.notes,
                    ),
                    title: Text(note.title),
                    subtitle: Text(
                      note.type == NoteType.checklist
                          ? '${note.lines.length} ${AppStrings.noteLines}'
                          : AppStrings.markdownLabel,
                    ),
                    onTap: () => Navigator.of(dialogContext).pop(note),
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
        if (selected == null) return;
        try {
          await planner.linkNote(postIt, selected);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) {
            _showMessage(context, AppStrings.statusUpdatedMessage);
          }
        } on Object {
          if (context.mounted) {
            _showMessage(context, AppStrings.linkNoteError);
          }
        }
      }

      Future<void> unlinkNote() async {
        try {
          await planner.unlinkNote(postIt);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) {
            _showMessage(context, AppStrings.statusUpdatedMessage);
          }
        } on Object {
          if (context.mounted) {
            _showMessage(context, AppStrings.linkNoteError);
          }
        }
      }

      Future<void> edit() async {
        Navigator.of(sheetContext).pop();
        onEdit(postIt);
      }

      Future<void> move() async {
        final picked = await _pickDate(
          sheetContext,
          initial: postIt.startDate ?? planner.selectedDate,
          helpText: AppStrings.moveToDate,
        );
        if (picked == null) return;
        try {
          await planner.movePostIt(postIt, picked);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) _showMessage(context, AppStrings.movedMessage);
        } on Object {
          if (context.mounted) _showMessage(context, AppStrings.errorMove);
        }
      }

      Future<void> resize() async {
        final start = postIt.startDate ?? planner.selectedDate;
        final end = postIt.effectiveEndDate ?? start;
        final newStart = await _pickDate(
          sheetContext,
          initial: start,
          helpText: AppStrings.fieldStartDate,
        );
        if (newStart == null || !sheetContext.mounted) return;
        final newEnd = await _pickDate(
          sheetContext,
          initial: end.isBefore(newStart) ? newStart : end,
          firstDate: newStart,
          helpText: AppStrings.fieldEndDate,
        );
        if (newEnd == null) return;
        try {
          await planner.resizeEvent(
            postIt,
            startDate: newStart,
            endDate: newEnd,
          );
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) _showMessage(context, AppStrings.resizedMessage);
        } on Object {
          if (context.mounted) _showMessage(context, AppStrings.errorResize);
        }
      }

      Future<void> reorder(Future<void> Function() action) async {
        try {
          await action();
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) _showMessage(context, AppStrings.reorderedMessage);
        } on Object {
          if (context.mounted) _showMessage(context, AppStrings.errorReorder);
        }
      }

      Future<void> setStatus(PostItStatus status) async {
        try {
          await planner.setPostItStatus(postIt, status);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) {
            _showMessage(context, AppStrings.statusUpdatedMessage);
          }
        } on Object {
          if (context.mounted) {
            _showMessage(context, AppStrings.errorSave);
          }
        }
      }

      Future<void> delete() async {        final confirmed = await showDialog<bool>(
          context: sheetContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text(AppStrings.deleting),
            content: const Text(AppStrings.deleteExplanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text(AppStrings.cancel),
              ),
              FilledButton(
                key: const Key('confirm-delete'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(AppStrings.confirmDelete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        try {
          await planner.deletePostIt(postIt);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppStrings.deletedMessage),
                action: SnackBarAction(
                  label: AppStrings.undo,
                  onPressed: () async {
                    try {
                      await planner.restorePostIt(postIt);
                      if (context.mounted) {
                        _showMessage(context, AppStrings.restoredMessage);
                      }
                    } on Object {
                      if (context.mounted) {
                        _showMessage(context, AppStrings.errorSave);
                      }
                    }
                  },
                ),
              ),
            );
          }
        } on Object {
          if (context.mounted) _showMessage(context, AppStrings.errorDelete);
        }
      }

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      postItIcon(postIt),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        postIt.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        symbol.isEmpty
                            ? postItTypeLabel(postIt)
                            : '$symbol ${postItTypeLabel(postIt)}',
                      ),
                    ),
                    Chip(label: Text(postItStatusLabel(postIt.status))),
                    if (postIt.noteId != null)
                      Chip(
                        avatar: const Icon(Icons.link, size: 18),
                        label: const Text(AppStrings.linkedNoteChip),
                      ),
                    if (postIt.noteExcerpt != null)
                      Chip(
                        avatar: const Icon(Icons.content_copy, size: 18),
                        label: const Text(AppStrings.noteExcerptChip),
                      ),
                    if (postIt.isRecurring &&
                        postIt.status == PostItStatus.active)
                      Chip(
                        avatar: const Icon(Icons.repeat, size: 18),
                        label: Text(
                          planner.isPostponed(postIt) &&
                                  postIt.startDate != null
                              ? '${AppStrings.postponedUntil} '
                                    '${DateFormats.shortDate(postIt.startDate!)}'
                              : AppStrings.advancesDaily,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: postItDateLabel(postIt),
                ),
                if (postIt.details != null &&
                    postIt.details!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.detailsSection,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(postIt.details!, style: theme.textTheme.bodyMedium),
                ],
                if (postIt.noteExcerpt != null &&
                    postIt.noteExcerpt!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noteExcerptTitle,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      postIt.noteExcerpt!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.noteSnapshotHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (postIt.noteId != null) ...[
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.note_alt_outlined,
                    text: linkedNote != null
                        ? '${AppStrings.linkedNoteTitle}: '
                              '${linkedNote.title}'
                        : '${AppStrings.linkedNoteTitle}: ${postIt.noteId}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.noteLiveLink,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (postIt.isRecurring &&
                    planner.isPostponed(postIt)) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.schedule,
                    text: AppStrings.recurringPostponedHelp,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  AppStrings.actions,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (postIt.status == PostItStatus.active)
                      FilledButton.tonalIcon(
                        key: const Key('details-complete'),
                        onPressed: () =>
                            setStatus(PostItStatus.done),
                        icon: const Icon(Icons.check),
                        label: const Text(AppStrings.statusDoneAction),
                      )
                    else
                      FilledButton.tonalIcon(
                        key: const Key('details-reopen'),
                        onPressed: () =>
                            setStatus(PostItStatus.active),
                        icon: const Icon(Icons.undo),
                        label: const Text(AppStrings.statusReopenAction),
                      ),
                    if (postIt.status != PostItStatus.cancelled)
                      OutlinedButton.icon(
                        key: const Key('details-cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () =>
                            setStatus(PostItStatus.cancelled),
                        icon: const Icon(Icons.close),
                        label: const Text(AppStrings.statusCancelAction),
                      ),
                    FilledButton.tonalIcon(
                      key: const Key('details-edit'),
                      onPressed: edit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(AppStrings.edit),
                    ),
                    OutlinedButton.icon(
                      key: const Key('details-move'),
                      onPressed: move,
                      icon: const Icon(Icons.drive_file_move_outline),
                      label: const Text(AppStrings.moveToDate),
                    ),
                    if (postIt.noteId == null &&
                        notesController.notes.isNotEmpty)
                      OutlinedButton.icon(
                        key: const Key('details-link-note'),
                        onPressed: linkNote,
                        icon: const Icon(Icons.link),
                        label: const Text(AppStrings.linkNote),
                      ),
                    if (postIt.noteId != null) ...[
                      OutlinedButton.icon(
                        key: const Key('details-open-note'),
                        onPressed: linkedNote == null ? null : openNote,
                        icon: const Icon(Icons.note_alt_outlined),
                        label: const Text(AppStrings.openNote),
                      ),
                      OutlinedButton.icon(
                        key: const Key('details-unlink-note'),
                        onPressed: unlinkNote,
                        icon: const Icon(Icons.link_off),
                        label: const Text(AppStrings.unlinkNote),
                      ),
                    ],
                    if (postIt.isEvent)
                      OutlinedButton.icon(
                        key: const Key('details-resize'),
                        onPressed: resize,
                        icon: const Icon(Icons.straighten),
                        label: const Text(AppStrings.changeDuration),
                      ),
                    if (planner.canMovePostItUp(postIt))
                      IconButton.filledTonal(
                        key: const Key('details-move-up'),
                        tooltip: AppStrings.moveUp,
                        onPressed: () =>
                            reorder(() => planner.movePostItUp(postIt)),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    if (planner.canMovePostItDown(postIt))
                      IconButton.filledTonal(
                        key: const Key('details-move-down'),
                        tooltip: AppStrings.moveDown,
                        onPressed: () =>
                            reorder(() => planner.movePostItDown(postIt)),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    OutlinedButton.icon(
                      key: const Key('details-delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(AppStrings.delete),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text(AppStrings.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<DateOnly?> _pickDate(
  BuildContext context, {
  required DateOnly initial,
  required String helpText,
  DateOnly? firstDate,
}) async {
  final first = firstDate ?? DateOnly(2000, 1, 1);
  final picked = await showDatePicker(
    context: context,
    initialDate: initial.toLocalDateTime(),
    firstDate: first.toLocalDateTime(),
    lastDate: DateTime(2100),
    locale: const Locale('pt', 'BR'),
    helpText: helpText,
  );
  return picked == null ? null : DateOnly.fromDateTime(picked);
}

void _showMessage(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
