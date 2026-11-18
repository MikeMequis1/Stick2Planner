import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/controllers/routines_controller.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/routine.dart';

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

  testWidgets('cria rotina completa com card vazio', (tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.routines),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-routine')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('routine-name')),
      'Rotina completa',
    );
    await tester.tap(find.text(AppStrings.routineComplete));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('routine-add-section')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('routine-section-title-0')),
      'Manhã',
    );
    await tester.tap(find.byKey(const Key('routine-save')));
    await tester.pumpAndSettle();

    final routine = dependencies.routines.routines.single;
    expect(routine.mode, RoutineMode.complete);
    expect(routine.sections.single.title, 'Manhã');
    expect(routine.sections.single.startMinutes, isNull);
    expect(routine.sections.single.endMinutes, isNull);
  });

  testWidgets('dicas seguem a configuração Mostrar dicas', (tester) async {
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

    await dependencies.settings.setShowCalendarHints(false);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.routineSwipeHint), findsNothing);
    expect(find.text(AppStrings.dragToReorder), findsNothing);

    await dependencies.settings.setShowCalendarHints(true);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.routineSwipeHint), findsOneWidget);
    expect(find.text(AppStrings.dragToReorder), findsOneWidget);
  });

  testWidgets('rotina completa mostra cards e permite concluir tarefa', (
    tester,
  ) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final routine = await dependencies.routines.saveRoutine(
      name: 'Rotina completa',
      mode: RoutineMode.complete,
      weekdays: {1},
      items: const [],
      sections: [
        const RoutineSection(
          id: 's1',
          routineId: '',
          title: 'Manhã',
          position: 0,
          startMinutes: 480,
          endMinutes: 600,
          intervals: [
            RoutineInterval(
              id: 'i1',
              sectionId: 's1',
              startMinutes: 480,
              endMinutes: 600,
              position: 0,
              title: 'Estudar',
            ),
          ],
        ),
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

    expect(find.text('Manhã'), findsOneWidget);
    expect(find.text('Estudar'), findsOneWidget);
    final checkbox = find.byKey(Key('routine-interval-i1-2026-11-09'));
    expect(checkbox, findsOneWidget);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    expect(
      dependencies.routines.routines.single.sections.single.intervals.single
          .isCompletedOn(DateOnly(2026, 11, 9)),
      isTrue,
    );
  });

  testWidgets('cards completos usam duas colunas em tela larga', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final routine = await dependencies.routines.saveRoutine(
      name: 'Rotina completa',
      mode: RoutineMode.complete,
      weekdays: {1},
      items: const [],
      sections: const [
        RoutineSection(
          id: 'wide-s1',
          routineId: '',
          title: 'Manhã',
          position: 0,
          startMinutes: 480,
          endMinutes: 600,
          intervals: [
            RoutineInterval(
              id: 'wide-i1',
              sectionId: 'wide-s1',
              startMinutes: 480,
              endMinutes: 600,
              position: 0,
              title: 'Estudar',
            ),
          ],
        ),
        RoutineSection(
          id: 'wide-s2',
          routineId: '',
          title: 'Tarde',
          position: 1,
          startMinutes: 780,
          endMinutes: 900,
          intervals: [
            RoutineInterval(
              id: 'wide-i2',
              sectionId: 'wide-s2',
              startMinutes: 780,
              endMinutes: 900,
              position: 0,
              title: 'Trabalhar',
            ),
          ],
        ),
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

    final first = tester.getTopLeft(find.byKey(const ValueKey('wide-s1')));
    final second = tester.getTopLeft(find.byKey(const ValueKey('wide-s2')));
    expect(first.dy, second.dy);
    expect(second.dx, greaterThan(first.dx));
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
