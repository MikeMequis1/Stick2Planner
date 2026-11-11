import '../../core/date_only.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/tag.dart';

/// Entidades sincronizáveis. Preferências e credenciais ficam locais.
const syncEntityPostIt = 'postIt';
const syncEntityNote = 'note';
const syncEntityHistory = 'history';
const syncEntityTag = 'tag';
const syncEntityRoutine = 'routine';

Map<String, Object?> postItPayload(PostIt postIt) => {
  'id': postIt.id,
  'title': postIt.title,
  'type': postIt.type.name,
  'status': postIt.status.name,
  'isHighlight': postIt.isHighlight,
  'details': postIt.details,
  'noteId': postIt.noteId,
  'noteExcerpt': postIt.noteExcerpt,
  'sourceNoteId': postIt.sourceNoteId,
  'startDate': postIt.startDate?.toIso8601String(),
  'endDate': postIt.endDate?.toIso8601String(),
  'recurrence': postIt.recurrence.name,
  'recurrenceInterval': postIt.recurrenceInterval,
  'timeMinutes': postIt.timeMinutes,
  'reminderMinutes': postIt.reminderMinutes,
  'tagIds': postIt.tagIds,
  'sortOrder': postIt.sortOrder,
  'lastRolloverAt': postIt.lastRolloverAt?.toUtc().toIso8601String(),
  'createdAt': postIt.createdAt.toUtc().toIso8601String(),
  'updatedAt': postIt.updatedAt.toUtc().toIso8601String(),
  'deletedAt': postIt.deletedAt?.toUtc().toIso8601String(),
};

PostIt postItFromPayload(Map<String, Object?> payload) => PostIt(
  id: _text(payload, 'id'),
  title: _text(payload, 'title'),
  type: _enum(PostItType.values, _text(payload, 'type')),
  status: _enum(PostItStatus.values, _text(payload, 'status')),
  isHighlight: _flag(payload, 'isHighlight'),
  details: _optionalText(payload, 'details'),
  noteId: _optionalText(payload, 'noteId'),
  noteExcerpt: _optionalText(payload, 'noteExcerpt'),
  sourceNoteId: _optionalText(payload, 'sourceNoteId'),
  startDate: _optionalDate(payload, 'startDate'),
  endDate: _optionalDate(payload, 'endDate'),
  recurrence: _optionalEnum(
    EventRecurrence.values,
    payload['recurrence'],
    EventRecurrence.none,
  ),
  recurrenceInterval: _optionalInteger(payload, 'recurrenceInterval', 1),
  timeMinutes: _optionalNullableInteger(payload, 'timeMinutes'),
  reminderMinutes: _optionalNullableInteger(payload, 'reminderMinutes'),
  tagIds: _stringList(payload['tagIds']),
  sortOrder: _integer(payload, 'sortOrder'),
  lastRolloverAt: _optionalTime(payload, 'lastRolloverAt'),
  createdAt: _time(payload, 'createdAt'),
  updatedAt: _time(payload, 'updatedAt'),
  deletedAt: _optionalTime(payload, 'deletedAt'),
);

/// Nota completa, com linhas e checklists no mesmo payload.
Map<String, Object?> notePayload(Note note) => {
  'id': note.id,
  'title': note.title,
  'type': note.type.name,
  'markdown': note.markdown,
  'createdAt': note.createdAt.toUtc().toIso8601String(),
  'updatedAt': note.updatedAt.toUtc().toIso8601String(),
  'deletedAt': note.deletedAt?.toUtc().toIso8601String(),
  'lines': [
    for (final line in note.lines)
      {
        'id': line.id,
        'noteId': line.noteId,
        'position': line.position,
        'text': line.text,
        'isChecked': line.isChecked,
      },
  ],
};

Note noteFromPayload(Map<String, Object?> payload) {
  final rawLines = payload['lines'];
  if (rawLines is! List) {
    throw const FormatException('note.lines ausente');
  }
  return Note(
    id: _text(payload, 'id'),
    title: _text(payload, 'title'),
    type: _enum(NoteType.values, _text(payload, 'type')),
    markdown: _optionalText(payload, 'markdown'),
    createdAt: _time(payload, 'createdAt'),
    updatedAt: _time(payload, 'updatedAt'),
    deletedAt: _optionalTime(payload, 'deletedAt'),
    lines: [
      for (final raw in rawLines)
        if (raw is Map<String, Object?>)
          NoteLine(
            id: _text(raw, 'id'),
            noteId: _text(raw, 'noteId'),
            position: _integer(raw, 'position'),
            text: _text(raw, 'text'),
            isChecked: _flag(raw, 'isChecked'),
          )
        else
          throw const FormatException('note.lines inválido'),
    ],
  );
}

Map<String, Object?> historyPayload(PostItHistoryEntry entry) => {
  'id': entry.id,
  'postItId': entry.postItId,
  'action': entry.action.name,
  'fromValue': entry.fromValue,
  'toValue': entry.toValue,
  'createdAt': entry.createdAt.toUtc().toIso8601String(),
};

PostItHistoryEntry historyFromPayload(Map<String, Object?> payload) =>
    PostItHistoryEntry(
      id: _text(payload, 'id'),
      postItId: _text(payload, 'postItId'),
      action: _enum(PostItHistoryAction.values, _text(payload, 'action')),
      fromValue: _optionalText(payload, 'fromValue'),
      toValue: _optionalText(payload, 'toValue'),
      createdAt: _time(payload, 'createdAt'),
    );

Map<String, Object?> tagPayload(Tag tag) => {
  'id': tag.id,
  'name': tag.name,
  'tone': tag.tone.name,
  'createdAt': tag.createdAt.toUtc().toIso8601String(),
  'updatedAt': tag.updatedAt.toUtc().toIso8601String(),
  'deletedAt': tag.deletedAt?.toUtc().toIso8601String(),
};

Tag tagFromPayload(Map<String, Object?> payload) => Tag(
  id: _text(payload, 'id'),
  name: _text(payload, 'name'),
  tone: payload['tone'] == 'tertiarySoft'
      ? TagTone.tertiary
      : _optionalEnum(TagTone.values, payload['tone'], TagTone.primary),
  createdAt: _time(payload, 'createdAt'),
  updatedAt: _time(payload, 'updatedAt'),
  deletedAt: _optionalTime(payload, 'deletedAt'),
);

/// Rotina e atividades como uma unidade atômica.
///
/// `deletedAt` é usado no tombstone de exclusão; a rotina em si não guarda o
/// campo no banco, mas o payload precisa dele para o servidor propagar a remoção.
Map<String, Object?> routinePayload(Routine routine, {DateTime? deletedAt}) => {
  'id': routine.id,
  'name': routine.name,
  'details': routine.details,
  'weekdays': routine.weekdays.toList()..sort(),
  'items': [
    for (final item in routine.items)
      {
        'id': item.id,
        'title': item.title,
        'details': item.details,
        'position': item.position,
        'completedDates': [
          for (final date in item.completedDates.toList()..sort())
            date.toIso8601String(),
        ],
      },
  ],
  'createdAt': routine.createdAt.toUtc().toIso8601String(),
  'updatedAt': routine.updatedAt.toUtc().toIso8601String(),
  'deletedAt': deletedAt?.toUtc().toIso8601String(),
};

Routine routineFromPayload(Map<String, Object?> payload) {
  final routineId = _text(payload, 'id');
  final rawItems = payload['items'];
  final items = <RoutineItem>[];
  if (rawItems is List) {
    for (var index = 0; index < rawItems.length; index++) {
      final raw = rawItems[index];
      if (raw is! Map) continue;
      final item = Map<String, Object?>.from(raw);
      items.add(
        RoutineItem(
          id: _text(item, 'id'),
          routineId: routineId,
          title: _text(item, 'title'),
          details: _optionalText(item, 'details'),
          position: _optionalInteger(item, 'position', index),
          completedDates: _dateList(item['completedDates']),
        ),
      );
    }
  }
  items.sort((a, b) => a.position.compareTo(b.position));
  return Routine(
    id: routineId,
    name: _text(payload, 'name'),
    details: _optionalText(payload, 'details'),
    weekdays: _integerList(payload['weekdays']).toSet(),
    items: items,
    createdAt: _time(payload, 'createdAt'),
    updatedAt: _time(payload, 'updatedAt'),
  );
}

String _text(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('$key inválido');
}

String? _optionalText(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$key inválido');
}

bool _flag(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value is bool) return value;
  throw FormatException('$key inválido');
}

int _integer(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value is int) return value;
  throw FormatException('$key inválido');
}

DateTime _time(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value is! String) throw FormatException('$key inválido');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('$key inválido');
  return parsed.toUtc();
}

DateTime? _optionalTime(Map<String, Object?> payload, String key) =>
    payload[key] == null ? null : _time(payload, key);

DateOnly? _optionalDate(Map<String, Object?> payload, String key) {
  final value = payload[key];
  if (value == null) return null;
  if (value is! String) throw FormatException('$key inválido');
  return DateOnly.parse(value);
}

T _enum<T extends Enum>(List<T> values, String name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('valor enum inválido: $name');
}

T _optionalEnum<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is! String) return fallback;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}

int _optionalInteger(Map<String, Object?> payload, String key, int fallback) {
  final value = payload[key];
  if (value is int) return value;
  return fallback;
}

int? _optionalNullableInteger(Map<String, Object?> payload, String key) {
  final value = payload[key];
  return value is int ? value : null;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final value in raw)
      if (value is String && value.isNotEmpty) value,
  ];
}

List<int> _integerList(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final value in raw)
      if (value is int) value,
  ];
}

Set<DateOnly> _dateList(Object? raw) {
  if (raw is! List) return const {};
  final dates = <DateOnly>{};
  for (final value in raw) {
    if (value is! String) continue;
    try {
      dates.add(DateOnly.parse(value));
    } on Object {
      // Ignora data inválida isolada sem perder o restante da rotina.
    }
  }
  return dates;
}
