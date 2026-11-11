import 'package:drift/drift.dart';

import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';
import '../../data/mappers/mappers.dart';
import 'sync_payload.dart';

/// Aplica alterações vindas do servidor sem gerar novas entradas na outbox.
///
/// O cursor e a revisão por entidade são gravados na mesma transação da
/// aplicação; o chamador é responsável por envolver o lote inteiro.
final class SyncApplyService {
  SyncApplyService(this._db);

  final AppDatabase _db;

  Future<void> applyPostIt(Map<String, Object?> payload, int rev) async {
    final postIt = postItFromPayload(payload);
    await _db.transaction(() async {
      await _db
          .into(_db.postIts)
          .insertOnConflictUpdate(postItToCompanion(postIt));
      await _recordRev(syncEntityPostIt, postIt.id, rev);
    });
  }

  Future<void> applyNote(Map<String, Object?> payload, int rev) async {
    final note = noteFromPayload(payload);
    await _db.transaction(() async {
      await _db.into(_db.notes).insertOnConflictUpdate(noteToCompanion(note));

      final keep = {for (final line in note.lines) line.id};
      final existing = await (_db.select(
        _db.noteLines,
      )..where((table) => table.noteId.equals(note.id))).get();
      for (final row in existing) {
        if (keep.contains(row.id)) continue;
        await (_db.delete(
          _db.noteLines,
        )..where((table) => table.id.equals(row.id))).go();
      }
      for (final line in note.lines) {
        await _db
            .into(_db.noteLines)
            .insertOnConflictUpdate(noteLineToCompanion(line));
      }

      await _recordRev(syncEntityNote, note.id, rev);
    });
  }

  Future<void> applyHistory(Map<String, Object?> payload, int rev) async {
    final entry = historyFromPayload(payload);
    await _db.transaction(() async {
      await _db
          .into(_db.postItHistoryEntries)
          .insertOnConflictUpdate(postItHistoryToCompanion(entry));
      await _recordRev(syncEntityHistory, entry.id, rev);
    });
  }

  Future<void> applyTag(Map<String, Object?> payload, int rev) async {
    final tag = tagFromPayload(payload);
    await _db.transaction(() async {
      await _db.into(_db.tags).insertOnConflictUpdate(tagToCompanion(tag));
      if (tag.isDeleted) {
        final rows = await _db.select(_db.postIts).get();
        for (final row in rows) {
          if (!row.tagIds.contains(tag.id)) continue;
          await (_db.update(
            _db.postIts,
          )..where((table) => table.id.equals(row.id))).write(
            PostItsCompanion(
              tagIds: Value([
                for (final id in row.tagIds)
                  if (id != tag.id) id,
              ]),
            ),
          );
        }
      }
      await _recordRev(syncEntityTag, tag.id, rev);
    });
  }

  Future<void> applyRoutine(Map<String, Object?> payload, int rev) async {
    final routineId = payload['id'];
    if (routineId is! String || routineId.isEmpty) {
      throw const FormatException('routine.id inválido');
    }
    if (payload['deletedAt'] != null) {
      await _db.transaction(() async {
        final items = await (_db.select(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routineId))).get();
        for (final item in items) {
          await (_db.delete(
            _db.routineCompletions,
          )..where((table) => table.routineItemId.equals(item.id))).go();
        }
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routineId))).go();
        await (_db.delete(
          _db.routines,
        )..where((table) => table.id.equals(routineId))).go();
        await _recordRev(syncEntityRoutine, routineId, rev);
      });
      return;
    }

    final routine = routineFromPayload(payload);
    await _db.transaction(() async {
      await _db
          .into(_db.routines)
          .insertOnConflictUpdate(
            RoutinesCompanion(
              id: Value(routine.id),
              name: Value(routine.name),
              details: Value(routine.details),
              weekdays: Value(routineWeekdayMask(routine.weekdays)),
              createdAt: Value(dateTimeToStorage(routine.createdAt)),
              updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
            ),
          );

      final existing = await (_db.select(
        _db.routineItems,
      )..where((table) => table.routineId.equals(routine.id))).get();
      final keepIds = {for (final item in routine.items) item.id};
      for (final row in existing) {
        if (keepIds.contains(row.id)) continue;
        await (_db.delete(
          _db.routineCompletions,
        )..where((table) => table.routineItemId.equals(row.id))).go();
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.id.equals(row.id))).go();
      }

      for (final item in routine.items) {
        await _db
            .into(_db.routineItems)
            .insertOnConflictUpdate(
              RoutineItemsCompanion(
                id: Value(item.id),
                routineId: Value(routine.id),
                title: Value(item.title),
                details: Value(item.details),
                position: Value(item.position),
                createdAt: Value(dateTimeToStorage(routine.createdAt)),
                updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
              ),
            );
        await (_db.delete(
          _db.routineCompletions,
        )..where((table) => table.routineItemId.equals(item.id))).go();
        for (final date in item.completedDates) {
          await _db
              .into(_db.routineCompletions)
              .insertOnConflictUpdate(
                RoutineCompletionsCompanion(
                  routineItemId: Value(item.id),
                  date: Value(date),
                  completedAt: Value(dateTimeToStorage(routine.updatedAt)),
                ),
              );
        }
      }
      await _recordRev(syncEntityRoutine, routine.id, rev);
    });
  }

  Future<void> _recordRev(String entity, String entityId, int rev) {
    return _db
        .into(_db.syncRowStates)
        .insertOnConflictUpdate(
          SyncRowStatesCompanion.insert(
            entity: entity,
            entityId: entityId,
            serverRev: rev,
            lastSyncedAt: dateTimeToStorage(DateTime.now().toUtc()),
          ),
        );
  }
}
