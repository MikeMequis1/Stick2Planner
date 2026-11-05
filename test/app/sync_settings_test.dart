import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';

import '../helpers/test_dependencies.dart';

final class SettingsFakeTransport implements SyncTransport {
  int syncCalls = 0;
  int healthCalls = 0;
  int pairCalls = 0;

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
}
