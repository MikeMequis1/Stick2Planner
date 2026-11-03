import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeDateFormatting('pt_BR');

  final dependencies = AppDependencies.open();
  await dependencies.initialize();

  try {
    await dependencies.screenWake.enable();
  } on Object {
    // Wakelock é best-effort; a tela ainda funciona sem ele.
  }

  runApp(PlannerApp(dependencies: dependencies));
}
