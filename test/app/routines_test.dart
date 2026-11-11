import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/controllers/routines_controller.dart';
import 'package:stick2planner/core/date_only.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('rotina repete nos dias escolhidos e conclui por ocorrência', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final routines = dependencies.routines;

    final routine = await routines.saveRoutine(
      name: 'Manhã',
      details: 'Antes do trabalho',
      weekdays: {1, 3},
      items: const [
        RoutineItemInput(title: 'Alongar'),
        RoutineItemInput(title: 'Ler'),
      ],
    );

    final monday = DateOnly(2026, 11, 9);
    final tuesday = DateOnly(2026, 11, 10);
    final wednesday = DateOnly(2026, 11, 11);
    expect(routine.items, hasLength(2));
    expect(routines.routinesOn(monday).single.id, routine.id);
    expect(routines.routinesOn(tuesday), isEmpty);
    expect(routines.routinesOn(wednesday).single.id, routine.id);

    await routines.toggleCompletion(routine.items.first, monday);
    var current = routines.routines.single;
    expect(current.items.first.isCompletedOn(monday), isTrue);
    expect(current.items.first.isCompletedOn(wednesday), isFalse);

    await routines.toggleCompletion(current.items.first, wednesday);
    current = routines.routines.single;
    expect(current.items.first.isCompletedOn(monday), isTrue);
    expect(current.items.first.isCompletedOn(wednesday), isTrue);

    await routines.toggleCompletion(current.items.first, monday);
    current = routines.routines.single;
    expect(current.items.first.isCompletedOn(monday), isFalse);
    expect(current.items.first.isCompletedOn(wednesday), isTrue);
  });

  test('edita, reordena e exclui rotina preservando ids', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final routines = dependencies.routines;

    final routine = await routines.saveRoutine(
      name: 'Noite',
      weekdays: {1},
      items: const [
        RoutineItemInput(title: 'A'),
        RoutineItemInput(title: 'B'),
      ],
    );
    final firstId = routine.items.first.id;
    final monday = DateOnly(2026, 11, 9);
    await routines.toggleCompletion(routine.items.first, monday);

    await routines.saveRoutine(
      id: routine.id,
      name: 'Noite editada',
      weekdays: {1, 2},
      items: [
        RoutineItemInput(id: routine.items.last.id, title: 'B primeiro'),
        RoutineItemInput(id: firstId, title: 'A depois'),
        const RoutineItemInput(title: 'C'),
      ],
    );

    final updated = routines.routines.single;
    expect(updated.name, 'Noite editada');
    expect(updated.weekdays, {1, 2});
    expect(updated.items.map((item) => item.title), [
      'B primeiro',
      'A depois',
      'C',
    ]);
    expect(updated.items[1].isCompletedOn(monday), isTrue);

    await routines.deleteRoutine(updated);
    expect(routines.routines, isEmpty);
  });

  test('recusa nome vazio ou nenhum dia', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final routines = dependencies.routines;

    await expectLater(
      routines.saveRoutine(name: '  ', weekdays: {1}, items: const []),
      throwsFormatException,
    );
    await expectLater(
      routines.saveRoutine(name: 'Sem dia', weekdays: {}, items: const []),
      throwsFormatException,
    );
  });

  test('não gera ocorrências antes da criação e preserva createdAt', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final routines = dependencies.routines;

    final routine = await routines.saveRoutine(
      name: 'Semana',
      weekdays: {1},
      items: const [RoutineItemInput(title: 'Planejar')],
    );
    final createdAt = routine.createdAt;

    expect(routines.routinesOn(DateOnly(2026, 11, 2)), isEmpty);
    expect(routines.routinesOn(DateOnly(2026, 11, 9)), hasLength(1));

    await routines.toggleCompletion(routine.items.first, DateOnly(2026, 11, 2));
    expect(
      routines.routines.single.items.first.isCompletedOn(DateOnly(2026, 11, 2)),
      isFalse,
    );

    await routines.saveRoutine(
      id: routine.id,
      name: 'Semana editada',
      weekdays: {1, 3},
      items: const [RoutineItemInput(title: 'Planejar melhor')],
    );
    expect(routines.routines.single.createdAt, createdAt);
  });

  test('reordena e remove atividades persistindo a ordem', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final routines = dependencies.routines;

    final routine = await routines.saveRoutine(
      name: 'Ordem',
      weekdays: {1},
      items: const [
        RoutineItemInput(title: 'A'),
        RoutineItemInput(title: 'B'),
        RoutineItemInput(title: 'C'),
      ],
    );
    final createdAt = routine.createdAt;
    final monday = DateOnly(2026, 11, 9);
    await routines.toggleCompletion(routine.items.first, monday);

    await routines.reorderItems(routine, 0, 2);
    var current = routines.routines.single;
    expect(current.items.map((item) => item.title), ['B', 'C', 'A']);
    expect(current.items.map((item) => item.position), [0, 1, 2]);
    expect(current.createdAt, createdAt);
    expect(current.items.last.isCompletedOn(monday), isTrue);

    await routines.removeItem(current, current.items[1]);
    current = routines.routines.single;
    expect(current.items.map((item) => item.title), ['B', 'A']);
    expect(current.items.map((item) => item.position), [0, 1]);
  });
}
