import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/tag.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('cria tag pela tela de gerenciamento', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-tags')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('settings-tags')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tags-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tag-name')), 'Estudo');
    await tester.tap(find.byKey(const Key('tag-tone-tertiary')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tag-save')));
    await tester.pumpAndSettle();

    expect(dependencies.tags.tags.single.name, 'Estudo');
    expect(dependencies.tags.tags.single.tone, TagTone.tertiary);
    expect(find.text('Estudo'), findsOneWidget);
  });

  testWidgets('Caixinha vazia mostra atalho para criar tags', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.inbox),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.tagFilterEmpty), findsOneWidget);
    expect(find.text(AppStrings.emptyInbox), findsOneWidget);
    expect(find.text(AppStrings.inboxPlaceholderBody), findsOneWidget);
    expect(find.text(AppStrings.tagNew), findsOneWidget);

    await tester.tap(find.byKey(const Key('inbox-manage-tags')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.tagsTitle), findsOneWidget);
  });

  testWidgets('Caixinha filtra por uma ou mais tags e limpa', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final work = await dependencies.tags.create(
      name: 'Trabalho',
      tone: TagTone.primary,
    );
    final home = await dependencies.tags.create(
      name: 'Casa',
      tone: TagTone.tertiary,
    );
    await dependencies.planner.createPostIt(
      title: 'A',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 6),
      tagIds: [work.id],
    );
    await dependencies.planner.createPostIt(
      title: 'B',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 6),
      tagIds: [home.id],
    );
    await dependencies.planner.createPostIt(
      title: 'C',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 6),
    );

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.inbox),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(Key('inbox-tag-filter-${work.id}')), findsOneWidget);
    expect(find.byKey(Key('inbox-tag-filter-${home.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('inbox-tag-filter-${work.id}')));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);

    await tester.tap(find.byKey(Key('inbox-tag-filter-${home.id}')));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsNothing);

    await tester.tap(find.byKey(const Key('inbox-tag-clear')));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });
}
