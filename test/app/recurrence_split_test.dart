import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test(
    'divide série semanal preservando passado e remapeando futuro',
    () async {
      final dependencies = testDependencies(now: DateTime(2026, 11, 3, 8));
      await dependencies.planner.initialize();
      addTearDown(dependencies.dispose);
      final planner = dependencies.planner;

      final event = await planner.createPostIt(
        title: 'Reunião',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 3),
        recurrence: EventRecurrence.weekly,
        recurrenceEndDate: DateOnly(2026, 12, 31),
      );
      await planner.setEventOccurrenceStatus(
        event,
        DateOnly(2026, 11, 10),
        PostItStatus.done,
      );
      await planner.setEventOccurrenceStatus(
        event,
        DateOnly(2026, 11, 24),
        PostItStatus.cancelled,
      );

      final occurrence = planner
          .postItsOn(DateOnly(2026, 11, 17))
          .singleWhere((postIt) => postIt.id == event.id);
      final segment = await planner.splitRecurringEvent(
        occurrence,
        DateOnly(2026, 11, 18),
      );

      expect(segment, isNotNull);
      final all = planner.postIts;
      expect(all, hasLength(2));
      final head = all.singleWhere((postIt) => postIt.id == event.id);
      expect(head.recurrenceEndDate, DateOnly(2026, 11, 16));
      expect(head.effectiveSeriesId, head.id);
      expect(segment!.effectiveSeriesId, head.id);
      expect(segment.startDate, DateOnly(2026, 11, 18));
      expect(segment.recurrence, EventRecurrence.weekly);
      expect(segment.recurrenceEndDate, DateOnly(2026, 12, 31));

      // Ocorrências anteriores continuam nas terças e com estados antigos.
      expect(
        planner.postItsOn(DateOnly(2026, 11, 10)).single.status,
        PostItStatus.done,
      );
      expect(planner.postItsOn(DateOnly(2026, 11, 17)), isEmpty);

      // Ocorrências futuras passam para as quartas.
      expect(planner.postItsOn(DateOnly(2026, 11, 18)).single.id, segment.id);
      expect(planner.postItsOn(DateOnly(2026, 11, 25)).single.id, segment.id);

      // A ocorrência cancelada de 24/11 era o índice 3; segue o mesmo índice.
      expect(
        planner.postItsOn(DateOnly(2026, 12, 9)).single.status,
        PostItStatus.cancelled,
      );

      final history = await DriftPostItRepository(dependencies.database)
          .loadHistory(head.id);
      expect(
        history.any((entry) => entry.action == PostItHistoryAction.seriesSplit),
        isTrue,
      );
    },
  );

  test(
    'divide série de tarefa recorrente preservando o tipo e o passado',
    () async {
      final dependencies = testDependencies(now: DateTime(2026, 11, 2, 8));
      await dependencies.planner.initialize();
      addTearDown(dependencies.dispose);
      final planner = dependencies.planner;

      final task = await planner.createPostIt(
        title: 'Enviar relatório',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 2),
        recurrence: EventRecurrence.weekly,
        recurrenceEndDate: DateOnly(2026, 12, 31),
      );
      await planner.setPostItStatus(task, PostItStatus.active);
      await planner.setEventOccurrenceStatus(
        task,
        DateOnly(2026, 11, 9),
        PostItStatus.done,
      );
      await planner.setEventOccurrenceStatus(
        task,
        DateOnly(2026, 11, 23),
        PostItStatus.cancelled,
      );

      final occurrence = planner
          .postItsOn(DateOnly(2026, 11, 16))
          .singleWhere((postIt) => postIt.id == task.id);
      expect(occurrence.isEvent, isFalse);
      final segment = await planner.splitRecurringEvent(
        occurrence,
        DateOnly(2026, 11, 17),
      );

      expect(segment, isNotNull);
      final head = planner.postIts.singleWhere((item) => item.id == task.id);
      expect(head.type, PostItType.task);
      expect(head.recurrenceEndDate, DateOnly(2026, 11, 15));
      expect(head.effectiveSeriesId, head.id);
      expect(segment!.type, PostItType.task);
      expect(segment.effectiveSeriesId, head.id);
      expect(segment.startDate, DateOnly(2026, 11, 17));
      expect(segment.recurrence, EventRecurrence.weekly);
      expect(segment.recurrenceEndDate, DateOnly(2026, 12, 31));

      expect(
        planner.postItsOn(DateOnly(2026, 11, 9)).single.status,
        PostItStatus.done,
      );
      expect(planner.postItsOn(DateOnly(2026, 11, 16)), isEmpty);
      expect(planner.postItsOn(DateOnly(2026, 11, 17)).single.id, segment.id);
      expect(planner.postItsOn(DateOnly(2026, 11, 24)).single.id, segment.id);
      expect(
        planner.postItsOn(DateOnly(2026, 12, 8)).single.status,
        PostItStatus.cancelled,
      );
    },
  );

  test('mover a primeira ocorrência desloca a série inteira', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 3, 8));
    await dependencies.planner.initialize();
    addTearDown(dependencies.dispose);
    final planner = dependencies.planner;

    final event = await planner.createPostIt(
      title: 'Reunião',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 3),
      recurrence: EventRecurrence.weekly,
    );
    final occurrence = planner
        .postItsOn(DateOnly(2026, 11, 3))
        .singleWhere((postIt) => postIt.id == event.id);

    final moved = await planner.splitRecurringEvent(
      occurrence,
      DateOnly(2026, 11, 4),
    );

    expect(moved, isNotNull);
    expect(planner.postIts, hasLength(1));
    expect(moved!.startDate, DateOnly(2026, 11, 4));
    expect(planner.postItsOn(DateOnly(2026, 11, 11)).single.id, event.id);
  });
}
