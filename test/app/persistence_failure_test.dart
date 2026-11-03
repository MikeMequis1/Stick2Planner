import 'package:drift/native.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/app/controllers/notes_controller.dart';
import 'package:flutter_schedule/app/controllers/planner_controller.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_settings_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';
import '../helpers/failing_repository.dart';
import '../helpers/test_dependencies.dart';

void main() {
  group('Falhas de persistência', () {
    late AppDatabase database;
    late DriftPostItRepository realRepository;
    late FailingPostItRepository failingRepository;
    late AppDependencies dependencies;

    AppDependencies buildDependencies() {
      return AppDependencies(
        database: database,
        planner: PlannerController(
          postItRepository: failingRepository,
          settingsRepository: DriftSettingsRepository(database),
          clock: FixedClock(DateTime(2026, 11, 3, 9)),
        ),
        notes: NotesController(
          noteRepository: DriftNoteRepository(database),
        ),
      );
    }

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      realRepository = DriftPostItRepository(database);
      failingRepository = FailingPostItRepository(realRepository);
      dependencies = buildDependencies();
      await dependencies.planner.initialize();
    });

    tearDown(() => dependencies.dispose());

    test('criação falha sem alterar memória nem banco', () async {
      await expectLater(
        dependencies.planner.createPostIt(
          title: 'Nova',
          type: PostItType.task,
          startDate: DateOnly(2026, 11, 3),
        ),
        throwsA(isA<StateError>()),
      );

      expect(dependencies.planner.postIts, isEmpty);
      expect(await realRepository.loadAll(), isEmpty);
      expect(failingRepository.writeAttempts, 1);
    });

    test('edição falha sem alterar memória nem banco', () async {
      final task = buildPostIt(
        id: 't1',
        title: 'Original',
        startDate: DateOnly(2026, 11, 3),
      );
      await realRepository.save(task);
      await dependencies.planner.refresh();

      await expectLater(
        dependencies.planner.updatePostIt(
          task,
          title: 'Alterada',
          type: PostItType.task,
          startDate: DateOnly(2026, 11, 4),
        ),
        throwsA(isA<StateError>()),
      );

      expect(dependencies.planner.postIts.single.title, 'Original');
      expect(dependencies.planner.postIts.single.startDate, DateOnly(2026, 11, 3));
      final persisted = await realRepository.findById('t1');
      expect(persisted!.title, 'Original');
      expect(persisted.startDate, DateOnly(2026, 11, 3));
    });

    test('movimentação falha sem alterar datas nem ordem', () async {
      final first = buildPostIt(
        id: 't1',
        title: 'A',
        startDate: DateOnly(2026, 11, 3),
        sortOrder: 0,
      );
      final second = buildPostIt(
        id: 't2',
        title: 'B',
        startDate: DateOnly(2026, 11, 3),
        sortOrder: 1,
      );
      await realRepository.saveBatch([first, second]);
      await dependencies.planner.refresh();

      await expectLater(
        dependencies.planner.movePostIt(first, DateOnly(2026, 11, 5)),
        throwsA(isA<StateError>()),
      );

      final byId = {
        for (final postIt in dependencies.planner.postIts) postIt.id: postIt,
      };
      expect(byId['t1']!.startDate, DateOnly(2026, 11, 3));
      expect(byId['t2']!.startDate, DateOnly(2026, 11, 3));
      expect(byId['t2']!.sortOrder, 1);
      expect(
        (await realRepository.findById('t1'))!.startDate,
        DateOnly(2026, 11, 3),
      );
    });

    test('redimensionamento falha sem alterar intervalo', () async {
      final event = buildPostIt(
        id: 'e1',
        title: 'Evento',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 3),
        endDate: DateOnly(2026, 11, 5),
      );
      await realRepository.save(event);
      await dependencies.planner.refresh();

      await expectLater(
        dependencies.planner.resizeEvent(
          event,
          startDate: DateOnly(2026, 11, 2),
          endDate: DateOnly(2026, 11, 6),
        ),
        throwsA(isA<StateError>()),
      );

      final current = dependencies.planner.postIts.single;
      expect(current.startDate, DateOnly(2026, 11, 3));
      expect(current.endDate, DateOnly(2026, 11, 5));
      final persisted = await realRepository.findById('e1');
      expect(persisted!.startDate, DateOnly(2026, 11, 3));
      expect(persisted.endDate, DateOnly(2026, 11, 5));
    });

    test('reordenação falha sem alterar ordem', () async {
      final first = buildPostIt(
        id: 't1',
        title: 'A',
        startDate: DateOnly(2026, 11, 3),
        sortOrder: 0,
      );
      final second = buildPostIt(
        id: 't2',
        title: 'B',
        startDate: DateOnly(2026, 11, 3),
        sortOrder: 1,
      );
      await realRepository.saveBatch([first, second]);
      await dependencies.planner.refresh();

      await expectLater(
        dependencies.planner.movePostItUp(second),
        throwsA(isA<StateError>()),
      );

      final ordered = dependencies.planner.postIts
          .where((postIt) => postIt.startDate == DateOnly(2026, 11, 3))
          .toList();
      expect(ordered.map((postIt) => postIt.id), ['t1', 't2']);
      expect(ordered.map((postIt) => postIt.sortOrder), [0, 1]);
    });

    test('exclusão falha sem remover da memória nem do banco', () async {
      final task = buildPostIt(
        id: 't1',
        title: 'Excluir',
        startDate: DateOnly(2026, 11, 3),
      );
      await realRepository.save(task);
      await dependencies.planner.refresh();

      await expectLater(
        dependencies.planner.deletePostIt(task),
        throwsA(isA<StateError>()),
      );

      expect(dependencies.planner.postIts.single.id, 't1');
      expect(
        await realRepository.loadAll(includeDeleted: true),
        hasLength(1),
      );
      expect(
        (await realRepository.loadAll(includeDeleted: true)).single.deletedAt,
        isNull,
      );
    });
  });
}
