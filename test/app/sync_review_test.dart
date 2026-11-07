import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/services/sync_coordinator.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_payload.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

final class ReviewTransport implements SyncTransport {
  ReviewTransport({
    this.counts = const SyncCounts(postIts: 3),
    this.snapshotData = const RemoteSyncSnapshot(entities: [], cursor: 0),
  });

  final SyncCounts counts;
  RemoteSyncSnapshot snapshotData;
  int statsCalls = 0;
  int syncCalls = 0;
  int replaceCalls = 0;
  int snapshotCalls = 0;
  List<SyncSnapshotEntity> replaced = const [];

  @override
  Future<SyncCounts> stats() async {
    statsCalls++;
    return counts;
  }

  @override
  Future<RemoteSyncSnapshot> snapshot() async {
    snapshotCalls++;
    return snapshotData;
  }

  @override
  Future<SyncReplaceResult> replace({
    required String deviceId,
    required List<SyncSnapshotEntity> entities,
  }) async {
    replaceCalls++;
    replaced = entities;
    return SyncReplaceResult(
      revs: {
        for (var index = 0; index < entities.length; index++)
          '${entities[index].entity}\u0000${entities[index].entityId}':
              index + 1,
      },
      cursor: 100,
    );
  }

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    syncCalls++;
    return SyncResponse(
      acks: const [],
      conflicts: const [],
      changes: const [],
      cursor: since,
      more: false,
    );
  }

  @override
  Future<ServerHealth> health() async =>
      const ServerHealth(ok: true, version: '0.1.0', serverId: 'srv');

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) async => PairResult(deviceId: deviceId, token: 'token');
}

void main() {
  final t0 = DateTime.utc(2026, 11, 5, 12);

  ({
    AppDatabase db,
    SyncCoordinator coordinator,
    ReviewTransport transport,
    SyncStateStore state,
    TokenStore tokens,
  })
  build() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final state = SyncStateStore(db);
    final tokens = InMemoryTokenStore();
    final transport = ReviewTransport();
    final coordinator = SyncCoordinator(
      database: db,
      state: state,
      tokens: tokens,
      transportFactory: (url, token) => transport,
      debounce: const Duration(hours: 1),
    );
    addTearDown(coordinator.dispose);
    return (
      db: db,
      coordinator: coordinator,
      transport: transport,
      state: state,
      tokens: tokens,
    );
  }

  Future<void> configure(
    ({
      AppDatabase db,
      SyncCoordinator coordinator,
      ReviewTransport transport,
      SyncStateStore state,
      TokenStore tokens,
    })
    ctx,
  ) async {
    await ctx.tokens.write('token');
    await ctx.state.setServerUrl('http://127.0.0.1:8090');
    await ctx.state.setEnabled(true);
    await ctx.coordinator.initialize();
  }

  PostIt postIt(String id) => PostIt(
    id: id,
    title: id,
    type: PostItType.event,
    status: PostItStatus.active,
    startDate: DateOnly(2026, 11, 5),
    createdAt: t0,
    updatedAt: t0,
  );

  test('pendências após sync anterior não pedem escolha', () {
    const preflight = SyncPreflight(
      local: SyncCounts(postIts: 5),
      remote: SyncCounts(postIts: 6),
      hasLocalChanges: true,
      hasSyncedBefore: true,
    );
    expect(preflight.requiresChoice, isFalse);
    expect(
      const SyncPreflight(
        local: SyncCounts(postIts: 5),
        remote: SyncCounts(postIts: 6),
        hasLocalChanges: true,
        hasSyncedBefore: false,
      ).requiresChoice,
      isTrue,
    );
  });

  test('diferença apenas de tags exige revisão', () {
    expect(const SyncCounts(tags: 1).isEmpty, isFalse);
    expect(
      const SyncCounts(tags: 1).hasSameUserData(const SyncCounts(tags: 2)),
      isFalse,
    );
    expect(
      const SyncPreflight(
        local: SyncCounts(tags: 1),
        remote: SyncCounts(tags: 2),
        hasLocalChanges: false,
        hasSyncedBefore: true,
      ).requiresChoice,
      isTrue,
    );
  });

  test('divergência sem alterações locais exige revisão', () async {
    final ctx = build();
    await configure(ctx);
    final repository = DriftPostItRepository(ctx.db);
    await repository.save(postIt('p1'));
    await repository.save(postIt('p2'));
    await ctx.db.delete(ctx.db.syncOutbox).go();
    await ctx.coordinator.refreshConfig();

    final preflight = await ctx.coordinator.inspect();

    expect(preflight, isNotNull);
    expect(preflight!.local.postIts, 2);
    expect(preflight.remote.postIts, 3);
    expect(preflight.requiresChoice, isTrue);
    expect(ctx.coordinator.pendingPreflight, isNotNull);
    expect(await ctx.coordinator.syncNow(), isNull);
    expect(ctx.transport.syncCalls, 0);
  });

  test('manter local substitui o conjunto remoto', () async {
    final ctx = build();
    await configure(ctx);
    final repository = DriftPostItRepository(ctx.db);
    await repository.save(postIt('p1'));
    await repository.save(postIt('p2'));
    await ctx.db.delete(ctx.db.syncOutbox).go();
    await ctx.coordinator.refreshConfig();

    final report = await ctx.coordinator.syncNow(
      mode: SyncMode.keepLocal,
      inspectFirst: false,
    );

    expect(report, isNotNull);
    expect(ctx.transport.replaceCalls, 1);
    expect(ctx.transport.replaced, hasLength(2));
    expect(ctx.coordinator.pendingPreflight, isNull);
    expect(await ctx.db.select(ctx.db.syncOutbox).get(), isEmpty);
    expect(await ctx.state.cursor(), 100);
  });

  test('manter remoto substitui o conteúdo local', () async {
    final ctx = build();
    await configure(ctx);
    final repository = DriftPostItRepository(ctx.db);
    await repository.save(postIt('local-1'));
    await repository.save(postIt('local-2'));
    await ctx.db.delete(ctx.db.syncOutbox).go();

    ctx.transport.snapshotData = RemoteSyncSnapshot(
      entities: [
        SyncSnapshotEntity(
          entity: syncEntityPostIt,
          entityId: 'remote-1',
          rev: 4,
          updatedAt: t0,
          deleted: false,
          payload: postItPayload(postIt('remote-1')),
        ),
      ],
      cursor: 50,
    );

    final report = await ctx.coordinator.syncNow(
      mode: SyncMode.keepRemote,
      inspectFirst: false,
    );

    expect(report, isNotNull);
    expect(report!.pulled, 1);
    final rows = await ctx.db.select(ctx.db.postIts).get();
    expect(rows.map((row) => row.id), ['remote-1']);
    expect(await ctx.db.select(ctx.db.syncOutbox).get(), isEmpty);
    expect(await ctx.state.cursor(), 50);
  });
}
