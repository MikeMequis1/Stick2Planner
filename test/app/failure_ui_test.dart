import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
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
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/entities.dart';
import '../helpers/failing_repository.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpWithFailingRepository(
    WidgetTester tester, {
    PostIt? seed,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    final realRepository = DriftPostItRepository(database);
    if (seed != null) await realRepository.save(seed);

    final failing = FailingPostItRepository(realRepository);
    final dependencies = AppDependencies(
      database: database,
      planner: PlannerController(
        postItRepository: failing,
        settingsRepository: DriftSettingsRepository(database),
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      ),
      notes: NotesController(
        noteRepository: DriftNoteRepository(database),
      ),
    );
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(AppStrings.appName), findsOneWidget);
    return dependencies;
  }

  testWidgets('falha ao mover mostra erro e mantém a data persistida', (
    tester,
  ) async {
    final dependencies = await pumpWithFailingRepository(
      tester,
      seed: buildPostIt(
        id: 't1',
        title: 'Arrastar',
        startDate: DateOnly(2026, 11, 3),
      ),
    );

    final source = find.byKey(const Key('post-it-t1'));
    final target = find.byKey(const Key('day-2026-11-05'));

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(AppStrings.errorMove), findsOneWidget);
    expect(dependencies.planner.postIts.single.startDate, DateOnly(2026, 11, 3));
    expect(
      find.descendant(
        of: find.byKey(const Key('day-2026-11-03')),
        matching: find.byKey(const Key('post-it-t1')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('falha ao salvar mantém formulário e mostra erro', (tester) async {
    await pumpWithFailingRepository(tester);

    await tester.tap(find.byKey(const Key('add-post-it')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('editor-title')),
      'Não salvar',
    );
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(AppStrings.errorSave), findsOneWidget);
    expect(find.text(AppStrings.newPostIt), findsWidgets);
    expect(find.byKey(const Key('editor-title')), findsOneWidget);
  });
}
