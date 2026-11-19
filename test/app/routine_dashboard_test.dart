import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/controllers/routines_controller.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/routine.dart';
import 'package:stick2planner/features/routines/routine_dashboard_page.dart';

import '../helpers/test_dependencies.dart';

void main() {
  testWidgets('dashboard mostra execuções persistidas', (tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final today = DateOnly.fromDateTime(DateTime.now());
    final routine = await dependencies.routines.saveRoutine(
      name: 'Hidratação',
      weekdays: {1, 2, 3, 4, 5, 6, 7},
      items: const [RoutineItemInput(id: 'water', title: 'Beber água')],
    );
    await dependencies.routines.recordExecution(
      routineId: routine.id,
      date: today,
      origin: RoutineExecutionOrigin.notification,
      itemId: 'water',
      reminderId: 'rem1',
      slotMinutes: 480,
    );

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.routines),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-routine-dashboard')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dashboard), findsOneWidget);
    expect(find.text(AppStrings.dashboardExecutions), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Beber água'),
      200,
      scrollable: find.descendant(
        of: find.byType(RoutineDashboardPage),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.textContaining('Beber água'), findsWidgets);
  });
}
