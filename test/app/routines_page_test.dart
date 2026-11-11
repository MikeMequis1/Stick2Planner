import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/controllers/routines_controller.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('navega entre dias por gesto e respeita a criação', (
    tester,
  ) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await dependencies.routines.saveRoutine(
      name: 'Rotina de segunda',
      weekdays: {1},
      items: const [RoutineItemInput(title: 'Planejar a semana')],
    );
    await dependencies.routines.saveRoutine(
      name: 'Rotina de terça',
      weekdays: {2},
      items: const [RoutineItemInput(title: 'Revisar pendências')],
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

    expect(find.text('Rotina de segunda'), findsOneWidget);
    expect(find.text('Rotina de terça'), findsNothing);

    await tester.fling(
      find.byKey(const Key('routine-swipe-area')),
      const Offset(-420, 0),
      1200,
    );
    await tester.pumpAndSettle();

    expect(find.text('Rotina de terça'), findsOneWidget);
    expect(find.text('Rotina de segunda'), findsNothing);

    await tester.tap(find.byKey(const Key('routine-today')));
    await tester.pumpAndSettle();

    expect(find.text('Rotina de segunda'), findsOneWidget);
  });

  testWidgets('layout compacto mantém a navegação e não estoura', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await dependencies.routines.saveRoutine(
      name: 'Rotina compacta',
      weekdays: {1},
      items: const [RoutineItemInput(title: 'Atividade')],
    );

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-routines')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('routine-swipe-area')), findsOneWidget);
    expect(find.text('Rotina compacta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dicas seguem a configuração de animações e transições', (
    tester,
  ) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final routine = await dependencies.routines.saveRoutine(
      name: 'Rotina com dicas',
      weekdays: {1},
      items: const [RoutineItemInput(title: 'Atividade')],
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

    expect(find.text(AppStrings.routineSwipeHint), findsOneWidget);
    await tester.tap(find.byKey(Key('routine-${routine.id}')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.dragToReorder), findsOneWidget);

    await dependencies.settings.setAnimationsEnabled(false);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.routineSwipeHint), findsNothing);
    expect(find.text(AppStrings.dragToReorder), findsNothing);

    await dependencies.settings.setAnimationsEnabled(true);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.routineSwipeHint), findsOneWidget);
    expect(find.text(AppStrings.dragToReorder), findsOneWidget);
  });

  testWidgets('expande a rotina e reordena atividades pela alça', (
    tester,
  ) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final routine = await dependencies.routines.saveRoutine(
      name: 'Rotina diária',
      weekdays: {1},
      items: const [
        RoutineItemInput(title: 'Primeira'),
        RoutineItemInput(title: 'Segunda'),
      ],
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

    await tester.tap(find.byKey(Key('routine-${routine.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Primeira'), findsOneWidget);
    expect(find.text('Segunda'), findsOneWidget);

    final handle = find.byKey(
      Key('routine-item-handle-${routine.items.first.id}'),
    );
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.moveBy(const Offset(0, 70));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.moveBy(const Offset(0, 70));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      dependencies.routines.routines.single.items.map((item) => item.title),
      ['Segunda', 'Primeira'],
    );
  });
}
