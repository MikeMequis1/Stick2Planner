import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/services/sync_coordinator.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

final class FakeTransport implements SyncTransport {
  bool failSync = false;
  bool failHealth = false;
  int healthCalls = 0;
  int pairCalls = 0;
  int syncCalls = 0;
  List<SyncChange> lastChanges = const [];

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    syncCalls++;
    lastChanges = changes;
    if (failSync) throw const SyncException('offline', retryable: true);
    return SyncResponse(
      acks: const [],
      conflicts: const [],
      changes: const [],
      cursor: since,
      more: false,
    );
  }

  @override
  Future<ServerHealth> health() async {
    healthCalls++;
    if (failHealth) throw const SyncException('unreachable');
    return const ServerHealth(ok: true, version: '0.1.0', serverId: 'srv');
  }

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) async {
    pairCalls++;
    return PairResult(deviceId: deviceId, token: 'device-token');
  }

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
  final now = DateTime.utc(2026, 11, 4, 12);

  ({
    AppDatabase db,
    SyncCoordinator coordinator,
    FakeTransport transport,
    TokenStore tokens,
    SyncStateStore state,
  })
  build({
    Stream<bool>? connectivity,
    Duration debounce = const Duration(seconds: 2),
  }) {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final tokens = InMemoryTokenStore();
    final state = SyncStateStore(db);
    final transport = FakeTransport();
    final coordinator = SyncCoordinator(
      database: db,
      state: state,
      tokens: tokens,
      transportFactory: (url, token) => transport,
      debounce: debounce,
      connectivityChanges: connectivity,
    );
    addTearDown(coordinator.dispose);
    return (
      db: db,
      coordinator: coordinator,
      transport: transport,
      tokens: tokens,
      state: state,
    );
  }

  Future<void> configure(
    ({
      AppDatabase db,
      SyncCoordinator coordinator,
      FakeTransport transport,
      TokenStore tokens,
      SyncStateStore state,
    })
    ctx,
  ) async {
    await ctx.tokens.write('token');
    await ctx.state.setServerUrl('http://127.0.0.1:8090');
    await ctx.state.setEnabled(true);
    await ctx.coordinator.initialize();
  }

  test('endereço inválido é recusado e válido é salvo', () async {
    final ctx = build();
    await ctx.coordinator.initialize();

    expect(
      () => ctx.coordinator.setServerUrl('ftp://x'),
      throwsFormatException,
    );
    await ctx.coordinator.setServerUrl('http://192.168.0.10:8090/');
    expect(ctx.coordinator.serverUrl, 'http://192.168.0.10:8090');
    expect(await ctx.state.serverUrl(), 'http://192.168.0.10:8090');
  });

  test('pareamento salva token, URL e habilita', () async {
    final ctx = build();
    await ctx.coordinator.initialize();

    await ctx.coordinator.pair(
      '{"u":"http://host:8090","p":"pair-token"}',
      deviceName: 'Tablet',
    );

    expect(ctx.transport.pairCalls, 1);
    expect(await ctx.tokens.read(), 'device-token');
    expect(await ctx.state.serverUrl(), 'http://host:8090');
    expect(ctx.coordinator.enabled, isTrue);
    expect(ctx.coordinator.configured, isTrue);
  });

  test('pareamento define rótulo e desconexão limpa o estado', () async {
    final ctx = build();
    await ctx.coordinator.initialize();

    await ctx.coordinator.pair(
      '{"u":"http://host:8090","p":"pair-token"}',
      deviceName: 'Tablet de teste',
    );
    expect(ctx.coordinator.configured, isTrue);
    expect(ctx.coordinator.pairedDeviceLabel, 'Tablet de teste');

    await ctx.coordinator.disconnect();
    expect(ctx.coordinator.configured, isFalse);
    expect(ctx.coordinator.pairedDeviceLabel, isNull);
    expect(ctx.coordinator.serverUrl, isNull);
  });

  test('teste de conexão usa o endereço informado', () async {
    final ctx = build();
    await ctx.coordinator.initialize();

    final health = await ctx.coordinator.testConnection(
      'http://192.168.0.10:8090',
    );
    expect(health.serverId, 'srv');
    expect(ctx.transport.healthCalls, 1);
  });

  test('sync manual publica relatório e limpa erro', () async {
    final ctx = build();
    await configure(ctx);

    final report = await ctx.coordinator.syncNow();

    expect(report, isNotNull);
    expect(ctx.coordinator.lastSyncAt, isNotNull);
    expect(ctx.coordinator.lastError, isNull);
    expect(ctx.transport.syncCalls, greaterThanOrEqualTo(1));
  });

  test('falha fica registrada sem derrubar o app', () async {
    final ctx = build();
    await configure(ctx);
    ctx.transport.failSync = true;

    final report = await ctx.coordinator.syncNow();

    expect(report, isNull);
    expect(ctx.coordinator.lastError, contains('offline'));
  });

  test('alteração local agenda sync com debounce', () async {
    final ctx = build(debounce: const Duration(milliseconds: 20));
    await configure(ctx);

    await DriftPostItRepository(ctx.db).save(
      PostIt(
        id: 'p1',
        title: 'Debounce',
        type: PostItType.task,
        status: PostItStatus.active,
        startDate: DateOnly(2026, 11, 4),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(ctx.transport.syncCalls, greaterThanOrEqualTo(1));
    expect(ctx.coordinator.pendingCount, greaterThanOrEqualTo(1));
  });

  test('reconexão dispara sync', () async {
    final controller = StreamController<bool>.broadcast();
    addTearDown(controller.close);
    final ctx = build(connectivity: controller.stream);
    await configure(ctx);

    controller.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(ctx.transport.syncCalls, greaterThanOrEqualTo(1));
  });
}
