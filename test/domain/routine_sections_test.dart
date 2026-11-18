import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/routine.dart';
import 'package:stick2planner/domain/usecases/routine_sections.dart';

RoutineSection section({
  int? start = 480,
  int? end = 720,
  List<RoutineInterval>? intervals,
}) {
  final id = 's1';
  return RoutineSection(
    id: id,
    routineId: 'r1',
    title: 'Manhã',
    position: 0,
    startMinutes: start,
    endMinutes: end,
    intervals:
        intervals ??
        [
          RoutineInterval(
            id: 'i1',
            sectionId: id,
            startMinutes: start ?? 480,
            endMinutes: end ?? 720,
            position: 0,
            title: 'Estudar',
            completedDates: {DateOnly(2026, 11, 10)},
          ),
        ],
  );
}

void main() {
  test('adicionar horário divide o intervalo mantendo tarefa e conclusão', () {
    final updated = addSectionTime(
      section(),
      minutes: 600,
      idGenerator: () => 'i2',
    );

    expect(updated.intermediateTimes, [600]);
    expect(updated.intervals, hasLength(2));
    expect(updated.intervals.first.id, 'i1');
    expect(updated.intervals.first.endMinutes, 600);
    expect(updated.intervals.first.title, 'Estudar');
    expect(updated.intervals.first.completedDates, {DateOnly(2026, 11, 10)});
    expect(updated.intervals.last.id, 'i2');
    expect(updated.intervals.last.title, isNull);
  });

  test('mover fronteira preserva IDs e tarefas', () {
    final withTime = addSectionTime(
      section(),
      minutes: 600,
      idGenerator: () => 'i2',
    );
    final moved = moveSectionTime(withTime, fromMinutes: 600, toMinutes: 630);

    expect(moved.intermediateTimes, [630]);
    expect(moved.intervals.map((item) => item.id), ['i1', 'i2']);
    expect(moved.intervals.first.endMinutes, 630);
    expect(moved.intervals.last.startMinutes, 630);
  });

  test('remover horário une intervalos e preserva tarefa única', () {
    final withTime = addSectionTime(
      section(),
      minutes: 600,
      idGenerator: () => 'i2',
    );
    final merged = removeSectionTime(withTime, minutes: 600);

    expect(merged.intervals, hasLength(1));
    expect(merged.intervals.single.id, 'i1');
    expect(merged.intervals.single.title, 'Estudar');
    expect(merged.intervals.single.endMinutes, 720);
  });

  test('mover fronteira respeita os horários vizinhos', () {
    var value = section(start: 480, end: 960);
    value = addSectionTime(value, minutes: 600, idGenerator: () => 'i2');
    value = addSectionTime(value, minutes: 720, idGenerator: () => 'i3');

    expect(
      () => moveSectionTime(value, fromMinutes: 600, toMinutes: 750),
      throwsA(isA<RoutineSectionValidationException>()),
    );
    expect(
      () => moveSectionTime(value, fromMinutes: 600, toMinutes: 470),
      throwsA(isA<RoutineSectionValidationException>()),
    );
    final moved = moveSectionTime(value, fromMinutes: 600, toMinutes: 700);
    expect(moved.intermediateTimes, [700, 720]);
    expect(moved.intervals.map((item) => item.id), ['i1', 'i2', 'i3']);
  });

  test('remover horário preserva tarefa que está à direita', () {
    final withTime = addSectionTime(
      section(),
      minutes: 600,
      idGenerator: () => 'i2',
    );
    final rightTask = withTime.copyWith(
      intervals: [
        withTime.intervals.first.copyWith(
          title: null,
          completedDates: const {},
        ),
        withTime.intervals.last.copyWith(
          title: 'Trabalhar',
          completedDates: {DateOnly(2026, 11, 11)},
        ),
      ],
    );
    final merged = removeSectionTime(rightTask, minutes: 600);

    expect(merged.intervals.single.id, 'i1');
    expect(merged.intervals.single.title, 'Trabalhar');
    expect(merged.intervals.single.completedDates, {DateOnly(2026, 11, 11)});
  });

  test('conflito entre duas tarefas exige escolha', () {
    final withTime = addSectionTime(
      section(),
      minutes: 600,
      idGenerator: () => 'i2',
    );
    final withTasks = withTime.copyWith(
      intervals: [
        withTime.intervals.first,
        withTime.intervals.last.copyWith(title: 'Trabalhar'),
      ],
    );

    expect(
      () => removeSectionTime(withTasks, minutes: 600),
      throwsA(isA<RoutineSectionMergeException>()),
    );
  });

  test('valida limites, vãos e tarefas', () {
    expect(validateRoutineSections([section()]), isEmpty);
    expect(
      validateRoutineSections([section(start: 720, end: 480)]),
      contains(RoutineSectionValidationError.endBeforeStart),
    );
    expect(
      validateRoutineSections([section(start: 480, end: null)]),
      contains(RoutineSectionValidationError.missingBoundary),
    );
    expect(
      validateRoutineSections([
        section(
          intervals: [section().intervals.single.copyWith(endMinutes: 600)],
        ),
      ]),
      contains(RoutineSectionValidationError.invalidInterval),
    );
    expect(
      validateRoutineSections([
        RoutineSection(
          id: 's1',
          routineId: 'r1',
          title: '',
          position: 0,
          startMinutes: null,
          endMinutes: null,
        ),
      ]),
      contains(RoutineSectionValidationError.titleEmpty),
    );
  });
}
