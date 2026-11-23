import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/usecases/find_post_it_time_conflicts.dart';

import '../helpers/entities.dart';

void main() {
  const finder = FindPostItTimeConflicts();

  test('detecta evento e tarefa no mesmo horário e dia', () {
    final events = [
      buildPostIt(
        id: 'event',
        type: PostItType.event,
        title: 'Reunião',
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'task',
        title: 'Enviar proposta',
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'other',
        title: 'Outro horário',
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 600,
      ),
    ];

    final conflicts = finder.forDay(events, DateOnly(2026, 11, 24));

    expect(conflicts, hasLength(1));
    expect(conflicts.single.timeMinutes, 540);
    expect(
      conflicts.single.postIts.map((postIt) => postIt.id),
      containsAll(['event', 'task']),
    );
  });

  test('não conflita horários, datas ou estados diferentes', () {
    final postIts = [
      buildPostIt(
        id: 'a',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'b',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 600,
      ),
      buildPostIt(
        id: 'c',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 25),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'done',
        type: PostItType.event,
        status: PostItStatus.done,
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'highlight',
        type: PostItType.event,
        isHighlight: true,
        startDate: DateOnly(2026, 11, 24),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'untimed',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 24),
      ),
    ];

    expect(finder.forDay(postIts, DateOnly(2026, 11, 24)), isEmpty);
  });

  test('evento de vários dias conflita em qualquer dia coberto', () {
    final candidate = buildPostIt(
      id: 'new',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 24),
      endDate: DateOnly(2026, 11, 26),
      timeMinutes: 540,
    );
    final existing = [
      buildPostIt(
        id: 'middle',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 25),
        timeMinutes: 540,
      ),
    ];

    final conflicts = finder.forNewPostIt(candidate, existing);

    expect(conflicts, hasLength(1));
    expect(conflicts.single.date, DateOnly(2026, 11, 25));
  });

  test('série recorrente lista apenas as ocorrências conflitantes', () {
    final candidate = buildPostIt(
      id: 'new',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 2),
      recurrence: EventRecurrence.weekly,
      recurrenceEndDate: DateOnly(2026, 11, 30),
      timeMinutes: 540,
    );
    final existing = [
      buildPostIt(
        id: 'week2',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 9),
        timeMinutes: 540,
      ),
      buildPostIt(
        id: 'week4',
        title: 'Outro horário',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 23),
        timeMinutes: 600,
      ),
    ];

    final conflicts = finder.forNewPostIt(candidate, existing);

    expect(conflicts, hasLength(1));
    expect(conflicts.single.date, DateOnly(2026, 11, 9));
    expect(conflicts.single.postIts.single.id, 'week2');
  });

  test('registro em edição não conflita consigo mesmo', () {
    final current = buildPostIt(
      id: 'same',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 24),
      timeMinutes: 540,
    );
    final candidate = buildPostIt(
      id: 'new',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 24),
      timeMinutes: 540,
    );
    final sameCandidate = buildPostIt(
      id: 'same',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 24),
      timeMinutes: 540,
    );

    expect(finder.forNewPostIt(candidate, [current]), hasLength(1));
    expect(finder.forNewPostIt(sameCandidate, [current]), isEmpty);
  });
}
