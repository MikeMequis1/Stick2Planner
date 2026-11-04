import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/controllers/sync_controller.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/sync/sync_engine.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';

final class _EmptyTransport implements SyncTransport {
  _EmptyTransport({this.completer});

  final Completer<void>? completer;

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    await completer?.future;
    return SyncResponse(
      acks: const [],
      conflicts: const [],
      changes: const [],
      cursor: since,
      more: false,
    );
  }

  @override
  Future<ServerHealth> health() => throw UnimplementedError();

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) => throw UnimplementedError();
}

final class _FailingTransport implements SyncTransport {
  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async => throw const SyncException('offline', retryable: true);

  @override
  Future<ServerHealth> health() => throw UnimplementedError();

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) => throw UnimplementedError();
}

void main() {
  SyncController controllerFor(AppDatabase db, SyncTransport transport) =>
      SyncController(
        engineFactory: () => SyncEngine(
          database: db,
          transport: transport,
          state: SyncStateStore(db),
        ),
      );

  test('rodada bem-sucedida publica o relatório', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final controller = controllerFor(db, _EmptyTransport());

    final report = await controller.syncNow();

    expect(report, isNotNull);
    expect(controller.status, SyncRunStatus.success);
    expect(controller.error, isNull);
    expect(controller.lastReport, isNotNull);
  });

  test('falha de transporte vira estado de erro', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final controller = controllerFor(db, _FailingTransport());

    final report = await controller.syncNow();

    expect(report, isNull);
    expect(controller.status, SyncRunStatus.failure);
    expect(controller.error, contains('offline'));
  });

  test('chamada concorrente é ignorada', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final gate = Completer<void>();
    final controller = controllerFor(db, _EmptyTransport(completer: gate));

    final first = controller.syncNow();
    expect(controller.isRunning, isTrue);
    expect(await controller.syncNow(), isNull);

    gate.complete();
    expect(await first, isNotNull);
    expect(controller.status, SyncRunStatus.success);
  });
}
