import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';

import '../helpers/test_dependencies.dart';

Future<void> _pressCtrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

Future<void> _pressCtrlShift(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('desktop shortcuts switch sections and open help', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final dependencies = testDependencies(now: DateTime(2026, 11, 12, 12));
      await dependencies.initialize();
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(PlannerApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inbox-search')), findsOneWidget);

      await _pressCtrl(tester, LogicalKeyboardKey.tab);
      expect(find.byKey(const Key('add-note')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.keyboardShortcutsTitle), findsOneWidget);
      expect(find.text('Ctrl + N'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('desktop saves note with Ctrl+S and opens shortcut tips', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final dependencies = testDependencies(now: DateTime(2026, 11, 12, 12));
      await dependencies.initialize();
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(PlannerApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      await _pressCtrl(tester, LogicalKeyboardKey.digit3);
      await tester.tap(find.byKey(const Key('add-note')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('note-title')),
        'Nota desktop',
      );
      await _pressCtrl(tester, LogicalKeyboardKey.keyS);

      expect(find.text('Nota desktop'), findsOneWidget);

      await _pressCtrl(tester, LogicalKeyboardKey.comma);
      final shortcuts = find.byKey(const Key('settings-desktop-shortcuts'));
      await tester.ensureVisible(shortcuts);
      await tester.pumpAndSettle();
      await tester.tap(shortcuts);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.keyboardShortcutsTitle), findsOneWidget);
      expect(find.text('Ctrl + Tab / Shift + Ctrl + Tab'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('right-click on a day opens the desktop context menu', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final dependencies = testDependencies(now: DateTime(2026, 11, 12, 12));
      await dependencies.initialize();
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(PlannerApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      final day = find.byKey(const Key('day-2026-11-12'));
      expect(day, findsOneWidget);
      final gesture = await tester.startGesture(
        tester.getCenter(day),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('day-menu-task')), findsOneWidget);
      expect(find.byKey(const Key('day-menu-event')), findsOneWidget);

      await tester.tap(find.byKey(const Key('day-menu-task')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editor-title')), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('desktop checklist exposes an explicit delete action', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final dependencies = testDependencies(now: DateTime(2026, 11, 12, 12));
      await dependencies.initialize();
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(PlannerApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      await _pressCtrl(tester, LogicalKeyboardKey.digit3);
      await tester.tap(find.byKey(const Key('add-note')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.noteTypeChecklist));
      await tester.pumpAndSettle();

      final delete = find.byKey(const Key('note-line-delete-0'));
      expect(delete, findsOneWidget);
      expect(
        find.descendant(of: delete, matching: find.byType(IconButton)),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('desktop pairing hides the camera QR action', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final dependencies = testDependencies(now: DateTime(2026, 11, 12, 12));
      await dependencies.initialize();
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(PlannerApp(dependencies: dependencies));
      await tester.pumpAndSettle();

      await _pressCtrlShift(tester, LogicalKeyboardKey.keyS);
      final pair = find.byKey(const Key('settings-sync-pair'));
      await tester.ensureVisible(pair);
      await tester.pumpAndSettle();
      await tester.tap(pair);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sync-pair-code')), findsOneWidget);
      expect(find.byKey(const Key('sync-pair-scan')), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
