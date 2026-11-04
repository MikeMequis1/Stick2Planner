import 'package:flutter/material.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/bootstrap.dart';
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
    List<PostIt> postIts = const [],
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
    await dependencies.initialize();
    for (final postIt in postIts) {
      await dependencies.planner.savePostIt(postIt);
    }
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> openInbox(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.inbox),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<PostIt> seedAll() => [
    buildPostIt(
      id: 'active',
      title: 'Reunião',
      startDate: DateOnly(2026, 11, 3),
    ),
    buildPostIt(
      id: 'done',
      title: 'Feito',
      status: PostItStatus.done,
      startDate: DateOnly(2026, 11, 3),
    ),
    buildPostIt(
      id: 'cancelled',
      title: 'Cancelado',
      status: PostItStatus.cancelled,
      startDate: DateOnly(2026, 11, 3),
    ),
    buildPostIt(
      id: 'undated',
      title: 'Sem data',
      details: 'Encontrar na caixinha',
    ),
  ];

  testWidgets('caixinha lista ativos, concluídos, cancelados e sem data', (
    tester,
  ) async {
    await pumpPlanner(tester, postIts: seedAll());
    await openInbox(tester);

    expect(find.byKey(const Key('inbox-postit-active')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-done')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-cancelled')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-undated')), findsOneWidget);
  });

  testWidgets('filtros por estado e sem data funcionam', (tester) async {
    await pumpPlanner(tester, postIts: seedAll());
    await openInbox(tester);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inbox-postit-done')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-active')), findsNothing);

    await tester.tap(find.text(AppStrings.cancelled));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inbox-postit-cancelled')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-done')), findsNothing);

    await tester.tap(
      find.widgetWithText(ChoiceChip, AppStrings.undated),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inbox-postit-undated')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-active')), findsNothing);
  });

  testWidgets('busca filtra por título e detalhes', (tester) async {
    await pumpPlanner(tester, postIts: seedAll());
    await openInbox(tester);

    await tester.enterText(
      find.byKey(const Key('inbox-search')),
      'encontrar',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inbox-postit-undated')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-active')), findsNothing);

    await tester.enterText(find.byKey(const Key('inbox-search')), 'reunião');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inbox-postit-active')), findsOneWidget);
    expect(find.byKey(const Key('inbox-postit-undated')), findsNothing);
  });

  testWidgets('conclui e reabre pela caixinha', (tester) async {
    final dependencies = await pumpPlanner(tester, postIts: seedAll());
    await openInbox(tester);

    await tester.tap(find.byKey(const Key('inbox-menu-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.statusDoneAction));
    await tester.pumpAndSettle();

    expect(
      dependencies.planner.postIts
          .singleWhere((postIt) => postIt.id == 'active')
          .status,
      PostItStatus.done,
    );

    await tester.tap(find.byKey(const Key('inbox-menu-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.statusReopenAction));
    await tester.pumpAndSettle();

    expect(
      dependencies.planner.postIts
          .singleWhere((postIt) => postIt.id == 'active')
          .status,
      PostItStatus.active,
    );
    expect(find.byKey(const Key('inbox-postit-active')), findsOneWidget);
  });

  testWidgets('conclui pelo detalhe da agenda', (tester) async {    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'agenda',
          title: 'Concluir pela agenda',
          startDate: DateOnly(2026, 11, 3),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('post-it-agenda')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('details-complete')));
    await tester.tap(find.byKey(const Key('details-complete')));
    await tester.pumpAndSettle();

    expect(
      dependencies.planner.postIts.single.status,
      PostItStatus.done,
    );
  });

  testWidgets('desfaz exclusão pelo snackbar', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'undo',
          title: 'Recuperável',
          startDate: DateOnly(2026, 11, 3),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('post-it-undo')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('details-delete')));
    await tester.tap(find.byKey(const Key('details-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts, isEmpty);
    expect(find.text(AppStrings.undo), findsOneWidget);

    await tester.tap(find.text(AppStrings.undo));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts.single.id, 'undo');
    expect(find.byKey(const Key('post-it-undo')), findsOneWidget);
  });

  testWidgets('recorrente adiado é sinalizado e preservado na caixinha', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      postIts: [
        buildPostIt(
          id: 'rec',
          title: 'Tomar remédio',
          type: PostItType.recurringTodo,
          startDate: DateOnly(2026, 11, 6),
        ),
      ],
    );
    await openInbox(tester);

    expect(find.byKey(const Key('inbox-postit-rec')), findsOneWidget);
    expect(find.textContaining(AppStrings.postponedUntil), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });

  testWidgets('cria TO-DO recorrente sem data pela agenda', (tester) async {
    final dependencies = await pumpPlanner(tester);

    await tester.tap(find.byKey(const Key('add-post-it')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('editor-title')),
      'Beber água',
    );
    await tester.tap(find.text(AppStrings.recurringShort));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-save')));
    await tester.pumpAndSettle();

    final recurring = dependencies.planner.postIts.single;
    expect(recurring.type, PostItType.recurringTodo);
    expect(recurring.startDate, DateOnly(2026, 11, 3));
    expect(dependencies.planner.isPostponed(recurring), isFalse);
    expect(
      find.byKey(Key('post-it-${recurring.id}')),
      findsOneWidget,
    );
  });
}
