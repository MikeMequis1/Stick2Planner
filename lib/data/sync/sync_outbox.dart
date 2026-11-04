import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/canonical_json.dart';
import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import 'sync_payload.dart';

/// Grava a outbox na mesma transação das alterações locais.
///
/// Cada alteração coalesce por `(entity, entityId)`; o payload é o estado
/// completo, então o servidor sempre recebe a versão mais recente.
final class SyncOutboxRecorder {
  SyncOutboxRecorder(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<void> recordPostIt(PostIt postIt) => _record(
    syncEntityPostIt,
    postIt.id,
    postItPayload(postIt),
    postIt.updatedAt,
  );

  Future<void> recordPostIts(Iterable<PostIt> postIts) async {
    for (final postIt in postIts) {
      await recordPostIt(postIt);
    }
  }

  Future<void> recordNote(Note note) =>
      _record(syncEntityNote, note.id, notePayload(note), note.updatedAt);

  Future<void> recordHistory(PostItHistoryEntry entry) => _record(
    syncEntityHistory,
    entry.id,
    historyPayload(entry),
    entry.createdAt,
  );

  Future<void> recordHistoryEntries(
    Iterable<PostItHistoryEntry> entries,
  ) async {
    for (final entry in entries) {
      await recordHistory(entry);
    }
  }

  Future<void> _record(
    String entity,
    String entityId,
    Map<String, Object?> payload,
    DateTime at,
  ) async {
    final existing =
        await (_db.select(_db.syncOutbox)..where(
              (table) =>
                  table.entity.equals(entity) & table.entityId.equals(entityId),
            ))
            .getSingleOrNull();

    await _db
        .into(_db.syncOutbox)
        .insertOnConflictUpdate(
          SyncOutboxCompanion.insert(
            entity: entity,
            entityId: entityId,
            payload: canonicalJsonEncode(payload),
            changeId: _uuid.v4(),
            updatedAt: dateTimeToStorage(at),
            baseRev: Value(existing?.baseRev ?? 0),
            attempts: const Value(0),
            lastError: const Value(null),
          ),
        );
  }
}
