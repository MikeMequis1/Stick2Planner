import 'dart:convert';

import '../../core/canonical_json.dart';

/// Mudança local a enviar ao servidor.
final class SyncChange {
  const SyncChange({
    required this.changeId,
    required this.entity,
    required this.entityId,
    required this.baseRev,
    required this.updatedAt,
    required this.deleted,
    required this.payload,
  });

  final String changeId;
  final String entity;
  final String entityId;
  final int baseRev;
  final DateTime updatedAt;
  final bool deleted;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
    'changeId': changeId,
    'entity': entity,
    'entityId': entityId,
    'baseRev': baseRev,
    'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
    'deleted': deleted,
    'payload': canonicalJsonEncode(payload),
  };
}

final class SyncAck {
  const SyncAck({
    required this.changeId,
    required this.entity,
    required this.entityId,
    required this.rev,
  });

  final String changeId;
  final String entity;
  final String entityId;
  final int rev;
}

final class SyncRemoteChange {
  const SyncRemoteChange({
    required this.entity,
    required this.entityId,
    required this.rev,
    required this.deleted,
    required this.updatedAt,
    required this.payload,
  });

  final String entity;
  final String entityId;
  final int rev;
  final bool deleted;
  final DateTime updatedAt;
  final Map<String, Object?> payload;
}

final class SyncConflict {
  const SyncConflict({
    required this.entity,
    required this.entityId,
    required this.server,
  });

  final String entity;
  final String entityId;
  final SyncRemoteChange server;
}

final class SyncResponse {
  const SyncResponse({
    required this.acks,
    required this.conflicts,
    required this.changes,
    required this.cursor,
    required this.more,
  });

  final List<SyncAck> acks;
  final List<SyncConflict> conflicts;
  final List<SyncRemoteChange> changes;
  final int cursor;
  final bool more;

  factory SyncResponse.fromJson(Map<String, Object?> json) {
    return SyncResponse(
      acks: [for (final raw in _list(json['acks'], 'acks')) _ack(raw)],
      conflicts: [
        for (final raw in _list(json['conflicts'], 'conflicts')) _conflict(raw),
      ],
      changes: [
        for (final raw in _list(json['changes'], 'changes')) _remote(raw),
      ],
      cursor: _int(json['cursor'], 'cursor'),
      more: json['more'] == true,
    );
  }
}

/// Estratégia escolhida antes de uma sincronização.
enum SyncMode { merge, keepLocal, keepRemote }

/// Contagem de dados de usuário de um lado da sincronização.
final class SyncCounts {
  const SyncCounts({
    this.postIts = 0,
    this.notes = 0,
    this.events = 0,
    this.tasks = 0,
    this.history = 0,
    this.tags = 0,
    this.deviceLabel = '',
  });

  final int postIts;
  final int notes;
  final int events;
  final int tasks;
  final int history;
  final int tags;

  /// Nome do dispositivo pareado, devolvido pelo servidor em `/stats`.
  final String deviceLabel;

  bool get isEmpty => postIts == 0 && notes == 0 && tags == 0;

  /// Compara apenas os dados visíveis; histórico é auditoria e não decide.
  bool hasSameUserData(SyncCounts other) =>
      postIts == other.postIts &&
      notes == other.notes &&
      events == other.events &&
      tasks == other.tasks &&
      tags == other.tags;

  Map<String, Object?> toJson() => {
    'postIts': postIts,
    'notes': notes,
    'events': events,
    'tasks': tasks,
    'history': history,
    'tags': tags,
    'deviceLabel': deviceLabel,
  };

  factory SyncCounts.fromJson(Map<String, Object?> json) => SyncCounts(
    postIts: _asInt(json['postIts']),
    notes: _asInt(json['notes']),
    events: _asInt(json['events']),
    tasks: _asInt(json['tasks']),
    history: _asInt(json['history']),
    tags: _asInt(json['tags']),
    deviceLabel: json['deviceLabel'] is String
        ? json['deviceLabel'] as String
        : '',
  );
}

/// Comparação local/remota feita antes de sincronizar.
final class SyncPreflight {
  const SyncPreflight({
    required this.local,
    required this.remote,
    required this.hasLocalChanges,
    required this.hasSyncedBefore,
  });

  final SyncCounts local;
  final SyncCounts remote;
  final bool hasLocalChanges;
  final bool hasSyncedBefore;

  /// Pede escolha quando ambos têm dados e a diferença não é explicada por
  /// alterações locais após um sync anterior. No primeiro sync, qualquer
  /// diferença pede confirmação.
  bool get requiresChoice {
    if (local.isEmpty || remote.isEmpty) return false;
    if (local.hasSameUserData(remote)) return false;
    return !hasSyncedBefore || !hasLocalChanges;
  }
}

/// Entidade de um snapshot remoto/local usado para substituição de conjunto.
final class SyncSnapshotEntity {
  const SyncSnapshotEntity({
    required this.entity,
    required this.entityId,
    required this.rev,
    required this.updatedAt,
    required this.deleted,
    required this.payload,
  });

  final String entity;
  final String entityId;
  final int rev;
  final DateTime updatedAt;
  final bool deleted;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
    'entity': entity,
    'entityId': entityId,
    'rev': rev,
    'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
    'deleted': deleted,
    'payload': payload,
  };

  factory SyncSnapshotEntity.fromJson(Map<String, Object?> json) {
    final payload = json['payload'];
    return SyncSnapshotEntity(
      entity: _string(json['entity'], 'snapshot.entity'),
      entityId: _string(json['entityId'], 'snapshot.entityId'),
      rev: _int(json['rev'], 'snapshot.rev'),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _int(json['updatedAt'], 'snapshot.updatedAt'),
        isUtc: true,
      ),
      deleted: json['deleted'] == true,
      payload: payload is Map
          ? Map<String, Object?>.from(payload)
          : <String, Object?>{},
    );
  }
}

/// Snapshot remoto com cursor da mudança mais recente.
final class RemoteSyncSnapshot {
  const RemoteSyncSnapshot({required this.entities, required this.cursor});

  final List<SyncSnapshotEntity> entities;
  final int cursor;

  factory RemoteSyncSnapshot.fromJson(Map<String, Object?> json) {
    final raw = json['entities'];
    return RemoteSyncSnapshot(
      entities: [
        if (raw is List)
          for (final item in raw)
            if (item is Map)
              SyncSnapshotEntity.fromJson(Map<String, Object?>.from(item)),
      ],
      cursor: _int(json['cursor'], 'snapshot.cursor'),
    );
  }
}

/// Resultado de uma substituição de conjunto no servidor.
final class SyncReplaceResult {
  const SyncReplaceResult({required this.revs, required this.cursor});

  final Map<String, int> revs;
  final int cursor;

  factory SyncReplaceResult.fromJson(Map<String, Object?> json) {
    final raw = json['entities'];
    final revs = <String, int>{};
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, Object?>.from(item);
        revs['${map['entity']}\u0000${map['entityId']}'] = _asInt(map['rev']);
      }
    }
    return SyncReplaceResult(
      revs: revs,
      cursor: _int(json['cursor'], 'replace.cursor'),
    );
  }
}

/// Resumo de uma rodada de sincronização.
final class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.copies,
    required this.cursor,
    required this.finishedAt,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final int copies;
  final int cursor;
  final DateTime finishedAt;

  bool get hasConflicts => conflicts > 0;
}

/// Falha de transporte/servidor, com indicação de retentativa.
final class SyncException implements Exception {
  const SyncException(this.message, {this.statusCode, this.retryable = false});

  final String message;
  final int? statusCode;
  final bool retryable;

  @override
  String toString() => 'SyncException($message, status=$statusCode)';
}

SyncAck _ack(Object? raw) {
  final map = _map(raw, 'ack');
  return SyncAck(
    changeId: _string(map['changeId'], 'ack.changeId'),
    entity: _string(map['entity'], 'ack.entity'),
    entityId: _string(map['entityId'], 'ack.entityId'),
    rev: _int(map['rev'], 'ack.rev'),
  );
}

SyncConflict _conflict(Object? raw) {
  final map = _map(raw, 'conflict');
  final entity = _string(map['entity'], 'conflict.entity');
  final entityId = _string(map['entityId'], 'conflict.entityId');
  final server = _map(map['server'], 'conflict.server');
  final payload = server['payload'];
  final decoded = payload is String ? jsonDecode(payload) : payload;
  if (decoded is! Map) {
    throw const SyncException('payload inválido');
  }
  return SyncConflict(
    entity: entity,
    entityId: entityId,
    server: SyncRemoteChange(
      entity: entity,
      entityId: entityId,
      rev: _int(server['rev'], 'conflict.server.rev'),
      deleted: server['deleted'] == true,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _int(server['updatedAt'], 'conflict.server.updatedAt'),
        isUtc: true,
      ),
      payload: Map<String, Object?>.from(decoded),
    ),
  );
}

SyncRemoteChange _remote(Object? raw) {
  final map = _map(raw, 'change');
  final payload = map['payload'];
  final decoded = payload is String ? jsonDecode(payload) : payload;
  if (decoded is! Map) {
    throw const SyncException('payload inválido');
  }
  return SyncRemoteChange(
    entity: _string(map['entity'], 'change.entity'),
    entityId: _string(map['entityId'], 'change.entityId'),
    rev: _int(map['rev'], 'change.rev'),
    deleted: map['deleted'] == true,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      _int(map['updatedAt'], 'change.updatedAt'),
      isUtc: true,
    ),
    payload: Map<String, Object?>.from(decoded),
  );
}

Map<String, Object?> _map(Object? value, String field) {
  if (value is Map) return Map<String, Object?>.from(value);
  throw SyncException('$field inválido');
}

List<Object?> _list(Object? value, String field) {
  if (value is List) return value;
  throw SyncException('$field inválido');
}

String _string(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  throw SyncException('$field inválido');
}

int _int(Object? value, String field) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw SyncException('$field inválido');
}

int _asInt(Object? value) => value is int
    ? value
    : value is num
    ? value.toInt()
    : 0;
