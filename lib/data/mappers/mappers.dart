import 'package:drift/drift.dart';

import '../../core/date_only.dart';
import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';

PostIt postItFromRow(PostItRow row) => PostIt(
  id: row.id,
  title: row.title,
  type: row.type,
  status: row.status,
  isHighlight: row.isHighlight,
  details: row.details,
  noteId: row.noteId,
  noteExcerpt: row.noteExcerpt,
  sourceNoteId: row.sourceNoteId,
  startDate: row.startDate,
  endDate: row.endDate,
  recurrence: row.recurrence,
  recurrenceInterval: row.recurrenceInterval,
  sortOrder: row.sortOrder,
  lastRolloverAt: row.lastRolloverAt == null
      ? null
      : dateTimeFromStorage(row.lastRolloverAt!),
  createdAt: dateTimeFromStorage(row.createdAt),
  updatedAt: dateTimeFromStorage(row.updatedAt),
  deletedAt: row.deletedAt == null ? null : dateTimeFromStorage(row.deletedAt!),
);

PostItsCompanion postItToCompanion(PostIt postIt) => PostItsCompanion(
  id: Value(postIt.id),
  title: Value(postIt.title),
  type: Value(postIt.type),
  status: Value(postIt.status),
  isHighlight: Value(postIt.isHighlight),
  details: Value(postIt.details),
  noteId: Value(postIt.noteId),
  noteExcerpt: Value(postIt.noteExcerpt),
  sourceNoteId: Value(postIt.sourceNoteId),
  startDate: Value<DateOnly?>(postIt.startDate),
  endDate: Value<DateOnly?>(postIt.endDate),
  recurrence: Value(postIt.recurrence),
  recurrenceInterval: Value(postIt.recurrenceInterval),
  sortOrder: Value(postIt.sortOrder),
  lastRolloverAt: Value(
    postIt.lastRolloverAt == null
        ? null
        : dateTimeToStorage(postIt.lastRolloverAt!),
  ),
  createdAt: Value(dateTimeToStorage(postIt.createdAt)),
  updatedAt: Value(dateTimeToStorage(postIt.updatedAt)),
  deletedAt: Value(
    postIt.deletedAt == null ? null : dateTimeToStorage(postIt.deletedAt!),
  ),
);

PostItHistoryEntry postItHistoryFromRow(PostItHistoryRow row) =>
    PostItHistoryEntry(
      id: row.id,
      postItId: row.postItId,
      action: row.action,
      fromValue: row.fromValue,
      toValue: row.toValue,
      createdAt: dateTimeFromStorage(row.createdAt),
    );

PostItHistoryEntriesCompanion postItHistoryToCompanion(
  PostItHistoryEntry entry,
) => PostItHistoryEntriesCompanion(
  id: Value(entry.id),
  postItId: Value(entry.postItId),
  action: Value(entry.action),
  fromValue: Value(entry.fromValue),
  toValue: Value(entry.toValue),
  createdAt: Value(dateTimeToStorage(entry.createdAt)),
);

Note noteFromRows(NoteRow row, List<NoteLineRow> lineRows) => Note(
  id: row.id,
  title: row.title,
  type: row.type,
  lines: [
    for (final line in lineRows)
      NoteLine(
        id: line.id,
        noteId: line.noteId,
        position: line.position,
        text: line.content,
        isChecked: line.isChecked,
      ),
  ],
  markdown: row.markdown,
  createdAt: dateTimeFromStorage(row.createdAt),
  updatedAt: dateTimeFromStorage(row.updatedAt),
  deletedAt: row.deletedAt == null ? null : dateTimeFromStorage(row.deletedAt!),
);

NotesCompanion noteToCompanion(Note note) => NotesCompanion(
  id: Value(note.id),
  title: Value(note.title),
  type: Value(note.type),
  markdown: Value(note.markdown),
  createdAt: Value(dateTimeToStorage(note.createdAt)),
  updatedAt: Value(dateTimeToStorage(note.updatedAt)),
  deletedAt: Value(
    note.deletedAt == null ? null : dateTimeToStorage(note.deletedAt!),
  ),
);

NoteLinesCompanion noteLineToCompanion(NoteLine line) => NoteLinesCompanion(
  id: Value(line.id),
  noteId: Value(line.noteId),
  position: Value(line.position),
  content: Value(line.text),
  isChecked: Value(line.isChecked),
);
