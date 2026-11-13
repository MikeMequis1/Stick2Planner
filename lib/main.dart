import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/services/background_sync.dart';
import 'core/platform_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Barras de sistema só existem no Android/iOS; em desktop a janela nativa
  // cuida do dimensionamento e não há imersão para configurar.
  if (!isDesktopRuntime) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  await initializeDateFormatting('pt_BR');
  await initializeDateFormatting('en');

  final dependencies = AppDependencies.open();
  await dependencies.initialize();
  await scheduleBackgroundSync();

  runApp(PlannerApp(dependencies: dependencies));
}
