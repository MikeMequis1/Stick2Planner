import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/features/planner/widgets/day_cell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<void> pumpApp(WidgetTester tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 10, 31, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  testWidgets('abre na agenda e navega pelas três seções', (tester) async {
    await pumpApp(tester);

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.agenda), findsWidgets);
    expect(find.text(AppStrings.inbox), findsWidgets);
    expect(find.text(AppStrings.notes), findsWidgets);
    expect(find.byType(DayCell), findsNWidgets(7));
    expect(find.byKey(const Key('day-2026-10-31')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.inbox),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.inboxPlaceholderTitle), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.notes),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.notesPlaceholderTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('usa barra inferior em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(DayCell), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.notes),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.notesPlaceholderTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
