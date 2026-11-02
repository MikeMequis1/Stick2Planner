import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/app/controllers/planner_controller.dart';
import 'package:flutter_schedule/app/planner_view_mode.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/domain/usecases/validate_post_it.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  group('PlannerController', () {
    late AppDependencies dependencies;
    late PlannerController controller;

    setUp(() {
      dependencies = testDependencies(now: DateTime(2026, 10, 31, 12));
      controller = dependencies.planner;
    });

    tearDown(() => dependencies.dispose());

    test('inicializa com data local, modos padrão e sem post-its', () async {
      await controller.initialize();

      expect(controller.isLoading, isFalse);
      expect(controller.selectedDate, DateOnly(2026, 10, 31));
      expect(controller.portraitMode, AgendaViewMode.day);
      expect(controller.landscapeMode, AgendaViewMode.week);
      expect(controller.postIts, isEmpty);
      expect(controller.error, isNull);
    });

    test('persiste modo de visualização por orientação', () async {
      await controller.initialize();
      await controller.setMode(AgendaViewMode.fourDays, Orientation.portrait);
      await controller.setMode(AgendaViewMode.twoWeeks, Orientation.landscape);

      final reloaded = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 10, 31, 12)),
      );
      await reloaded.planner.initialize();

      expect(reloaded.planner.portraitMode, AgendaViewMode.fourDays);
      expect(reloaded.planner.landscapeMode, AgendaViewMode.twoWeeks);

      reloaded.planner.dispose();
      reloaded.notes.dispose();
    });

    test('persiste data selecionada', () async {
      await controller.initialize();
      await controller.selectDate(DateOnly(2026, 11, 15));

      final reloaded = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 10, 31, 12)),
      );
      await reloaded.planner.initialize();

      expect(reloaded.planner.selectedDate, DateOnly(2026, 11, 15));

      reloaded.planner.dispose();
      reloaded.notes.dispose();
    });

    test('evento multi-dia aparece em todos os dias cobertos', () async {
      await controller.initialize();
      await controller.savePostIt(
        buildPostIt(
          id: 'evento',
          title: 'Viagem',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 2),
          endDate: DateOnly(2026, 11, 5),
        ),
      );
      await controller.savePostIt(
        buildPostIt(
          id: 'tarefa',
          title: 'Compras',
          startDate: DateOnly(2026, 11, 3),
        ),
      );
      await controller.savePostIt(
        buildPostIt(id: 'sem-data', title: 'Ideia'),
      );

      expect(
        controller.postItsOn(DateOnly(2026, 11, 4)).map((item) => item.id),
        ['evento'],
      );
      expect(
        controller.postItsOn(DateOnly(2026, 11, 3)).map((item) => item.id),
        ['evento', 'tarefa'],
      );
      expect(controller.undatedPostIts.map((item) => item.id), ['sem-data']);
    });

    test('conta post-its por estado', () async {
      await controller.initialize();
      await controller.savePostIt(buildPostIt(id: 'a'));
      await controller.savePostIt(
        buildPostIt(id: 'b', status: PostItStatus.done),
      );
      await controller.savePostIt(
        buildPostIt(id: 'c', status: PostItStatus.cancelled),
      );

      expect(controller.countByStatus(PostItStatus.active), 1);
      expect(controller.countByStatus(PostItStatus.done), 1);
      expect(controller.countByStatus(PostItStatus.cancelled), 1);
    });

    test('recusa evento sem data e não persiste', () async {
      await controller.initialize();

      await expectLater(
        controller.savePostIt(
          buildPostIt(type: PostItType.event, title: 'Sem data'),
        ),
        throwsA(isA<PostItValidationException>()),
      );
      expect(controller.postIts, isEmpty);
    });

    test('NotesController carrega notas persistidas', () async {
      final noteRepository = DriftNoteRepository(dependencies.database);
      await noteRepository.save(buildNote(id: 'n1'));

      await dependencies.notes.initialize();

      expect(dependencies.notes.notes.map((note) => note.id), ['n1']);
      expect(dependencies.notes.error, isNull);
    });

    test('modos disponíveis dependem da orientação', () {
      expect(plannerModesFor(Orientation.portrait), [
        AgendaViewMode.day,
        AgendaViewMode.fourDays,
        AgendaViewMode.week,
      ]);
      expect(plannerModesFor(Orientation.landscape), [
        AgendaViewMode.week,
        AgendaViewMode.twoWeeks,
        AgendaViewMode.month,
      ]);
      expect(AppStrings.viewModeMonth, 'Mês');
    });
  });
}
