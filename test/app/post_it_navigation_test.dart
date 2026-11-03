import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/app/controllers/app_navigation_controller.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/domain/entities/note.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/features/planner/widgets/post_it_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpApp(
    WidgetTester tester, {
    Future<void> Function(AppDependencies dependencies)? prepare,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
    await dependencies.initialize();
    if (prepare != null) await prepare(dependencies);
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> openSection(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre na Agenda pelo post-it vinculado à nota inteira', (
    tester,
  ) async {
    late PostIt task;
    late Note note;
    final dependencies = await pumpApp(
      tester,
      prepare: (dependencies) async {
        task = await dependencies.planner.createPostIt(
          title: 'Tarefa vinculada',
          type: PostItType.task,
          startDate: DateOnly(2026, 11, 5),
        );
        note = await dependencies.notes.createNote(
          title: 'Nota vinculada',
          type: NoteType.text,
          markdown: 'Conteúdo da nota',
        );
        await dependencies.planner.linkNote(task, note);
      },
    );

    await openSection(tester, AppStrings.notes);
    await tester.tap(find.text(note.title));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('note-linked-postit-${task.id}')));
    await tester.pumpAndSettle();

    expect(dependencies.navigation.section, AppSection.agenda);
    expect(dependencies.planner.postIts, hasLength(1));
    expect(find.text(task.title), findsWidgets);
    expect(find.text(AppStrings.linkedNoteChip), findsOneWidget);
  });

  testWidgets('abre na Agenda pelo snapshot de trecho', (tester) async {
    late PostIt snapshot;
    late Note note;
    final dependencies = await pumpApp(
      tester,
      prepare: (dependencies) async {
        note = await dependencies.notes.createNote(
          title: 'Nota com trecho',
          type: NoteType.text,
          markdown: 'Trecho original',
        );
        snapshot = await dependencies.planner.createPostIt(
          title: 'Trecho copiado',
          type: PostItType.task,
          noteExcerpt: 'Trecho original',
          sourceNoteId: note.id,
        );
      },
    );

    await openSection(tester, AppStrings.notes);
    await tester.tap(find.text(note.title));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('note-snapshot-${snapshot.id}')));
    await tester.pumpAndSettle();

    expect(dependencies.navigation.section, AppSection.agenda);
    expect(dependencies.planner.postIts, hasLength(1));
    expect(find.text(snapshot.title), findsWidgets);
    expect(find.text(AppStrings.noteExcerptChip), findsWidgets);
  });

  testWidgets('post-it ausente mostra aviso sem navegar', (tester) async {
    final dependencies = await pumpApp(tester);
    final context = tester.element(find.byType(Scaffold).first);

    unawaited(
      openPostItDetailsById(context, postItId: 'post-it-inexistente'),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.postItNotFound), findsOneWidget);
    expect(dependencies.navigation.section, AppSection.agenda);
    expect(dependencies.planner.postIts, isEmpty);
  });

  testWidgets('Caixinha oferece Abrir na Agenda somente com data', (
    tester,
  ) async {
    late PostIt dated;
    late PostIt undated;
    final dependencies = await pumpApp(
      tester,
      prepare: (dependencies) async {
        dated = await dependencies.planner.createPostIt(
          title: 'Com data',
          type: PostItType.task,
          startDate: DateOnly(2026, 11, 5),
        );
        undated = await dependencies.planner.createPostIt(
          title: 'Sem data',
          type: PostItType.task,
        );
      },
    );

    await openSection(tester, AppStrings.inbox);

    await tester.tap(find.byKey(Key('inbox-menu-${dated.id}')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.openInAgenda), findsOneWidget);
    expect(find.text(AppStrings.statusDoneAction), findsOneWidget);
    expect(find.text(AppStrings.statusCancelAction), findsOneWidget);
    await tester.tap(find.text(AppStrings.openInAgenda));
    await tester.pumpAndSettle();

    expect(dependencies.navigation.section, AppSection.agenda);
    expect(find.text(dated.title), findsWidgets);
    expect(dependencies.planner.postIts, hasLength(2));

    Navigator.of(tester.element(find.text(dated.title).last)).pop();
    await tester.pumpAndSettle();

    await openSection(tester, AppStrings.inbox);
    await tester.tap(find.byKey(Key('inbox-menu-${undated.id}')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.openInAgenda), findsNothing);
    expect(find.text(AppStrings.statusDoneAction), findsOneWidget);
  });
}
