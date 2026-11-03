import 'package:drift/native.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/domain/entities/post_it_history.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  group('TO-DO recorrente', () {
    late AppDatabase database;
    late AppDependencies dependencies;
    late DriftPostItRepository repository;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      dependencies = AppDependencies.fromDatabase(
        database,
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      );
      await dependencies.planner.initialize();
      repository = DriftPostItRepository(database);
    });

    tearDown(() => dependencies.dispose());

    test('criado sem data aparece hoje', () async {
      final recurring = await dependencies.planner.createPostIt(
        title: 'Tomar remédio',
        type: PostItType.recurringTodo,
      );

      expect(recurring.startDate, DateOnly(2026, 11, 3));
      expect(recurring.lastRolloverAt, isNotNull);
      expect(
        dependencies.planner.postItsOn(DateOnly(2026, 11, 3)).single.id,
        recurring.id,
      );
      expect(dependencies.planner.isPostponed(recurring), isFalse);
    });

    test('abertura após dias fechado avança direto para hoje', () async {
      await dependencies.planner.savePostIt(
        buildPostIt(
          id: 'rec',
          title: 'Pendência',
          type: PostItType.recurringTodo,
          startDate: DateOnly(2026, 10, 30),
        ),
      );

      final reopened = AppDependencies.fromDatabase(
        database,
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      );
      await reopened.planner.initialize();

      final recurring = reopened.planner.postIts.single;
      expect(recurring.startDate, DateOnly(2026, 11, 3));
      expect(
        recurring.lastRolloverAt,
        DateTime(2026, 11, 3, 9).toUtc(),
      );

      final history = await repository.loadHistory('rec');
      expect(
        history.where(
          (entry) => entry.action == PostItHistoryAction.rolloverAdvanced,
        ),
        hasLength(1),
      );

      reopened.planner.dispose();
      reopened.notes.dispose();
    });

    test('avanço é idempotente', () async {
      await dependencies.planner.savePostIt(
        buildPostIt(
          id: 'rec',
          title: 'Pendência',
          type: PostItType.recurringTodo,
          startDate: DateOnly(2026, 11, 1),
        ),
      );
      await dependencies.planner.ensureRecurringRollover();

      final before = dependencies.planner.postIts.single;
      final historyBefore = await repository.loadHistory('rec');
      await dependencies.planner.ensureRecurringRollover();
      await dependencies.planner.handleAppResumed();

      final after = dependencies.planner.postIts.single;
      expect(after.startDate, DateOnly(2026, 11, 3));
      expect(after.updatedAt, before.updatedAt);
      expect(
        (await repository.loadHistory('rec')).length,
        historyBefore.length,
      );
    });

    test('concluído e cancelado não avançam', () async {
      await dependencies.planner.savePostIt(
        buildPostIt(
          id: 'done',
          title: 'Feita',
          type: PostItType.recurringTodo,
          status: PostItStatus.done,
          startDate: DateOnly(2026, 10, 30),
        ),
      );
      await dependencies.planner.savePostIt(
        buildPostIt(
          id: 'cancelled',
          title: 'Cancelada',
          type: PostItType.recurringTodo,
          status: PostItStatus.cancelled,
          startDate: DateOnly(2026, 10, 30),
        ),
      );

      await dependencies.planner.ensureRecurringRollover();

      final byId = {
        for (final postIt in dependencies.planner.postIts) postIt.id: postIt,
      };
      expect(byId['done']!.startDate, DateOnly(2026, 10, 30));
      expect(byId['cancelled']!.startDate, DateOnly(2026, 10, 30));
    });

    test('adiamento manual para o futuro é preservado e sinalizado', () async {
      final recurring = await dependencies.planner.createPostIt(
        title: 'Pendência',
        type: PostItType.recurringTodo,
      );

      await dependencies.planner.movePostIt(
        recurring,
        DateOnly(2026, 11, 6),
      );

      final postponed = dependencies.planner.postIts.single;
      expect(postponed.startDate, DateOnly(2026, 11, 6));
      expect(dependencies.planner.isPostponed(postponed), isTrue);

      await dependencies.planner.ensureRecurringRollover();
      expect(
        dependencies.planner.postIts.single.startDate,
        DateOnly(2026, 11, 6),
      );

      final history = await repository.loadHistory(recurring.id);
      expect(
        history.map((entry) => entry.action),
        contains(PostItHistoryAction.manualPostponed),
      );
    });

    test('mover recorrente para o passado normaliza para hoje', () async {
      final recurring = await dependencies.planner.createPostIt(
        title: 'Pendência',
        type: PostItType.recurringTodo,
      );

      await dependencies.planner.movePostIt(
        recurring,
        DateOnly(2026, 10, 1),
      );

      expect(
        dependencies.planner.postIts.single.startDate,
        DateOnly(2026, 11, 3),
      );
      expect(
        dependencies.planner.isPostponed(dependencies.planner.postIts.single),
        isFalse,
      );
    });

    test('reabrir recorrente atrasado recarrega para hoje', () async {
      await dependencies.planner.savePostIt(
        buildPostIt(
          id: 'rec',
          title: 'Pendência',
          type: PostItType.recurringTodo,
          status: PostItStatus.done,
          startDate: DateOnly(2026, 10, 30),
        ),
      );

      await dependencies.planner.setPostItStatus(
        dependencies.planner.postIts.single,
        PostItStatus.active,
      );

      final reopened = dependencies.planner.postIts.single;
      expect(reopened.status, PostItStatus.active);
      expect(reopened.startDate, DateOnly(2026, 11, 3));
    });
  });

  group('Estados', () {
    late AppDependencies dependencies;
    late DriftPostItRepository repository;

    setUp(() async {
      dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
      await dependencies.planner.initialize();
      repository = DriftPostItRepository(dependencies.database);
    });

    tearDown(() => dependencies.dispose());

    test('concluir e cancelar preservam o registro e histórico', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 3),
      );

      await dependencies.planner.setPostItStatus(task, PostItStatus.done);
      await dependencies.planner.setPostItStatus(
        dependencies.planner.postIts.single,
        PostItStatus.cancelled,
      );

      final current = dependencies.planner.postIts.single;
      expect(current.id, task.id);
      expect(current.status, PostItStatus.cancelled);
      expect(current.title, 'Tarefa');
      expect(await repository.loadAll(), hasLength(1));

      final history = await repository.loadHistory(task.id);
      expect(
        history.where(
          (entry) => entry.action == PostItHistoryAction.statusChanged,
        ),
        hasLength(2),
      );
    });

    test('reabrir tarefa mantém dados e a torna ativa', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 3),
      );
      await dependencies.planner.setPostItStatus(task, PostItStatus.done);
      await dependencies.planner.setPostItStatus(
        dependencies.planner.postIts.single,
        PostItStatus.active,
      );

      expect(
        dependencies.planner.postIts.single.status,
        PostItStatus.active,
      );
      expect(dependencies.planner.postIts.single.title, 'Tarefa');
    });

    test('trocar estado não altera data nem ordem', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );

      await dependencies.planner.setPostItStatus(task, PostItStatus.done);

      final current = dependencies.planner.postIts.single;
      expect(current.startDate, DateOnly(2026, 11, 4));
      expect(current.sortOrder, task.sortOrder);
    });

    test('estado persiste após reabrir', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Persistente',
        type: PostItType.task,
      );
      await dependencies.planner.setPostItStatus(task, PostItStatus.done);

      final reopened = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      );
      await reopened.planner.initialize();

      expect(
        reopened.planner.postIts.single.status,
        PostItStatus.done,
      );
      expect(
        reopened.planner.postIts.single.title,
        'Persistente',
      );

      reopened.planner.dispose();
      reopened.notes.dispose();
    });
  });
}
