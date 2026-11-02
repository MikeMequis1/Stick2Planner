import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/domain/entities/post_it_history.dart';
import 'package:flutter_schedule/domain/usecases/validate_post_it.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  group('PlannerController — criação e edição', () {
    late AppDependencies dependencies;
    late DriftPostItRepository repository;

    setUp(() async {
      dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
      await dependencies.planner.initialize();
      repository = DriftPostItRepository(dependencies.database);
    });

    tearDown(() => dependencies.dispose());

    test('cria tarefa simples e tarefa sem data', () async {
      final dated = await dependencies.planner.createPostIt(
        title: '  Comprar pão  ',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final undated = await dependencies.planner.createPostIt(
        title: 'Ideia',
        type: PostItType.task,
      );

      expect(dated.title, 'Comprar pão');
      expect(dated.startDate, DateOnly(2026, 11, 4));
      expect(dated.endDate, isNull);
      expect(undated.startDate, isNull);
      expect(dependencies.planner.postIts, hasLength(2));
      expect(dependencies.planner.undatedPostIts.single.id, undated.id);
    });

    test('propriedades de evento não contaminam tarefa', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        isHighlight: true,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 7),
      );

      expect(task.isHighlight, isFalse);
      expect(task.endDate, isNull);
      expect(task.durationInDays, 1);
    });

    test('cria evento marcante com intervalo', () async {
      final event = await dependencies.planner.createPostIt(
        title: 'Aniversário',
        type: PostItType.event,
        isHighlight: true,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
      );

      expect(event.type, PostItType.event);
      expect(event.isHighlight, isTrue);
      expect(event.durationInDays, 3);
      expect(event.endDate, DateOnly(2026, 11, 6));
    });

    test('evento sem data é recusado e nada é persistido', () async {
      await expectLater(
        dependencies.planner.createPostIt(
          title: 'Sem data',
          type: PostItType.event,
        ),
        throwsA(isA<PostItValidationException>()),
      );

      expect(dependencies.planner.postIts, isEmpty);
      expect(await repository.loadAll(), isEmpty);
    });

    test('edição preserva estado, vínculo e histórico', () async {
      final noteRepository = DriftNoteRepository(dependencies.database);
      await noteRepository.save(buildNote(id: 'nota-1'));
      final original = buildPostIt(
        id: 'p1',
        title: 'Original',
        noteId: 'nota-1',
        noteExcerpt: 'trecho',
        status: PostItStatus.done,
        startDate: DateOnly(2026, 11, 4),
      );
      await dependencies.planner.savePostIt(original);

      await dependencies.planner.updatePostIt(
        original,
        title: 'Editado',
        type: PostItType.task,
        details: 'detalhes',
        startDate: DateOnly(2026, 11, 5),
      );

      final updated = dependencies.planner.postIts.single;
      expect(updated.id, 'p1');
      expect(updated.title, 'Editado');
      expect(updated.details, 'detalhes');
      expect(updated.status, PostItStatus.done);
      expect(updated.noteId, 'nota-1');
      expect(updated.noteExcerpt, 'trecho');
      expect(updated.startDate, DateOnly(2026, 11, 5));

      final history = await repository.loadHistory('p1');
      expect(
        history.map((entry) => entry.action),
        contains(PostItHistoryAction.updated),
      );
    });

    test('exclusão é lógica e preserva histórico', () async {
      final postIt = await dependencies.planner.createPostIt(
        title: 'Descartável',
        type: PostItType.task,
      );

      await dependencies.planner.deletePostIt(postIt);

      expect(dependencies.planner.postIts, isEmpty);
      final deleted = await repository.loadAll(includeDeleted: true);
      expect(deleted.single.id, postIt.id);
      expect(deleted.single.deletedAt, isNotNull);
      final history = await repository.loadHistory(postIt.id);
      expect(
        history.map((entry) => entry.action),
        contains(PostItHistoryAction.deleted),
      );
    });
  });

  group('PlannerController — movimentação e redimensionamento', () {
    late AppDependencies dependencies;
    late DriftPostItRepository repository;

    setUp(() async {
      dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
      await dependencies.planner.initialize();
      repository = DriftPostItRepository(dependencies.database);
    });

    tearDown(() => dependencies.dispose());

    test('move tarefa entre dias preservando identidade', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );

      await dependencies.planner.movePostIt(task, DateOnly(2026, 11, 6));

      final moved = dependencies.planner.postIts.single;
      expect(moved.id, task.id);
      expect(moved.startDate, DateOnly(2026, 11, 6));
      expect(moved.status, PostItStatus.active);

      final history = await repository.loadHistory(task.id);
      expect(
        history.map((entry) => entry.action),
        contains(PostItHistoryAction.moved),
      );
    });

    test('mover evento preserva duração e cruza mês', () async {
      final event = await dependencies.planner.createPostIt(
        title: 'Viagem',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 28),
        endDate: DateOnly(2026, 12, 1),
      );

      await dependencies.planner.movePostIt(event, DateOnly(2026, 12, 30));

      final moved = dependencies.planner.postIts.single;
      expect(moved.id, event.id);
      expect(moved.startDate, DateOnly(2026, 12, 30));
      expect(moved.endDate, DateOnly(2027, 1, 2));
      expect(moved.durationInDays, 4);
    });

    test('redimensiona início e fim com clamp', () async {
      final event = await dependencies.planner.createPostIt(
        title: 'Evento',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
      );

      await dependencies.planner.resizeEvent(
        event,
        startDate: DateOnly(2026, 11, 2),
        endDate: DateOnly(2026, 11, 6),
      );
      var updated = dependencies.planner.postIts.single;
      expect(updated.startDate, DateOnly(2026, 11, 2));
      expect(updated.durationInDays, 5);

      await dependencies.planner.resizeEvent(
        updated,
        startDate: DateOnly(2026, 11, 2),
        endDate: DateOnly(2026, 11, 1),
      );
      updated = dependencies.planner.postIts.single;
      expect(updated.endDate, isNull);
      expect(updated.durationInDays, 1);

      final history = await repository.loadHistory(event.id);
      expect(
        history.where(
          (entry) => entry.action == PostItHistoryAction.resized,
        ),
        hasLength(2),
      );
    });

    test('mover reorganiza origem e destino na mesma transação', () async {
      final first = await dependencies.planner.createPostIt(
        title: 'A',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final second = await dependencies.planner.createPostIt(
        title: 'B',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final target = await dependencies.planner.createPostIt(
        title: 'C',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 6),
      );

      await dependencies.planner.movePostIt(first, DateOnly(2026, 11, 6));

      final items = dependencies.planner.postIts;
      final sourceDay = items
          .where((postIt) => postIt.startDate == DateOnly(2026, 11, 4))
          .toList();
      final targetDay = items
          .where((postIt) => postIt.startDate == DateOnly(2026, 11, 6))
          .toList();
      expect(sourceDay.single.id, second.id);
      expect(sourceDay.single.sortOrder, 0);
      expect(targetDay.map((postIt) => postIt.id), [target.id, first.id]);
      expect(targetDay.map((postIt) => postIt.sortOrder), [0, 1]);
    });

    test('redimensiona evento atravessando virada de mês', () async {
      final event = await dependencies.planner.createPostIt(
        title: 'Evento',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 29),
        endDate: DateOnly(2026, 12, 1),
      );

      await dependencies.planner.resizeEvent(
        event,
        startDate: DateOnly(2026, 11, 28),
        endDate: DateOnly(2026, 12, 3),
      );

      final updated = dependencies.planner.postIts.single;
      expect(updated.startDate, DateOnly(2026, 11, 28));
      expect(updated.endDate, DateOnly(2026, 12, 3));
      expect(updated.durationInDays, 6);
    });

    test('redimensionar tarefa falha sem alterar memória', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );

      await expectLater(
        dependencies.planner.resizeEvent(
          task,
          startDate: DateOnly(2026, 11, 3),
          endDate: DateOnly(2026, 11, 5),
        ),
        throwsArgumentError,
      );

      expect(dependencies.planner.postIts.single.startDate, task.startDate);
    });

    test('reordena no mesmo dia e persiste após reabrir', () async {
      final first = await dependencies.planner.createPostIt(
        title: 'Primeira',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      await dependencies.planner.createPostIt(
        title: 'Segunda',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final third = await dependencies.planner.createPostIt(
        title: 'Terceira',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );

      await dependencies.planner.movePostItUp(third);
      await dependencies.planner.movePostItDown(first);

      final ordered = dependencies.planner.postIts
          .where((postIt) => postIt.startDate == DateOnly(2026, 11, 4))
          .toList();
      expect(ordered.map((postIt) => postIt.title), [
        'Terceira',
        'Primeira',
        'Segunda',
      ]);

      final reloaded = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 11, 4, 12)),
      );
      await reloaded.planner.initialize();
      expect(
        reloaded.planner.postIts.map((postIt) => postIt.title),
        ['Terceira', 'Primeira', 'Segunda'],
      );
      expect(
        reloaded.planner.postIts.map((postIt) => postIt.sortOrder),
        [0, 1, 2],
      );
      reloaded.planner.dispose();
      reloaded.notes.dispose();
    });

    test('operações rápidas são serializadas e não duplicam', () async {
      final first = await dependencies.planner.createPostIt(
        title: 'A',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final second = await dependencies.planner.createPostIt(
        title: 'B',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );

      await Future.wait([
        dependencies.planner.movePostIt(first, DateOnly(2026, 11, 5)),
        dependencies.planner.movePostIt(second, DateOnly(2026, 11, 6)),
        dependencies.planner.movePostIt(first, DateOnly(2026, 11, 7)),
      ]);

      final items = dependencies.planner.postIts;
      expect(items, hasLength(2));
      expect(
        items.singleWhere((postIt) => postIt.id == first.id).startDate,
        DateOnly(2026, 11, 7),
      );
      expect(
        items.singleWhere((postIt) => postIt.id == second.id).startDate,
        DateOnly(2026, 11, 6),
      );
      expect(items.map((postIt) => postIt.id).toSet(), {
        first.id,
        second.id,
      });
    });

    test('mover para o mesmo dia sem índice é no-op', () async {
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        startDate: DateOnly(2026, 11, 4),
      );
      final before = dependencies.planner.postIts.single.updatedAt;

      await dependencies.planner.movePostIt(task, DateOnly(2026, 11, 4));

      expect(dependencies.planner.postIts.single.updatedAt, before);
    });
  });
}
