import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await initializeDateFormatting('pt_BR');
  await initializeDateFormatting('en');

  final dependencies = AppDependencies.open();
  await dependencies.initialize();

  runApp(PlannerApp(dependencies: dependencies));
}
