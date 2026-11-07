import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';
import 'package:stick2planner/domain/usecases/ensure_event_completion.dart';

void main() {
  final today = DateOnly(2026, 11, 6);
  final now = DateTime.utc(2026, 11, 6, 12);

  PostIt event({
    String id = 'e1',
    DateOnly? start,
    DateOnly? end,
    PostItStatus status = PostItStatus.active,
  }) => PostIt(
    id: id,
    title: 'Evento',
    type: PostItType.event,
    status: status,
    startDate: start ?? DateOnly(2026, 11, 1),
    endDate: end,
    createdAt: now,
    updatedAt: now,
  );

  EventCompletionPlan run(List<PostIt> postIts) =>
      const EnsureEventCompletion()(
        postIts: postIts,
        today: today,
        now: now,
        idGenerator: () => 'h1',
      );

  test('conclui evento cujo fim já passou', () {
    final plan = run([event(id: 'past', end: DateOnly(2026, 11, 5))]);

    expect(plan.updates.single.id, 'past');
    expect(plan.updates.single.status, PostItStatus.done);
    expect(plan.history.single.action, PostItHistoryAction.eventCompleted);
    expect(plan.history.single.fromValue, 'active');
    expect(plan.history.single.toValue, 'done');
  });

  test('não conclui evento de hoje, futuro, sem fim ou já concluído', () {
    final plan = run([
      event(id: 'today', end: today),
      event(id: 'future', end: DateOnly(2026, 11, 7)),
      event(id: 'single'),
      event(id: 'done', end: DateOnly(2026, 11, 5), status: PostItStatus.done),
    ]);

    expect(plan.hasChanges, isFalse);
  });

  test('execução repetida é idempotente', () {
    final first = run([event(id: 'past', end: DateOnly(2026, 11, 5))]);
    final second = run(first.updates);

    expect(second.hasChanges, isFalse);
  });
}
