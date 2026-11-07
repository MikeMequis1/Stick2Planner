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
