import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/sync/sync_engine.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

/// Servidor mínimo em memória, com a mesma semântica de rev/conflito.
final class MemorySyncServer {
  final Map<String, int> _revs = {};
  final Map<String, Map<String, Object?>> _payloads = {};
  final Map<String, bool> _deleted = {};
  final Map<String, int> _updated = {};
  final Map<String, int> _applied = {};
  final List<({int seq, String key})> _log = [];
  int _seq = 0;

  String _key(String entity, String id) => '$entity/$id';

  SyncResponse handle({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    required int limit,
  }) {
    final acks = <SyncAck>[];
    final conflicts = <SyncConflict>[];

    for (final change in changes) {
      final key = _key(change.entity, change.entityId);
      final appliedRev = _applied[change.changeId];
      if (appliedRev != null) {
        acks.add(
          SyncAck(
            changeId: change.changeId,
            entity: change.entity,
            entityId: change.entityId,
            rev: appliedRev,
          ),
        );
        continue;
      }

      final currentRev = _revs[key] ?? 0;
      if (currentRev != 0 && change.baseRev != currentRev) {
        conflicts.add(
          SyncConflict(
            entity: change.entity,
            entityId: change.entityId,
            server: SyncRemoteChange(
              entity: change.entity,
              entityId: change.entityId,
              rev: currentRev,
              deleted: _deleted[key] ?? false,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                _updated[key] ?? 0,
                isUtc: true,
              ),
              payload: _payloads[key]!,
            ),
          ),
        );
        continue;
      }

      final nextRev = currentRev + 1;
      _revs[key] = nextRev;
      _payloads[key] = change.payload;
      _deleted[key] = change.deleted;
      _updated[key] = change.updatedAt.millisecondsSinceEpoch;
      _applied[change.changeId] = nextRev;
      _seq++;
      _log.add((seq: _seq, key: key));
      acks.add(
        SyncAck(
          changeId: change.changeId,
          entity: change.entity,
          entityId: change.entityId,
          rev: nextRev,
        ),
      );
    }

    final pending = _log
        .where((entry) => entry.seq > since)
        .take(limit)
        .toList();
    final changesOut = <SyncRemoteChange>[];
    for (final entry in pending) {
      final separator = entry.key.indexOf('/');
      final entity = entry.key.substring(0, separator);
      final id = entry.key.substring(separator + 1);
      changesOut.add(
        SyncRemoteChange(
          entity: entity,
          entityId: id,
          rev: _revs[entry.key]!,
          deleted: _deleted[entry.key] ?? false,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            _updated[entry.key] ?? 0,
            isUtc: true,
          ),
          payload: _payloads[entry.key]!,
        ),
      );
    }
    final cursor = pending.isEmpty ? since : pending.last.seq;

    return SyncResponse(
      acks: acks,
      conflicts: conflicts,
      changes: changesOut,
      cursor: cursor,
      more: _log.where((entry) => entry.seq > cursor).isNotEmpty,
    );
  }
}

final class DeviceTransport implements SyncTransport {
  DeviceTransport(this.server, this.deviceId);

  final MemorySyncServer server;
  final String deviceId;

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async => server.handle(
    deviceId: deviceId,
    since: since,
    changes: changes,
    limit: limit,
  );

  @override
  Future<ServerHealth> health() => throw UnimplementedError();

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) => throw UnimplementedError();

  @override
  Future<SyncCounts> stats() async => const SyncCounts();

  @override
  Future<RemoteSyncSnapshot> snapshot() async =>
      const RemoteSyncSnapshot(entities: [], cursor: 0);

  @override
  Future<SyncReplaceResult> replace({
    required String deviceId,
    required List<SyncSnapshotEntity> entities,
  }) async => const SyncReplaceResult(revs: {}, cursor: 0);
}

void main() {
  final t0 = DateTime.utc(2026, 11, 4, 12);

  AppDatabase openDb() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  PostIt basePostIt({String title = 'A'}) => PostIt(
    id: 'p1',
    title: title,
    type: PostItType.task,
    status: PostItStatus.active,
    startDate: DateOnly(2026, 11, 4),
    createdAt: t0,
    updatedAt: t0,
  );

  test('dois dispositivos convergem e conflito gera cópia', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );

    await repoA.save(basePostIt(title: 'Original'));
    await engineA.run();

    await engineB.run();
    expect((await repoB.loadAll()).single.title, 'Original');

    // B edita e envia primeiro.
    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(title: 'B', updatedAt: t0.add(const Duration(minutes: 2))),
    );
    await engineB.run();

    // A edita com timestamp mais antigo: perde e vira cópia.
    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(title: 'A2', updatedAt: t0.add(const Duration(minutes: 1))),
    );
    final reportA = await engineA.run();

    expect(reportA.conflicts, 1);
    expect(reportA.copies, 1);
    final finalA = await repoA.loadAll();
    expect(finalA.firstWhere((postIt) => postIt.id == 'p1').title, 'B');
    expect(finalA.any((postIt) => postIt.title == '[Conflito] A2'), isTrue);

    // A envia a cópia no próximo sync; B recebe no pull seguinte.
    await engineA.run();
    await engineB.run();
    expect(
      (await repoB.loadAll()).any((postIt) => postIt.title == '[Conflito] A2'),
      isTrue,
    );
  });

  test('edição local mais nova vence e chega ao outro dispositivo', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );

    await repoA.save(basePostIt(title: 'Original'));
    await engineA.run();
    await engineB.run();

    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(title: 'B', updatedAt: t0.add(const Duration(minutes: 1))),
    );
    await engineB.run();

    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(
        title: 'A-novo',
        updatedAt: t0.add(const Duration(minutes: 5)),
      ),
    );
    await engineA.run();

    await engineB.run();
    expect((await repoB.loadAll()).single.title, 'A-novo');
  });
}
