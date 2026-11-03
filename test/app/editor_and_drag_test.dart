import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpPlanner(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    List<PostIt> postIts = const [],
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
    await dependencies.initialize();
    for (final postIt in postIts) {
      await dependencies.planner.savePostIt(postIt);
    }
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('add-post-it')));
    await tester.pumpAndSettle();
  }

  Future<void> openDetails(WidgetTester tester, String id) async {
    await tester.tap(find.byKey(Key('post-it-$id')));
    await tester.pumpAndSettle();
  }

  testWidgets('cria tarefa detalhada pelo formulário', (tester) async {
    final dependencies = await pumpPlanner(tester);

    await openEditor(tester);
    expect(find.text(AppStrings.newPostIt), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('editor-title')),
      'Comprar pão',
    );
    await tester.enterText(
      find.byKey(const Key('editor-details')),
      'Levar a sacola reutilizável',
    );
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts, hasLength(1));
    final created = dependencies.planner.postIts.single;
    expect(created.title, 'Comprar pão');
    expect(created.details, 'Levar a sacola reutilizável');
    expect(created.type, PostItType.task);
    expect(created.startDate, DateOnly(2026, 11, 4));
    expect(find.text('Comprar pão'), findsOneWidget);
  });

  testWidgets('cria evento marcante com intervalo', (tester) async {
    final dependencies = await pumpPlanner(tester);

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('editor-title')),
      'Aniversário',
    );
    await tester.tap(find.text(AppStrings.eventType));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.fieldHighlight));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.type, PostItType.event);
    expect(event.isHighlight, isTrue);
    expect(event.startDate, DateOnly(2026, 11, 4));
  });

  testWidgets('mostra mensagem para título vazio', (tester) async {
    final dependencies = await pumpPlanner(tester);

    await openEditor(tester);
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.errorTitleEmpty), findsOneWidget);
    expect(dependencies.planner.postIts, isEmpty);
    expect(find.text(AppStrings.newPostIt), findsWidgets);
  });

  testWidgets('edita título existente', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Título antigo',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    await openDetails(tester, 't1');
    await tester.ensureVisible(find.byKey(const Key('details-edit')));
    await tester.tap(find.byKey(const Key('details-edit')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('editor-title')),
      'Título novo',
    );
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts.single.title, 'Título novo');
    expect(find.text('Título novo'), findsOneWidget);
  });

  testWidgets('exclui com confirmação', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Descartável',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    await openDetails(tester, 't1');
    await tester.ensureVisible(find.byKey(const Key('details-delete')));
    await tester.tap(find.byKey(const Key('details-delete')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.deleting), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts, isEmpty);
    expect(find.text('Descartável'), findsNothing);
  });

  testWidgets('arrasta tarefa entre dias e persiste', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Arrastar',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    final source = find.byKey(const Key('post-it-t1'));
    final target = find.byKey(const Key('day-2026-11-06'));

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts.single.startDate, DateOnly(2026, 11, 6));
    expect(
      find.descendant(
        of: target,
        matching: find.byKey(const Key('post-it-t1')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('arrasta post-it sobre outro para reordenar', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Primeira',
          startDate: DateOnly(2026, 11, 4),
          sortOrder: 0,
        ),
        buildPostIt(
          id: 't2',
          title: 'Segunda',
          startDate: DateOnly(2026, 11, 4),
          sortOrder: 1,
        ),
      ],
    );

    final source = find.byKey(const Key('post-it-t2'));
    final target = find.byKey(const Key('post-it-t1'));

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final tasks = dependencies.planner.postIts
        .where((postIt) => postIt.startDate == DateOnly(2026, 11, 4))
        .toList();
    expect(tasks.map((postIt) => postIt.id), ['t2', 't1']);
    expect(tasks.map((postIt) => postIt.sortOrder), [0, 1]);
  });

  testWidgets('arrasta evento preservando a duração', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    final source = find.byKey(const ValueKey('event-bar-e1-2026-11-02'));
    final target = find.byKey(const Key('day-2026-11-07'));

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.id, 'e1');
    expect(event.startDate, DateOnly(2026, 11, 7));
    expect(event.endDate, DateOnly(2026, 11, 9));
    expect(event.durationInDays, 3);
  });

  testWidgets('reordena pela alternativa acessível no detalhe', (
    tester,
  ) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Primeira',
          startDate: DateOnly(2026, 11, 4),
          sortOrder: 0,
        ),
        buildPostIt(
          id: 't2',
          title: 'Segunda',
          startDate: DateOnly(2026, 11, 4),
          sortOrder: 1,
        ),
      ],
    );

    await openDetails(tester, 't2');
    await tester.ensureVisible(find.byKey(const Key('details-move-up')));
    await tester.tap(find.byKey(const Key('details-move-up')));
    await tester.pumpAndSettle();

    final tasks = dependencies.planner.postIts
        .where((postIt) => postIt.startDate == DateOnly(2026, 11, 4))
        .toList();
    expect(tasks.map((postIt) => postIt.id), ['t2', 't1']);
  });

  testWidgets('redimensionar atualiza a barra durante o gesto', (tester) async {
    await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    final bar = find.byKey(
      const ValueKey('event-bar-e1-2026-11-02'),
    );
    final initialWidth = tester.getSize(bar).width;
    final handle = find.byKey(const Key('event-resize-end-e1'));

    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.getSize(bar).width, greaterThan(initialWidth));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('alça final estende evento em um dia', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    final handle = find.byKey(const Key('event-resize-end-e1'));
    expect(handle, findsOneWidget);

    await tester.drag(handle, const Offset(160, 0));
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.startDate, DateOnly(2026, 11, 4));
    expect(event.endDate, DateOnly(2026, 11, 7));
  });

  testWidgets('alça inicial antecipa evento', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    final handle = find.byKey(const Key('event-resize-start-e1'));
    await tester.drag(handle, const Offset(-160, 0));
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.startDate, DateOnly(2026, 11, 3));
    expect(event.endDate, DateOnly(2026, 11, 6));
  });

  testWidgets('detalhe oferece mover para data', (tester) async {
    await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Mover',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    await openDetails(tester, 't1');
    await tester.ensureVisible(find.byKey(const Key('details-move')));
    await tester.tap(find.byKey(const Key('details-move')));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('move pela alternativa acessível', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Mover',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    await openDetails(tester, 't1');
    await tester.ensureVisible(find.byKey(const Key('details-move')));
    await tester.tap(find.byKey(const Key('details-move')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('6').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts.single.startDate, DateOnly(2026, 11, 6));
  });

  testWidgets('editor não quebra com teclado virtual', (tester) async {
    await pumpPlanner(tester);
    await openEditor(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('editor-title')), findsOneWidget);
  });
}
