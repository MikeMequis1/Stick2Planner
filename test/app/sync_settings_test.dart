import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

import '../helpers/test_dependencies.dart';

final class SettingsFakeTransport implements SyncTransport {
  int syncCalls = 0;
  int healthCalls = 0;
  int pairCalls = 0;
  int replaceCalls = 0;
  SyncCounts counts = const SyncCounts();
  List<SyncSnapshotEntity> replaced = const [];

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
  Future<ServerHealth> health() async {
    healthCalls++;
    return const ServerHealth(ok: true, version: '0.1.0', serverId: 'srv-ui');
  }

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) async {
    pairCalls++;
    return PairResult(deviceId: deviceId, token: 'token-ui');
  }

  @override
  Future<SyncCounts> stats() async => counts;

  @override
  Future<RemoteSyncSnapshot> snapshot() async =>
      const RemoteSyncSnapshot(entities: [], cursor: 0);

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
          '${entities[index].entity}\u0000${entities[index].entityId}': index + 1,
      },
      cursor: 10,
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('configura servidor, testa, pareia e sincroniza', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tokens = InMemoryTokenStore();
    final transport = SettingsFakeTransport();
    final dependencies = testDependencies(
      now: DateTime(2026, 11, 4, 12),
      tokens: tokens,
      syncTransportFactory: (url, token) => transport,
    );
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-sync-connection')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-sync-connection')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('sync-connection-url')),
      'http://192.168.0.10:8090',
    );
    await tester.tap(find.byKey(const Key('sync-connection-save')));
    await tester.pumpAndSettle();
    expect(dependencies.sync.serverUrl, 'http://192.168.0.10:8090');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sync-connection-test')));
    await tester.pumpAndSettle();
    expect(transport.healthCalls, 1);
    expect(find.text(AppStrings.syncTestOk('srv-ui')), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-sync-pair')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('sync-pair-code')),
      '{"u":"http://192.168.0.10:8090","p":"pair"}',
    );
    await tester.tap(find.byKey(const Key('sync-pair-confirm')));
    await tester.pumpAndSettle();

    expect(transport.pairCalls, 1);
    expect(await tokens.read(), 'token-ui');
    expect(dependencies.sync.enabled, isTrue);
    expect(dependencies.sync.configured, isTrue);
    expect(dependencies.sync.serverUrl, 'http://192.168.0.10:8090');
    await dependencies.sync.setEnabled(false);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('settings-sync-now')));
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('settings-sync-now')),
    );
    expect(button.onPressed, isNotNull);
    final callsBefore = transport.syncCalls;
    await tester.tap(find.byKey(const Key('settings-sync-now')));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(transport.syncCalls, greaterThan(callsBefore));
    expect(dependencies.sync.lastReport, isNotNull);
  });

  testWidgets('divergência pede confirmação antes de sincronizar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tokens = InMemoryTokenStore();
    final transport = SettingsFakeTransport()
      ..counts = const SyncCounts(postIts: 5, events: 1, tasks: 4);
    final dependencies = testDependencies(
      now: DateTime(2026, 11, 5, 12),
      tokens: tokens,
      syncTransportFactory: (url, token) => transport,
    );
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await dependencies.planner.createPostIt(
      title: 'Local',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 5),
    );
    await dependencies.database.delete(dependencies.database.syncOutbox).go();
    await tokens.write('token-ui');
    await dependencies.sync.setServerUrl('http://192.168.0.10:8090');
    await dependencies.sync.refreshConfig();

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-sync-now')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('settings-sync-now')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.syncReviewTitle), findsOneWidget);
    expect(find.byKey(const Key('sync-review-local')), findsOneWidget);
    expect(find.byKey(const Key('sync-review-remote')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sync-review-local')));
    await tester.pumpAndSettle();

    expect(transport.replaceCalls, 1);
    expect(
      transport.replaced.where((entity) => entity.entity == 'postIt'),
      hasLength(1),
    );
    expect(dependencies.sync.pendingPreflight, isNull);
  });
}
