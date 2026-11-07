import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

PostIt buildPostIt({
  String id = 'postit-1',
  String title = 'Tarefa',
  PostItType type = PostItType.task,
  PostItStatus status = PostItStatus.active,
  bool isHighlight = false,
  String? details,
  String? noteId,
  String? noteExcerpt,
  String? sourceNoteId,
  DateOnly? startDate,
  DateOnly? endDate,
  EventRecurrence recurrence = EventRecurrence.none,
  int recurrenceInterval = 1,
  int? timeMinutes,
  List<String> tagIds = const [],
  int sortOrder = 0,
  DateTime? lastRolloverAt,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final timestamp = createdAt ?? DateTime.utc(2026, 10, 31, 12);
  return PostIt(
    id: id,
    title: title,
    type: type,
    status: status,
    isHighlight: isHighlight,
    details: details,
    noteId: noteId,
    noteExcerpt: noteExcerpt,
    sourceNoteId: sourceNoteId,
    startDate: startDate,
    endDate: endDate,
    recurrence: recurrence,
    recurrenceInterval: recurrenceInterval,
    timeMinutes: timeMinutes,
    tagIds: tagIds,
    sortOrder: sortOrder,
    lastRolloverAt: lastRolloverAt,
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
    deletedAt: deletedAt,
  );
}

Note buildNote({
  String id = 'note-1',
  String title = 'Lista',
  NoteType type = NoteType.checklist,
  List<String> lines = const ['Primeira', 'Segunda'],
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final timestamp = createdAt ?? DateTime.utc(2026, 10, 31, 12);
  return Note(
    id: id,
    title: title,
    type: type,
    lines: [
      for (var index = 0; index < lines.length; index++)
        NoteLine(
          id: '$id-line-$index',
          noteId: id,
          position: index,
          text: lines[index],
        ),
    ],
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
    deletedAt: deletedAt,
  );
}
