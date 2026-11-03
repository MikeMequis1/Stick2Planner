import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/core/date_formatting.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('agenda mantém layout e rótulos com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.bySemanticsLabel(
        RegExp(
          '${DateFormats.fullDate(DateOnly(2026, 11, 4))}.*'
          '${AppStrings.today}.*${AppStrings.selectedDay}',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(AppStrings.agenda), findsWidgets);
    semantics.dispose();
  });

  testWidgets('editor de nota mantém layout com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.notes));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-markdown')),
      '# Título\n\n**Texto** ampliado.',
    );
    await tester.tap(find.byKey(const Key('note-md-preview')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.markdownPreviewTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
