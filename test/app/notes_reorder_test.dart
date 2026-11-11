import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<void> openNotes(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.notes),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reordena linhas pela alça e persiste na hora', (tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-title')), 'Compras');
    await tester.tap(find.text(AppStrings.noteTypeChecklist));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-0')), 'A');
    await tester.tap(find.byKey(const Key('note-add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-1')), 'B');
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    final noteId = dependencies.notes.notes.single.id;
    await tester.tap(find.byKey(Key('note-$noteId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('note-edit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('note-line-handle-0')), findsOneWidget);
    expect(find.byKey(const Key('note-line-delete-0')), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('note-line-handle-0'))),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.moveBy(const Offset(0, 70));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.moveBy(const Offset(0, 70));
    await tester.pump(const Duration(milliseconds: 120));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      dependencies.notes.notes.single.lines.map((line) => line.text),
      ['B', 'A'],
    );

    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    expect(dependencies.notes.notes.single.lines.map((line) => line.text), [
      'B',
      'A',
    ]);
  });

  testWidgets('seleciona demais linhas com toque e cancela', (tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-title')), 'Seleção');
    await tester.tap(find.text(AppStrings.noteTypeChecklist));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-0')), 'A');
    await tester.tap(find.byKey(const Key('note-add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-1')), 'B');
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    final noteId = dependencies.notes.notes.single.id;
    await tester.tap(find.byKey(Key('note-$noteId')));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.selectedLines(1)), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.selectedLines(2)), findsOneWidget);
    expect(find.byKey(const Key('note-save')), findsNothing);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.tap(find.byKey(const Key('note-cancel-selection')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.selectedLines(2)), findsNothing);
    expect(find.text(AppStrings.selectLinesHint), findsWidgets);
  });

  testWidgets('exclui linha só ao completar o pressionamento', (tester) async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 9, 8));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-title')), 'Excluir');
    await tester.tap(find.text(AppStrings.noteTypeChecklist));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-0')), 'A');
    await tester.tap(find.byKey(const Key('note-add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-line-1')), 'B');
    await tester.pumpAndSettle();

    final delete = find.byKey(const Key('note-line-delete-0'));
    final cancelled = await tester.startGesture(tester.getCenter(delete));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));
    await cancelled.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('note-line-0')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-line-0')))
          .controller
          ?.text,
      'A',
    );

    final completed = await tester.startGesture(tester.getCenter(delete));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800));
    await completed.up();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('note-line-0')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-line-0')))
          .controller
          ?.text,
      'B',
    );
  });
}
