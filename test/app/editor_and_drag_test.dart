import 'package:flutter/material.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/planner_view_mode.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
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

  testWidgets('evento pode repetir semanalmente', (tester) async {
    final dependencies = await pumpPlanner(tester, size: const Size(360, 780));

    await openEditor(tester);
    await tester.enterText(find.byKey(const Key('editor-title')), 'Reunião');
    await tester.tap(find.text(AppStrings.eventType));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('editor-recurrence')));
    await tester.tap(find.byKey(const Key('editor-recurrence')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.repeatWeekly).last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-recurrence-weeks')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('editor-recurrence-weeks')),
    );
    await tester.tap(find.byKey(const Key('editor-recurrence-weeks')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.type, PostItType.event);
    expect(event.recurrence, EventRecurrence.weekly);
    expect(event.recurrenceInterval, 2);
    expect(
      dependencies.planner
          .postItsOn(DateOnly(2026, 11, 18))
          .map((postIt) => postIt.id),
      contains(event.id),
    );
  });

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

  testWidgets('descrição acompanha o tipo e o estado Feito', (tester) async {
    await pumpPlanner(tester, size: const Size(360, 780));

    String description() => tester
        .widget<Text>(find.byKey(const Key('editor-type-description-text')))
        .data!;

    await openEditor(tester);
    expect(description(), AppStrings.taskTypeHelp);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('editor-type-task')))
          .showCheckmark,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('editor-type-event')));
    await tester.pumpAndSettle();
    expect(description(), AppStrings.eventTypeHelp);
    expect(find.text('Feito'), findsWidgets);

    await tester.ensureVisible(find.text(AppStrings.fieldHighlight));
    await tester.tap(find.text(AppStrings.fieldHighlight));
    await tester.pumpAndSettle();
    expect(description(), AppStrings.doneInfo);

    await tester.ensureVisible(
      find.byKey(const Key('editor-type-recurringTodo')),
    );
    await tester.tap(find.byKey(const Key('editor-type-recurringTodo')));
    await tester.pumpAndSettle();
    expect(description(), AppStrings.recurringHelp);
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
    await tester.ensureVisible(find.text(AppStrings.fieldHighlight));
    await tester.tap(find.text(AppStrings.fieldHighlight));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('editor-save')));
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

    expect(
      dependencies.planner.postIts.single.startDate,
      DateOnly(2026, 11, 6),
    );
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

  testWidgets('arrasta evento entre semanas visíveis', (tester) async {
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
    await dependencies.planner.setMode(
      AgendaViewMode.twoWeeks,
      Orientation.landscape,
    );
    await tester.pumpAndSettle();

    final source = find.byKey(const ValueKey('event-bar-e1-2026-11-02'));
    final target = find.byKey(const Key('day-2026-11-12'));

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.startDate, DateOnly(2026, 11, 12));
    expect(event.endDate, DateOnly(2026, 11, 14));
  });

  testWidgets('solta evento na faixa de outra semana em duas semanas', (
    tester,
  ) async {
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
        buildPostIt(
          id: 'e2',
          title: 'Outro evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 13),
          endDate: DateOnly(2026, 11, 14),
        ),
      ],
    );
    await dependencies.planner.setMode(
      AgendaViewMode.twoWeeks,
      Orientation.landscape,
    );
    await tester.pumpAndSettle();

    final source = find.byKey(const ValueKey('event-bar-e1-2026-11-02'));
    final cell = find.byKey(const Key('day-2026-11-12'));
    final topLeft = tester.getTopLeft(cell);
    final cellWidth = tester.getSize(cell).width;
    final drop = Offset(topLeft.dx + cellWidth / 2, topLeft.dy - 10);

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(drop);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final moved = dependencies.planner.postIts.firstWhere(
      (postIt) => postIt.id == 'e1',
    );
    expect(moved.startDate, DateOnly(2026, 11, 12));
    expect(moved.endDate, DateOnly(2026, 11, 14));
  });

  testWidgets('solta evento na faixa de outra semana no mês', (tester) async {
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
        buildPostIt(
          id: 'e2',
          title: 'Outro evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 24),
          endDate: DateOnly(2026, 11, 25),
        ),
      ],
    );
    await dependencies.planner.setMode(
      AgendaViewMode.month,
      Orientation.landscape,
    );
    await tester.pumpAndSettle();

    final source = find.byKey(const ValueKey('event-bar-e1-2026-11-02'));
    final cell = find.byKey(const Key('day-2026-11-25'));
    final topLeft = tester.getTopLeft(cell);
    final cellWidth = tester.getSize(cell).width;
    final drop = Offset(topLeft.dx + cellWidth / 2, topLeft.dy - 8);

    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));
    await gesture.moveTo(drop);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final moved = dependencies.planner.postIts.firstWhere(
      (postIt) => postIt.id == 'e1',
    );
    expect(moved.startDate, DateOnly(2026, 11, 25));
    expect(moved.endDate, DateOnly(2026, 11, 27));
  });

  testWidgets('solta evento na borda para avançar uma semana', (tester) async {
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
    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump(const Duration(milliseconds: 650));

    final nextWeek = find.byKey(const Key('event-week-next'));
    expect(nextWeek, findsOneWidget);
    await gesture.moveTo(tester.getCenter(nextWeek));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final event = dependencies.planner.postIts.single;
    expect(event.startDate, DateOnly(2026, 11, 11));
    expect(event.endDate, DateOnly(2026, 11, 13));
    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 11));
  });

  testWidgets('reordena pela alternativa acessível no detalhe', (tester) async {
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

    final bar = find.byKey(const ValueKey('event-bar-e1-2026-11-02'));
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
        buildPostIt(id: 't1', title: 'Mover', startDate: DateOnly(2026, 11, 4)),
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
        buildPostIt(id: 't1', title: 'Mover', startDate: DateOnly(2026, 11, 4)),
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

    expect(
      dependencies.planner.postIts.single.startDate,
      DateOnly(2026, 11, 6),
    );
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
