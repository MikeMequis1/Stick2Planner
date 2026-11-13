import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/platform_support.dart';
import '../../data/db/app_database.dart';
import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_state_store.dart';
import '../../data/sync/sync_transport.dart';
import 'token_store.dart';

const backgroundSyncTaskName = 'stick2planner.sync';
const _periodicUniqueName = 'stick2planner.sync.periodic';

/// Entrada executada pelo WorkManager em isolate próprio.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final database = AppDatabase.open();
    try {
      final state = SyncStateStore(database);
      final token = await SecureTokenStore().read();
      final url = await state.serverUrl();
      if (url == null || url.isEmpty || token == null || token.isEmpty) {
        return true;
      }
      final engine = SyncEngine(
        database: database,
        transport: HttpSyncTransport(baseUrl: Uri.parse(url), token: token),
        state: state,
      );
      await engine.run();
    } on Object {
      // Best-effort: a próxima execução tenta novamente.
    } finally {
      await database.close();
    }
    return true;
  });
}

/// Registra a sincronização periódica (mínimo de 15 min no Android).
Future<void> scheduleBackgroundSync() async {
  if (!supportsBackgroundSync) return;
  try {
    await Workmanager().initialize(syncCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _periodicUniqueName,
      backgroundSyncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } on Object {
    // WorkManager é best-effort; o app continua com sync oportunístico.
  }
}
