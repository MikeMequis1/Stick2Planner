import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'app_strings.dart';
import 'bootstrap.dart';
import 'theme/app_theme.dart';
import '../features/shell/home_shell.dart';

/// Raiz do aplicativo.
class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      planner: dependencies.planner,
      notes: dependencies.notes,
      navigation: dependencies.navigation,
      settings: dependencies.settings,
      child: ListenableBuilder(
        listenable: dependencies.settings,
        builder: (context, _) {
          final settings = dependencies.settings;
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [Locale('pt', 'BR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            builder: (context, child) {
              final dark = Theme.of(context).brightness == Brightness.dark;
              final iconBrightness = dark ? Brightness.light : Brightness.dark;
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  disableAnimations: !settings.animationsEnabled,
                ),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    statusBarIconBrightness: iconBrightness,
                    systemNavigationBarIconBrightness: iconBrightness,
                    systemStatusBarContrastEnforced: false,
                    systemNavigationBarContrastEnforced: false,
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
