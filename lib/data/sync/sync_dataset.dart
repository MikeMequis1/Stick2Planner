import 'package:drift/drift.dart';

import '../../core/date_only.dart';
import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';
import '../../data/mappers/mappers.dart';
import '../../domain/entities/post_it.dart';
import 'sync_models.dart';
import 'sync_payload.dart';

/// Lê contagens e o conjunto completo de dados de usuário do banco local.
final class SyncDatasetService {
  SyncDatasetService(this._db);

  final AppDatabase _db;

  Future<SyncCounts> counts() async {
    final postItRows = await (_db.select(
      _db.postIts,
    )..where((table) => table.deletedAt.isNull())).get();
    final noteCount = (await (_db.select(
      _db.notes,
    )..where((table) => table.deletedAt.isNull())).get()).length;
    var events = 0;
    var tasks = 0;
    for (final row in postItRows) {
      final postIt = postItFromRow(row);
      if (postIt.type == PostItType.event) {
        events++;
      } else {
        tasks++;
      }
    }
    final historyCount =
        (await _db.select(_db.postItHistoryEntries).get()).length;
    final tagCount = (await (_db.select(
      _db.tags,
    )..where((table) => table.deletedAt.isNull())).get()).length;
    final routineCount = (await _db.select(_db.routines).get()).length;
    return SyncCounts(
      postIts: postItRows.length,
      notes: noteCount,
      events: events,
      tasks: tasks,
      history: historyCount,
      tags: tagCount,
      routines: routineCount,
    );
  }

  /// Inclui tombstones para que “manter local” também remova itens remotos.
  Future<List<SyncSnapshotEntity>> snapshot() async {
    final postItRows = await _db.select(_db.postIts).get();
    final noteRows = await _db.select(_db.notes).get();
    final lineRows = await (_db.select(
      _db.noteLines,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final historyRows = await _db.select(_db.postItHistoryEntries).get();
    final tagRows = await _db.select(_db.tags).get();
    final routineRows = await _db.select(_db.routines).get();
    final routineItemRows = await (_db.select(
      _db.routineItems,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final routineCompletionRows = await _db
        .select(_db.routineCompletions)
        .get();

    final linesByNote = <String, List<NoteLineRow>>{};
    for (final row in lineRows) {
      linesByNote.putIfAbsent(row.noteId, () => []).add(row);
    }
    final itemsByRoutine = <String, List<RoutineItemRow>>{};
    for (final row in routineItemRows) {
      itemsByRoutine.putIfAbsent(row.routineId, () => []).add(row);
    }
    final completionsByItem = <String, Set<DateOnly>>{};
    for (final row in routineCompletionRows) {
      completionsByItem.putIfAbsent(row.routineItemId, () => {}).add(row.date);
    }

    return [
      for (final row in noteRows)
        _entity(
          syncEntityNote,
          row.id,
          notePayload(noteFromRows(row, linesByNote[row.id] ?? const [])),
          dateTimeFromStorage(row.updatedAt),
          row.deletedAt != null,
        ),
      for (final row in postItRows)
        _entity(
          syncEntityPostIt,
          row.id,
          postItPayload(postItFromRow(row)),
          dateTimeFromStorage(row.updatedAt),
          row.deletedAt != null,
        ),
      for (final row in historyRows)
        _entity(
          syncEntityHistory,
          row.id,
          historyPayload(postItHistoryFromRow(row)),
          dateTimeFromStorage(row.createdAt),
          false,
        ),
      for (final row in tagRows)
        _entity(
          syncEntityTag,
          row.id,
          tagPayload(tagFromRow(row)),
          dateTimeFromStorage(row.updatedAt),
          row.deletedAt != null,
        ),
      for (final row in routineRows)
        _entity(
          syncEntityRoutine,
          row.id,
          routinePayload(
            routineFromRows(
              row,
              itemsByRoutine[row.id] ?? const [],
              completionsByItem,
            ),
          ),
          dateTimeFromStorage(row.updatedAt),
          false,
        ),
    ];
  }

  SyncSnapshotEntity _entity(
    String entity,
    String entityId,
    Map<String, Object?> payload,
    DateTime updatedAt,
    bool deleted,
  ) => SyncSnapshotEntity(
    entity: entity,
    entityId: entityId,
    rev: 0,
    updatedAt: updatedAt,
    deleted: deleted,
    payload: payload,
  );
}
