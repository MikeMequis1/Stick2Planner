import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/app_info.dart';
import '../../core/date_only.dart';
import '../../data/db/app_database.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import 'backup_document.dart';

/// Snapshot local criado antes de uma importação.
final class BackupSnapshot {
  const BackupSnapshot({
    required this.path,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String path;
  final DateTime createdAt;
  final int sizeBytes;
}

final class BackupImportResult {
  const BackupImportResult({required this.counts, required this.snapshot});

  final BackupCounts counts;
  final BackupSnapshot snapshot;
}

/// Exportação, validação e restauração completas do banco local.
final class BackupService {
  BackupService({
    required AppDatabase database,
    required this.backupDirectory,
    DateTime Function()? now,
    this.appVersion = appVersionString,
  }) : _db = database,
       _now = now ?? DateTime.now;

  static const _snapshotPrefix = 'pre-import-';
  static const _snapshotRetention = 5;

  final AppDatabase _db;
  final Future<Directory> Function() backupDirectory;
  final DateTime Function() _now;
  final String appVersion;

  Future<BackupDocument> buildExport() async {
    final postIts = await (_db.select(
      _db.postIts,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).get();
    final notes = await (_db.select(
      _db.notes,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).get();
    final noteLines =
        await (_db.select(_db.noteLines)..orderBy([
              (table) => OrderingTerm(expression: table.noteId),
              (table) => OrderingTerm(expression: table.position),
              (table) => OrderingTerm(expression: table.id),
            ]))
            .get();
    final history =
        await (_db.select(_db.postItHistoryEntries)..orderBy([
              (table) => OrderingTerm(expression: table.createdAt),
              (table) => OrderingTerm(expression: table.id),
            ]))
            .get();
    final settings =
        await (_db.select(_db.appSettings)
              ..where((table) => table.key.like('planner.sync.%').not())
              ..orderBy([(table) => OrderingTerm(expression: table.key)]))
            .get();

    return BackupDocument(
      schemaVersion: _db.schemaVersion,
      appVersion: appVersion,
      exportedAt: _now().toUtc(),
      data: {
        'postIts': [for (final row in postIts) _postItToJson(row)],
        'notes': [for (final row in notes) _noteToJson(row)],
        'noteLines': [for (final row in noteLines) _noteLineToJson(row)],
        'history': [for (final row in history) _historyToJson(row)],
        'settings': [
          for (final row in settings) {'key': row.key, 'value': row.value},
        ],
      },
    );
  }

  Future<String> exportToJson() async => (await buildExport()).toJsonString();

  /// Cria um snapshot do estado atual e depois substitui tudo pelo backup.
  Future<BackupImportResult> importJson(String raw) async {
    final document = BackupDocument.parse(raw);

    // Garante um snapshot válido antes de qualquer escrita destrutiva.
    final snapshot = await _createSnapshot();

    try {
      await _db.transaction(() async {
        await _db.delete(_db.postItHistoryEntries).go();
        await _db.delete(_db.postIts).go();
        await _db.delete(_db.noteLines).go();
        await _db.delete(_db.notes).go();
        await _db.customStatement(
          "DELETE FROM app_settings WHERE key NOT LIKE 'planner.sync.%'",
        );
        // A importação substitui o estado local: a fila e o cursor antigos
        // deixam de representar os dados e são descartados. Configuração de
        // servidor e deviceId permanecem.
        await _db.delete(_db.syncOutbox).go();
        await _db.delete(_db.syncRowStates).go();
        await _db.customStatement(
          "DELETE FROM sync_states WHERE key IN ('cursor', 'last_sync_at', 'last_error')",
        );

        final notes = [
          for (final entry in _rows(document.data, 'notes'))
            NoteRow(
              id: _string(entry, 'id'),
              title: _string(entry, 'title'),
              type: _noteType(_string(entry, 'type')),
              markdown: _nullableString(entry, 'markdown'),
              createdAt: _timestamp(entry, 'createdAt'),
              updatedAt: _timestamp(entry, 'updatedAt'),
              deletedAt: _nullableTimestamp(entry, 'deletedAt'),
            ),
        ];
        final noteIds = {for (final note in notes) note.id};

        final noteLines = [
          for (final entry in _rows(document.data, 'noteLines'))
            NoteLineRow(
              id: _string(entry, 'id'),
              noteId: _stringIn(entry, 'noteId', noteIds),
              position: _int(entry, 'position'),
              content: _string(entry, 'content'),
              isChecked: _bool(entry, 'isChecked'),
            ),
        ];

        final postIts = [
          for (final entry in _rows(document.data, 'postIts'))
            PostItRow(
              id: _string(entry, 'id'),
              title: _string(entry, 'title'),
              type: _postItType(_string(entry, 'type')),
              status: _postItStatus(_string(entry, 'status')),
              isHighlight: _bool(entry, 'isHighlight'),
              details: _nullableString(entry, 'details'),
              noteId: _nullableStringIn(entry, 'noteId', noteIds),
              noteExcerpt: _nullableString(entry, 'noteExcerpt'),
              sourceNoteId: _nullableString(entry, 'sourceNoteId'),
              startDate: _nullableDate(entry, 'startDate'),
              endDate: _nullableDate(entry, 'endDate'),
              recurrence: _eventRecurrence(
                _nullableString(entry, 'recurrence'),
              ),
              recurrenceInterval: _optionalInt(entry, 'recurrenceInterval', 1),
              sortOrder: _int(entry, 'sortOrder'),
              lastRolloverAt: _nullableTimestamp(entry, 'lastRolloverAt'),
              createdAt: _timestamp(entry, 'createdAt'),
              updatedAt: _timestamp(entry, 'updatedAt'),
              deletedAt: _nullableTimestamp(entry, 'deletedAt'),
            ),
        ];
        final postItIds = {for (final postIt in postIts) postIt.id};

        final history = [
          for (final entry in _rows(document.data, 'history'))
            PostItHistoryRow(
              id: _string(entry, 'id'),
              postItId: _stringIn(entry, 'postItId', postItIds),
              action: _historyAction(_string(entry, 'action')),
              fromValue: _nullableString(entry, 'fromValue'),
              toValue: _nullableString(entry, 'toValue'),
              createdAt: _timestamp(entry, 'createdAt'),
            ),
        ];

        final settings = [
          for (final entry in _rows(document.data, 'settings'))
            if (!_string(entry, 'key').startsWith('planner.sync.'))
              AppSetting(
                key: _string(entry, 'key'),
                value: _string(entry, 'value'),
              ),
        ];

        await _db.batch((batch) {
          batch.insertAll(_db.notes, notes);
          batch.insertAll(_db.noteLines, noteLines);
          batch.insertAll(_db.postIts, postIts);
          batch.insertAll(_db.postItHistoryEntries, history);
          batch.insertAll(_db.appSettings, settings);
        });
      });
    } on BackupException {
      rethrow;
    } on Object catch (error) {
      throw BackupException(BackupErrorCode.ioError, error.toString());
    }

    return BackupImportResult(counts: document.counts, snapshot: snapshot);
  }

  Future<List<BackupSnapshot>> listSnapshots() async {
    final directory = await backupDirectory();
    if (!directory.existsSync()) return const [];
    final entries = <BackupSnapshot>[];
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith(_snapshotPrefix) || !name.endsWith('.s2p.json')) {
        continue;
      }
      final stat = entity.statSync();
      entries.add(
        BackupSnapshot(
          path: entity.path,
          createdAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<BackupImportResult> restoreSnapshot(BackupSnapshot snapshot) async {
    final raw = File(snapshot.path).readAsStringSync();
    return importJson(raw);
  }

  Future<BackupSnapshot> _createSnapshot() async {
    final raw = await exportToJson();
    final directory = await backupDirectory();
    directory.createSync(recursive: true);
    final now = _now().toUtc();
    final stamp =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      '$_snapshotPrefix$stamp.s2p.json',
    );
    file.writeAsStringSync(raw, flush: true);

    // Verifica o arquivo recém-escrito antes de permitir a substituição.
    try {
      final written = BackupDocument.parse(file.readAsStringSync());
      if (written.counts != BackupDocument.parse(raw).counts) {
        throw const BackupException(
          BackupErrorCode.ioError,
          'snapshot não confere com o estado atual',
        );
      }
    } on BackupException {
      _deleteQuietly(file);
      rethrow;
    }

    await _pruneSnapshots(directory, keepPath: file.path);
    return BackupSnapshot(
      path: file.path,
      createdAt: now,
      sizeBytes: file.lengthSync(),
    );
  }

  Future<void> _pruneSnapshots(
    Directory directory, {
    required String keepPath,
  }) async {
    final files = <File>[];
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name.startsWith(_snapshotPrefix) && name.endsWith('.s2p.json')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    while (files.length > _snapshotRetention) {
      final candidate = files.first;
      if (candidate.path == keepPath) return;
      files.removeAt(0);
      _deleteQuietly(candidate);
    }
  }

  static void _deleteQuietly(File file) {
    try {
      file.deleteSync();
    } on FileSystemException {
      // Snapshot antigo já removido ou inacessível.
    }
  }

  Map<String, Object?> _postItToJson(PostItRow row) => {
    'id': row.id,
    'title': row.title,
    'type': row.type.name,
    'status': row.status.name,
    'isHighlight': row.isHighlight,
    'details': row.details,
    'noteId': row.noteId,
    'noteExcerpt': row.noteExcerpt,
    'sourceNoteId': row.sourceNoteId,
    'startDate': row.startDate?.toIso8601String(),
    'endDate': row.endDate?.toIso8601String(),
    'recurrence': row.recurrence.name,
    'recurrenceInterval': row.recurrenceInterval,
    'sortOrder': row.sortOrder,
    'lastRolloverAt': _isoOrNull(row.lastRolloverAt),
    'createdAt': _iso(row.createdAt),
    'updatedAt': _iso(row.updatedAt),
    'deletedAt': _isoOrNull(row.deletedAt),
  };

  Map<String, Object?> _noteToJson(NoteRow row) => {
    'id': row.id,
    'title': row.title,
    'type': row.type.name,
    'markdown': row.markdown,
    'createdAt': _iso(row.createdAt),
    'updatedAt': _iso(row.updatedAt),
    'deletedAt': _isoOrNull(row.deletedAt),
  };

  Map<String, Object?> _noteLineToJson(NoteLineRow row) => {
    'id': row.id,
    'noteId': row.noteId,
    'position': row.position,
    'content': row.content,
    'isChecked': row.isChecked,
  };

  Map<String, Object?> _historyToJson(PostItHistoryRow row) => {
    'id': row.id,
    'postItId': row.postItId,
    'action': row.action.name,
    'fromValue': row.fromValue,
    'toValue': row.toValue,
    'createdAt': _iso(row.createdAt),
  };

  static String _iso(int milliseconds) => DateTime.fromMillisecondsSinceEpoch(
    milliseconds,
    isUtc: true,
  ).toIso8601String();

  static String? _isoOrNull(int? milliseconds) =>
      milliseconds == null ? null : _iso(milliseconds);

  static List<Map<String, Object?>> _rows(
    Map<String, Object?> data,
    String key,
  ) {
    final value = data[key];
    if (value is! List) {
      throw BackupException(BackupErrorCode.invalidData, 'data.$key ausente');
    }
    final rows = <Map<String, Object?>>[];
    for (final entry in value) {
      if (entry is! Map<String, Object?>) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'data.$key contém item inválido',
        );
      }
      rows.add(entry);
    }
    return rows;
  }

  static String _string(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is String && value.isNotEmpty) return value;
    throw BackupException(BackupErrorCode.invalidData, '$key inválido');
  }

  static String? _nullableString(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value == null) return null;
    if (value is String) return value;
    throw BackupException(BackupErrorCode.invalidData, '$key inválido');
  }

  static String _stringIn(
    Map<String, Object?> row,
    String key,
    Set<String> allowed,
  ) {
    final value = _string(row, key);
    if (!allowed.contains(value)) {
      throw BackupException(
        BackupErrorCode.invalidData,
        '$key referencia registro ausente',
      );
    }
    return value;
  }

  static String? _nullableStringIn(
    Map<String, Object?> row,
    String key,
    Set<String> allowed,
  ) {
    final value = _nullableString(row, key);
    if (value == null) return null;
    if (!allowed.contains(value)) {
      throw BackupException(
        BackupErrorCode.invalidData,
        '$key referencia registro ausente',
      );
    }
    return value;
  }

  static int _int(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is int) return value;
    throw BackupException(BackupErrorCode.invalidData, '$key inválido');
  }

  static bool _bool(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is bool) return value;
    throw BackupException(BackupErrorCode.invalidData, '$key inválido');
  }

  static int _timestamp(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is! String) {
      throw BackupException(BackupErrorCode.invalidData, '$key inválido');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw BackupException(BackupErrorCode.invalidData, '$key inválido');
    }
    return parsed.toUtc().millisecondsSinceEpoch;
  }

  static int? _nullableTimestamp(Map<String, Object?> row, String key) =>
      row[key] == null ? null : _timestamp(row, key);

  static DateOnly? _nullableDate(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value == null) return null;
    if (value is! String) {
      throw BackupException(BackupErrorCode.invalidData, '$key inválido');
    }
    try {
      return DateOnly.parse(value);
    } on FormatException {
      throw BackupException(BackupErrorCode.invalidData, '$key inválido');
    }
  }

  static NoteType _noteType(String name) {
    for (final value in NoteType.values) {
      if (value.name == name) return value;
    }
    throw BackupException(BackupErrorCode.invalidData, 'tipo de nota $name');
  }

  static PostItType _postItType(String name) {
    for (final value in PostItType.values) {
      if (value.name == name) return value;
    }
    throw BackupException(BackupErrorCode.invalidData, 'tipo de post-it $name');
  }

  static PostItStatus _postItStatus(String name) {
    for (final value in PostItStatus.values) {
      if (value.name == name) return value;
    }
    throw BackupException(
      BackupErrorCode.invalidData,
      'estado de post-it $name',
    );
  }

  static EventRecurrence _eventRecurrence(String? name) {
    if (name == null) return EventRecurrence.none;
    for (final value in EventRecurrence.values) {
      if (value.name == name) return value;
    }
    return EventRecurrence.none;
  }

  static int _optionalInt(Map<String, Object?> row, String key, int fallback) {
    final value = row[key];
    return value is int ? value : fallback;
  }

  static PostItHistoryAction _historyAction(String name) {
    for (final value in PostItHistoryAction.values) {
      if (value.name == name) return value;
    }
    throw BackupException(
      BackupErrorCode.invalidData,
      'ação de histórico $name',
    );
  }
}
