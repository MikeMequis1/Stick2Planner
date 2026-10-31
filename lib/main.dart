import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  final dependencies = AppDependencies.open();
  await dependencies.initialize();

  runApp(PlannerApp(dependencies: dependencies));
}
