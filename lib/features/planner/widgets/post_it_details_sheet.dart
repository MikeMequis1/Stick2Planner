import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_strings.dart';
import '../../../app/controllers/notes_controller.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/post_it.dart';
import '../../tags/tag_presentation.dart';
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
      final tagsById = AppScope.of(sheetContext).tags.byIdMap;

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
            title: Text(AppStrings.selectNote),
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
                child: Text(AppStrings.cancel),
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
          if (context.mounted) {
            _showMessage(context, AppStrings.reorderedMessage);
          }
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

      Future<void> delete() async {
        final confirmed = await showDialog<bool>(
          context: sheetContext,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppStrings.deleting),
            content: Text(AppStrings.deleteExplanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppStrings.cancel),
              ),
              FilledButton(
                key: Key('confirm-delete'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(AppStrings.confirmDelete),
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
                content: Text(AppStrings.deletedMessage),
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
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (postIt.isEvent)
                      Icon(postItIcon(postIt), color: theme.colorScheme.primary)
                    else
                      ListenableBuilder(
                        listenable: planner,
                        builder: (context, _) {
                          final current =
                              planner.postItById(postIt.id) ?? postIt;
                          final done = current.status == PostItStatus.done;
                          return IconButton(
                            key: const Key('details-complete-icon'),
                            tooltip: done
                                ? AppStrings.statusReopenAction
                                : AppStrings.statusDoneAction,
                            onPressed: () => planner.setPostItStatus(
                              current,
                              done ? PostItStatus.active : PostItStatus.done,
                            ),
                            icon: Icon(
                              postItIcon(current),
                              color: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        postIt.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(postItIcon(postIt), size: 18),
                      label: Text(
                        symbol.isEmpty
                            ? postItTypeLabel(postIt)
                            : '$symbol ${postItTypeLabel(postIt)}',
                      ),
                    ),
                    Chip(label: Text(postItStatusLabel(postIt.status))),
                    if (postIt.timeMinutes != null)
                      Chip(
                        avatar: const Icon(Icons.schedule, size: 18),
                        label: Text(DateFormats.clockTime(postIt.timeMinutes!)),
                      ),
                    for (final tagId in postIt.tagIds)
                      if (tagsById[tagId] != null)
                        TagChip(tag: tagsById[tagId]!),
                    if (postIt.noteId != null)
                      Chip(
                        avatar: Icon(Icons.link, size: 18),
                        label: Text(AppStrings.linkedNoteChip),
                      ),
                    if (postIt.noteExcerpt != null)
                      Chip(
                        avatar: Icon(Icons.content_copy, size: 18),
                        label: Text(AppStrings.noteExcerptChip),
                      ),
                    if (postIt.isRecurring &&
                        postIt.status == PostItStatus.active)
                      Chip(
                        avatar: Icon(Icons.repeat, size: 18),
                        label: Text(
                          planner.isPostponed(postIt) &&
                                  postIt.startDate != null
                              ? '${AppStrings.postponedUntil} '
                                    '${DateFormats.shortDate(postIt.startDate!)}'
                              : AppStrings.advancesDaily,
                        ),
                      ),
                    if (postIt.isRecurringEvent)
                      Chip(
                        avatar: Icon(Icons.event_repeat, size: 18),
                        label: Text(eventRecurrenceLabel(postIt)),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: postItDateLabel(postIt),
                ),
                if (postIt.details != null &&
                    postIt.details!.trim().isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    AppStrings.detailsSection,
                    style: theme.textTheme.labelLarge,
                  ),
                  SizedBox(height: 4),
                  Text(postIt.details!, style: theme.textTheme.bodyMedium),
                ],
                if (postIt.noteExcerpt != null &&
                    postIt.noteExcerpt!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    AppStrings.noteExcerptTitle,
                    style: theme.textTheme.labelLarge,
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      postIt.noteExcerpt!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppStrings.noteSnapshotHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (postIt.noteId != null) ...[
                  SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.note_alt_outlined,
                    text: linkedNote != null
                        ? '${AppStrings.linkedNoteTitle}: '
                              '${linkedNote.title}'
                        : '${AppStrings.linkedNoteTitle}: ${postIt.noteId}',
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppStrings.noteLiveLink,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (postIt.isRecurring && planner.isPostponed(postIt)) ...[
                  SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.schedule,
                    text: AppStrings.recurringPostponedHelp,
                  ),
                ],
                SizedBox(height: 20),
                Text(AppStrings.actions, style: theme.textTheme.labelLarge),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (postIt.status == PostItStatus.active)
                      FilledButton.tonalIcon(
                        key: Key('details-complete'),
                        onPressed: () => setStatus(PostItStatus.done),
                        icon: Icon(Icons.check),
                        label: Text(AppStrings.statusDoneAction),
                      )
                    else
                      FilledButton.tonalIcon(
                        key: Key('details-reopen'),
                        onPressed: () => setStatus(PostItStatus.active),
                        icon: Icon(Icons.undo),
                        label: Text(AppStrings.statusReopenAction),
                      ),
                    if (postIt.status != PostItStatus.cancelled)
                      OutlinedButton.icon(
                        key: Key('details-cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () => setStatus(PostItStatus.cancelled),
                        icon: Icon(Icons.close),
                        label: Text(AppStrings.statusCancelAction),
                      ),
                    FilledButton.tonalIcon(
                      key: Key('details-edit'),
                      onPressed: edit,
                      icon: Icon(Icons.edit_outlined),
                      label: Text(AppStrings.edit),
                    ),
                    OutlinedButton.icon(
                      key: Key('details-move'),
                      onPressed: move,
                      icon: Icon(Icons.drive_file_move_outline),
                      label: Text(AppStrings.moveToDate),
                    ),
                    if (postIt.noteId == null &&
                        notesController.notes.isNotEmpty)
                      OutlinedButton.icon(
                        key: Key('details-link-note'),
                        onPressed: linkNote,
                        icon: Icon(Icons.link),
                        label: Text(AppStrings.linkNote),
                      ),
                    if (postIt.noteId != null) ...[
                      OutlinedButton.icon(
                        key: Key('details-open-note'),
                        onPressed: linkedNote == null ? null : openNote,
                        icon: Icon(Icons.note_alt_outlined),
                        label: Text(AppStrings.openNote),
                      ),
                      OutlinedButton.icon(
                        key: Key('details-unlink-note'),
                        onPressed: unlinkNote,
                        icon: Icon(Icons.link_off),
                        label: Text(AppStrings.unlinkNote),
                      ),
                    ],
                    if (postIt.isEvent)
                      OutlinedButton.icon(
                        key: Key('details-resize'),
                        onPressed: resize,
                        icon: Icon(Icons.straighten),
                        label: Text(AppStrings.changeDuration),
                      ),
                    if (planner.canMovePostItUp(postIt))
                      IconButton.filledTonal(
                        key: Key('details-move-up'),
                        tooltip: AppStrings.moveUp,
                        onPressed: () =>
                            reorder(() => planner.movePostItUp(postIt)),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    if (planner.canMovePostItDown(postIt))
                      IconButton.filledTonal(
                        key: Key('details-move-down'),
                        tooltip: AppStrings.moveDown,
                        onPressed: () =>
                            reorder(() => planner.movePostItDown(postIt)),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    OutlinedButton.icon(
                      key: Key('details-delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: delete,
                      icon: Icon(Icons.delete_outline),
                      label: Text(AppStrings.delete),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(AppStrings.close),
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
    locale: Locale('pt', 'BR'),
    helpText: helpText,
  );
  return picked == null ? null : DateOnly.fromDateTime(picked);
}

void _showMessage(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

String eventRecurrenceLabel(PostIt postIt) {
  return switch (postIt.recurrence) {
    EventRecurrence.daily => AppStrings.repeatSummaryDaily,
    EventRecurrence.weekly => AppStrings.repeatSummaryWeekly(
      postIt.recurrenceInterval,
    ),
    EventRecurrence.monthly => AppStrings.repeatSummaryMonthly(
      postIt.recurrenceInterval,
    ),
    EventRecurrence.yearly => AppStrings.repeatSummaryYearly,
    EventRecurrence.none => AppStrings.repeatNone,
  };
}
