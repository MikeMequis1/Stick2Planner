import 'package:flutter/material.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/features/planner/widgets/day_cell.dart';
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

  testWidgets('abre na agenda e navega pelas seções', (tester) async {
    await pumpApp(tester);

    expect(find.text(AppStrings.appName), findsNothing);
    expect(find.text(AppStrings.agenda), findsWidgets);
    expect(find.text(AppStrings.inbox), findsWidgets);
    expect(find.text(AppStrings.notes), findsWidgets);
    expect(find.text(AppStrings.routines), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(7));
    expect(find.byKey(const Key('day-2026-10-31')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.inbox),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inbox-search')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.notes),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add-note')), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.routines),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add-routine')), findsOneWidget);
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
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byKey(const Key('add-post-it')), findsOneWidget);
    expect(find.byType(DayCell), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-post-it')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-title')), findsOneWidget);
    await tester.ensureVisible(find.text(AppStrings.cancel));
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-inbox')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add-post-it')), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-post-it')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-title')), findsOneWidget);
    await tester.ensureVisible(find.text(AppStrings.cancel));
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-notes')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add-post-it')), findsNothing);
    expect(find.byKey(const Key('add-note')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nuvem reflete o estado e abre a conexão nas configurações', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-sync-settings')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.settings), findsOneWidget);
    final status = tester.getRect(
      find.byKey(const Key('settings-sync-status')),
    );
    expect(status.top, greaterThanOrEqualTo(0));
    expect(status.bottom, lessThan(600));
  });
}
