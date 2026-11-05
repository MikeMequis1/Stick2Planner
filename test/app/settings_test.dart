import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/theme/app_palette.dart';
import 'package:stick2planner/core/date_formatting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('configurações alteram aparência, animações e dicas', (
    tester,
  ) async {
    final dependencies = await pumpApp(tester);

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.byKey(const Key('settings-theme')), findsOneWidget);
    expect(find.byKey(const Key('settings-animations')), findsOneWidget);
    expect(find.byKey(const Key('settings-keep-awake')), findsOneWidget);
    expect(find.byKey(const Key('settings-hints')), findsOneWidget);

    await tester.tap(find.text(AppStrings.settingsThemeDark));
    await tester.pumpAndSettle();
    expect(dependencies.settings.themeMode, ThemeMode.dark);

    await tester.tap(find.byKey(const Key('settings-palette-ocean')));
    await tester.pumpAndSettle();
    expect(dependencies.settings.palette, AppPalette.ocean);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(dependencies.settings.language, AppLanguage.en);
    expect(AppStrings.inbox, 'Inbox');
    expect(find.text('Settings'), findsOneWidget);
    expect(DateFormats.locale, 'en');

    await tester.tap(find.byKey(const Key('settings-animations')));
    await tester.pumpAndSettle();
    expect(dependencies.settings.animationsEnabled, isFalse);

    await tester.tap(find.byKey(const Key('settings-hints')));
    await tester.pumpAndSettle();
    expect(dependencies.settings.showCalendarHints, isFalse);

    Navigator.of(
      tester.element(find.text(AppStrings.settings)),
    ).pop();
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.calendarHint), findsNothing);
  });

  testWidgets('Sobre mostra versão, descrição e links', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Stick2Planner',
      packageName: 'com.mikemequis1.planner',
      version: '0.1.1',
      buildNumber: '3',
      buildSignature: '',
    );

    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-about')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('settings-about')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.aboutTitle), findsOneWidget);
    expect(find.text(AppStrings.aboutDescription), findsOneWidget);
    expect(find.text(AppStrings.aboutVersion('0.1.1')), findsOneWidget);
    expect(find.byKey(const Key('about-repository')), findsOneWidget);
    expect(find.byKey(const Key('about-profile')), findsOneWidget);
  });
}
