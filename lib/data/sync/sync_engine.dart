// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/canonical_json.dart';
import '../db/app_database.dart';
import '../db/converters.dart';
import '../sync/sync_apply.dart';
import '../sync/sync_dataset.dart';
import '../sync/sync_models.dart';
import '../sync/sync_outbox.dart';
import '../sync/sync_payload.dart';
import '../sync/sync_state_store.dart';
import '../sync/sync_transport.dart';

/// Executa push/pull, resolve conflitos e mantém cursor/outbox consistentes.
final class SyncEngine {
  SyncEngine({
    required AppDatabase database,
    required SyncTransport transport,
    required SyncStateStore state,
    SyncApplyService? apply,
    SyncOutboxRecorder? outbox,
    Uuid? uuid,
    DateTime Function()? now,
    this.batchSize = 200,
    this.supportsRoutines = true,
  }) : _db = database,
       _transport = transport,
       _state = state,
       _apply = apply ?? SyncApplyService(database),
       _outbox = outbox ?? SyncOutboxRecorder(database),
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SyncTransport _transport;
  final SyncStateStore _state;
  final SyncApplyService _apply;
  final SyncOutboxRecorder _outbox;
  final Uuid _uuid;
  final DateTime Function() _now;
  final int batchSize;

  /// Servidores anteriores à 0.2.2 recusam a entidade `routine`. Nesse caso as
  /// rotinas ficam na outbox local e o restante do sync continua funcionando.
  final bool supportsRoutines;

  /// Uma rodada completa: push, pull, conflitos e, se preciso, um reenvio.
  Future<SyncReport> run() async {
    final deviceId = await _state.ensureDeviceId();
    try {
      await _outbox.queueUnsyncedRoutines();
      final first = await _runRound(deviceId, allowRetry: true);
      var pushed = first.pushed;
      var pulled = first.pulled;
      var conflicts = first.conflicts;
      var copies = first.copies;
      var cursor = first.cursor;

      if (first.retryNeeded) {
        final second = await _runRound(deviceId, allowRetry: false);
        pushed += second.pushed;
        pulled += second.pulled;
        conflicts += second.conflicts;
        copies += second.copies;
        cursor = second.cursor;
      }

      final finishedAt = _now().toUtc();
      await _state.setLastSyncAt(finishedAt);
      await _state.setLastError(null);
      return SyncReport(
        pushed: pushed,
        pulled: pulled,
        conflicts: conflicts,
        copies: copies,
        cursor: cursor,
        finishedAt: finishedAt,
      );
    } on Object catch (error) {
      await _state.setLastError(error.toString());
      rethrow;
    }
  }

  /// Envia o conjunto local completo e remove do servidor o que não existe
  /// aqui. Usado quando o usuário escolhe “manter local”.
  Future<SyncReport> replaceWithLocal() async {
    final deviceId = await _state.ensureDeviceId();
    final dataset = await SyncDatasetService(_db).snapshot();
    final entities = supportsRoutines
        ? dataset
        : [
            for (final entity in dataset)
              if (entity.entity != syncEntityRoutine) entity,
          ];
    try {
      final result = await _transport.replace(
        deviceId: deviceId,
        entities: entities,
      );
      final finishedAt = _now().toUtc();
      await _db.transaction(() async {
        await _db.delete(_db.syncOutbox).go();
        await _db.delete(_db.syncRowStates).go();
        for (final entry in result.revs.entries) {
          final parts = entry.key.split('\u0000');
          if (parts.length != 2) continue;
          await _db
              .into(_db.syncRowStates)
              .insertOnConflictUpdate(
                SyncRowStatesCompanion.insert(
                  entity: parts[0],
                  entityId: parts[1],
                  serverRev: entry.value,
                  lastSyncedAt: dateTimeToStorage(finishedAt),
                ),
              );
        }
        await _state.setCursor(result.cursor);
      });
      await _state.setLastSyncAt(finishedAt);
      await _state.setLastError(null);
      return SyncReport(
        pushed: entities.length,
        pulled: 0,
        conflicts: 0,
        copies: 0,
        cursor: result.cursor,
        finishedAt: finishedAt,
      );
    } on Object catch (error) {
      await _state.setLastError(error.toString());
      rethrow;
    }
  }

  /// Substitui o conteúdo local pelo snapshot remoto. Usado quando o usuário
  /// escolhe “manter remoto”.
  Future<SyncReport> replaceWithRemote() async {
    final snapshot = await _transport.snapshot();
    try {
      await _db.transaction(() async {
        await _db.delete(_db.syncOutbox).go();
        await _db.delete(_db.syncRowStates).go();
        await _db.delete(_db.postItHistoryEntries).go();
        await _db.delete(_db.postIts).go();
        await _db.delete(_db.noteLines).go();
        await _db.delete(_db.notes).go();
        await _db.delete(_db.tags).go();
        if (supportsRoutines) {
          await _db.delete(_db.routineCompletions).go();
          await _db.delete(_db.routineItems).go();
          await _db.delete(_db.routines).go();
        }
        await _state.setCursor(0);

        for (final change in _sortedSnapshotEntities(snapshot.entities)) {
          switch (change.entity) {
            case syncEntityNote:
              await _apply.applyNote(change.payload, change.rev);
              break;
            case syncEntityPostIt:
              await _apply.applyPostIt(change.payload, change.rev);
              break;
            case syncEntityHistory:
              await _apply.applyHistory(change.payload, change.rev);
              break;
            case syncEntityTag:
              await _apply.applyTag(change.payload, change.rev);
              break;
            case syncEntityRoutine:
              if (supportsRoutines) {
                await _apply.applyRoutine(change.payload, change.rev);
              }
              break;
          }
        }
        await _state.setCursor(snapshot.cursor);
      });
      final finishedAt = _now().toUtc();
      await _state.setLastSyncAt(finishedAt);
      await _state.setLastError(null);
      return SyncReport(
        pushed: 0,
        pulled: snapshot.entities.length,
        conflicts: 0,
        copies: 0,
        cursor: snapshot.cursor,
        finishedAt: finishedAt,
      );
    } on Object catch (error) {
      await _state.setLastError(error.toString());
      rethrow;
    }
  }

  Future<_RoundResult> _runRound(
    String deviceId, {
    required bool allowRetry,
  }) async {
    final since = await _state.cursor();
    final pendingQuery = _db.select(_db.syncOutbox)
      ..orderBy([(table) => OrderingTerm(expression: table.updatedAt)]);
    if (!supportsRoutines) {
      pendingQuery.where((table) => table.entity.isNotIn([syncEntityRoutine]));
    }
    final rows = await (pendingQuery..limit(batchSize)).get();
    final changes = [for (final row in rows) _toChange(row)];
    final pushedByEntity = {
      for (final row in rows) '${row.entity}\u0000${row.entityId}': row,
    };

    final response = await _transport.sync(
      deviceId: deviceId,
      since: since,
      changes: changes,
      limit: batchSize,
    );

    var retryNeeded = false;
    var copies = 0;

    await _db.transaction(() async {
      for (final change in _sortedByEntity(response.changes)) {
        await _applyChange(change);
      }

      for (final conflict in response.conflicts) {
        final row =
            pushedByEntity['${conflict.entity}\u0000${conflict.entityId}'];
        if (row == null) continue;

        final current =
            await (_db.select(_db.syncOutbox)..where(
                  (table) =>
                      table.entity.equals(row.entity) &
                      table.entityId.equals(row.entityId),
                ))
                .getSingleOrNull();
        if (current == null || current.changeId != row.changeId) {
          // Houve edição local depois do push: preserva a versão nova e apenas
          // alinha a revisão para a próxima tentativa.
          if (current != null) {
            await _setBaseRev(current, conflict.server.rev);
          }
          continue;
        }

        final resolution = _resolve(row, conflict, deviceId);
        switch (resolution) {
          case _Resolution.identical:
            await _deleteRow(row);
            await _applyChange(conflict.server);
          case _Resolution.keepLocal:
            if (allowRetry) {
              await _setBaseRev(row, conflict.server.rev);
              retryNeeded = true;
            } else {
              copies += await _copyLocal(row);
              await _deleteRow(row);
              await _applyChange(conflict.server);
            }
          case _Resolution.serverWins:
            if (_needsCopy(row, conflict.server)) {
              copies += await _copyLocal(row);
            }
            await _deleteRow(row);
            await _applyChange(conflict.server);
        }
      }

      for (final ack in response.acks) {
        final row =
            await (_db.select(_db.syncOutbox)
                  ..where((table) => table.changeId.equals(ack.changeId)))
                .getSingleOrNull();
        if (row != null) {
          if (row.changeId == ack.changeId) {
            await _deleteRow(row);
          } else {
            await _setBaseRev(row, ack.rev);
          }
        }
        await _db
            .into(_db.syncRowStates)
            .insertOnConflictUpdate(
              SyncRowStatesCompanion.insert(
                entity: ack.entity,
                entityId: ack.entityId,
                serverRev: ack.rev,
                lastSyncedAt: dateTimeToStorage(_now().toUtc()),
              ),
            );
      }

      // Cursor e aplicação das mudanças na mesma transação local.
      await _state.setCursor(response.cursor);
    });

    return _RoundResult(
      pushed: response.acks.length,
      pulled: response.changes.length,
      conflicts: response.conflicts.length,
      copies: copies,
      cursor: response.cursor,
      retryNeeded: retryNeeded,
    );
  }

  SyncChange _toChange(SyncOutboxRow row) {
    final payload = _decode(row.payload);
    return SyncChange(
      changeId: row.changeId,
      entity: row.entity,
      entityId: row.entityId,
      baseRev: row.baseRev,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row.updatedAt,
        isUtc: true,
      ),
      deleted: _isDeleted(row.entity, payload),
      payload: payload,
    );
  }

  _Resolution _resolve(
    SyncOutboxRow row,
    SyncConflict conflict,
    String deviceId,
  ) {
    final localPayload = _decode(row.payload);
    final localCanonical = canonicalJsonEncode(localPayload);
    final serverCanonical = canonicalJsonEncode(conflict.server.payload);
    if (localCanonical == serverCanonical) return _Resolution.identical;

    final localTime = DateTime.fromMillisecondsSinceEpoch(
      row.updatedAt,
      isUtc: true,
    );
    final serverTime = conflict.server.updatedAt;
    if (localTime.isAfter(serverTime)) return _Resolution.keepLocal;
    // Empate: servidor vence, evitando depender de relógio/ordem de dispositivo.
    return _Resolution.serverWins;
  }

  bool _needsCopy(SyncOutboxRow row, SyncRemoteChange server) {
    final local = _decode(row.payload);
    if (_isDeleted(row.entity, local)) return false;
    return row.entity != syncEntityHistory;
  }

  Future<int> _copyLocal(SyncOutboxRow row) async {
    final payload = _decode(row.payload);
    switch (row.entity) {
      case syncEntityPostIt:
        final copy = await _conflictCopyPostIt(payload);
        await _apply.applyPostIt(copy, 0);
        await _outbox.recordPostIt(postItFromPayload(copy));
        return 1;
      case syncEntityNote:
        final copy = _conflictCopyNote(payload);
        await _apply.applyNote(copy, 0);
        await _outbox.recordNote(noteFromPayload(copy));
        return 1;
      case syncEntityRoutine:
        final copy = _conflictCopyRoutine(payload);
        await _apply.applyRoutine(copy, 0);
        await _outbox.recordRoutine(routineFromPayload(copy));
        return 1;
      default:
        return 0;
    }
  }

  Future<Map<String, Object?>> _conflictCopyPostIt(
    Map<String, Object?> payload,
  ) async {
    final copy = Map<String, Object?>.from(payload);
    copy['id'] = _uuid.v4();
    copy['title'] = _copyTitle(payload['title'] as String?);
    final noteId = payload['noteId'];
    if (noteId is String && !await _hasNote(noteId)) {
      copy['noteId'] = null;
    }
    return copy;
  }

  Map<String, Object?> _conflictCopyNote(Map<String, Object?> payload) {
    final copy = Map<String, Object?>.from(payload);
    final noteId = _uuid.v4();
    copy['id'] = noteId;
    copy['title'] = _copyTitle(payload['title'] as String?);
    final lines = payload['lines'];
    if (lines is List) {
      copy['lines'] = [
        for (final line in lines)
          if (line is Map)
            {
              ...Map<String, Object?>.from(line),
              'id': _uuid.v4(),
              'noteId': noteId,
            },
      ];
    }
    return copy;
  }

  Map<String, Object?> _conflictCopyRoutine(Map<String, Object?> payload) {
    final copy = Map<String, Object?>.from(payload);
    copy['id'] = _uuid.v4();
    copy['name'] = _copyTitle(payload['name'] as String?);
    final items = payload['items'];
    if (items is List) {
      copy['items'] = [
        for (final item in items)
          if (item is Map)
            {...Map<String, Object?>.from(item), 'id': _uuid.v4()},
      ];
    }
    return copy;
  }

  Future<bool> _hasNote(String id) async {
    final row = await (_db.select(
      _db.notes,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row != null;
  }

  String _copyTitle(String? title) {
    final base = (title == null || title.trim().isEmpty)
        ? 'Post-it'
        : title.trim();
    return '[Conflito] $base';
  }

  Future<void> _setBaseRev(SyncOutboxRow row, int rev) async {
    await (_db.update(_db.syncOutbox)..where(
          (table) =>
              table.entity.equals(row.entity) &
              table.entityId.equals(row.entityId),
        ))
        .write(SyncOutboxCompanion(baseRev: Value(rev)));
  }

  Future<void> _deleteRow(SyncOutboxRow row) async {
    await (_db.delete(_db.syncOutbox)..where(
          (table) =>
              table.entity.equals(row.entity) &
              table.entityId.equals(row.entityId) &
              table.changeId.equals(row.changeId),
        ))
        .go();
  }

  Future<void> _applyChange(SyncRemoteChange change) async {
    switch (change.entity) {
      case syncEntityNote:
        await _apply.applyNote(change.payload, change.rev);
      case syncEntityPostIt:
        await _apply.applyPostIt(change.payload, change.rev);
      case syncEntityHistory:
        await _apply.applyHistory(change.payload, change.rev);
      case syncEntityTag:
        await _apply.applyTag(change.payload, change.rev);
      case syncEntityRoutine:
        await _apply.applyRoutine(change.payload, change.rev);
      default:
        throw SyncException('entidade desconhecida ${change.entity}');
    }
  }

  static List<SyncRemoteChange> _sortedByEntity(
    List<SyncRemoteChange> changes,
  ) {
    int priority(String entity) => switch (entity) {
      syncEntityTag => 0,
      syncEntityNote => 1,
      syncEntityPostIt => 2,
      _ => 3,
    };
    return [...changes]
      ..sort((a, b) => priority(a.entity).compareTo(priority(b.entity)));
  }

  static List<SyncSnapshotEntity> _sortedSnapshotEntities(
    List<SyncSnapshotEntity> entities,
  ) {
    int priority(String entity) => switch (entity) {
      syncEntityTag => 0,
      syncEntityNote => 1,
      syncEntityPostIt => 2,
      _ => 3,
    };
    return [...entities]
      ..sort((a, b) => priority(a.entity).compareTo(priority(b.entity)));
  }

  static Map<String, Object?> _decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, Object?>.from(decoded);
    throw const SyncException('payload local inválido');
  }

  static bool _isDeleted(String entity, Map<String, Object?> payload) {
    if (entity == syncEntityHistory) return false;
    return payload['deletedAt'] != null;
  }
}

enum _Resolution { identical, keepLocal, serverWins }

final class _RoundResult {
  const _RoundResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.copies,
    required this.cursor,
    required this.retryNeeded,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final int copies;
  final int cursor;
  final bool retryNeeded;
}
