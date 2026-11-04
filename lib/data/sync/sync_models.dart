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
  return SyncConflict(
    entity: _string(map['entity'], 'conflict.entity'),
    entityId: _string(map['entityId'], 'conflict.entityId'),
    server: _remote(map['server']),
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
