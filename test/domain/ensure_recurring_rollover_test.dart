import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/domain/entities/post_it_history.dart';
import 'package:flutter_schedule/domain/usecases/ensure_recurring_rollover.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';

void main() {
  const rollover = EnsureRecurringRollover();
  var sequence = 0;
  String idGenerator() => 'history-${sequence++}';

  setUp(() => sequence = 0);

  group('EnsureRecurringRollover', () {
    test('avança pendente sem data para hoje', () {
      final pending = buildPostIt(
        id: 'rec-1',
        type: PostItType.recurringTodo,
      );

      final plan = rollover(
        postIts: [pending],
        today: DateOnly(2026, 11, 3),
        now: DateTime.utc(2026, 11, 3, 9),
        idGenerator: idGenerator,
      );

      expect(plan.updates, hasLength(1));
      expect(plan.updates.single.startDate, DateOnly(2026, 11, 3));
      expect(plan.updates.single.lastRolloverAt, DateTime.utc(2026, 11, 3, 9));
      expect(plan.updates.single.id, 'rec-1');
      expect(plan.history.single.action, PostItHistoryAction.rolloverAdvanced);
      expect(plan.history.single.fromValue, isNull);
      expect(plan.history.single.toValue, '2026-11-03');
    });

    test('avança atrasado direto para hoje, não dia a dia', () {
      final pending = buildPostIt(
        id: 'rec-1',
        type: PostItType.recurringTodo,
        startDate: DateOnly(2026, 10, 30),
      );

      final plan = rollover(
        postIts: [pending],
        today: DateOnly(2026, 11, 3),
        now: DateTime.utc(2026, 11, 3, 12),
        idGenerator: idGenerator,
      );

      expect(plan.updates.single.startDate, DateOnly(2026, 11, 3));
      expect(plan.updates.single.durationInDays, 1);
      expect(plan.history.single.fromValue, '2026-10-30');
    });

    test('não avança data futura adiada manualmente', () {
      final postponed = buildPostIt(
        id: 'rec-1',
        type: PostItType.recurringTodo,
        startDate: DateOnly(2026, 11, 6),
      );

      final plan = rollover(
        postIts: [postponed],
        today: DateOnly(2026, 11, 3),
        now: DateTime.utc(2026, 11, 3, 12),
        idGenerator: idGenerator,
      );

      expect(plan.hasChanges, isFalse);
    });

    test('concluído ou cancelado não avança', () {
      final done = buildPostIt(
        id: 'done',
        type: PostItType.recurringTodo,
        status: PostItStatus.done,
        startDate: DateOnly(2026, 10, 1),
      );
      final cancelled = buildPostIt(
        id: 'cancelled',
        type: PostItType.recurringTodo,
        status: PostItStatus.cancelled,
        startDate: DateOnly(2026, 10, 1),
      );

      final plan = rollover(
        postIts: [done, cancelled],
        today: DateOnly(2026, 11, 3),
        now: DateTime.utc(2026, 11, 3, 12),
        idGenerator: idGenerator,
      );

      expect(plan.hasChanges, isFalse);
    });

    test('executar novamente não duplica nem altera', () {
      final pending = buildPostIt(
        id: 'rec-1',
        type: PostItType.recurringTodo,
        startDate: DateOnly(2026, 10, 30),
      );
      final today = DateOnly(2026, 11, 3);
      final now = DateTime.utc(2026, 11, 3, 12);

      final first = rollover(
        postIts: [pending],
        today: today,
        now: now,
        idGenerator: idGenerator,
      );
      final second = rollover(
        postIts: first.updates,
        today: today,
        now: now,
        idGenerator: idGenerator,
      );

      expect(first.updates, hasLength(1));
      expect(second.hasChanges, isFalse);
    });

    test('preserva título, detalhes e vínculo de nota', () {
      final pending = buildPostIt(
        id: 'rec-1',
        title: 'Tomar remédio',
        type: PostItType.recurringTodo,
        details: 'Após o café',
        noteId: 'nota-1',
        noteExcerpt: 'Trecho',
        startDate: DateOnly(2026, 10, 1),
      );

      final plan = rollover(
        postIts: [pending],
        today: DateOnly(2026, 11, 3),
        now: DateTime.utc(2026, 11, 3, 12),
        idGenerator: idGenerator,
      );

      final updated = plan.updates.single;
      expect(updated.title, 'Tomar remédio');
      expect(updated.details, 'Após o café');
      expect(updated.noteId, 'nota-1');
      expect(updated.noteExcerpt, 'Trecho');
      expect(updated.id, 'rec-1');
    });
  });
}
