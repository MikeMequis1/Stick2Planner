import 'package:flutter/widgets.dart';

import 'controllers/app_navigation_controller.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/notes_controller.dart';
import 'controllers/planner_controller.dart';

/// Expõe os controllers para a árvore de widgets.
///
/// Widgets escutam com `ListenableBuilder`; este escopo só injeta dependências.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.planner,
    required this.notes,
    required this.navigation,
    required this.settings,
    required super.child,
  });

  final PlannerController planner;
  final NotesController notes;
  final AppNavigationController navigation;
  final AppSettingsController settings;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      planner != oldWidget.planner ||
      notes != oldWidget.notes ||
      navigation != oldWidget.navigation ||
      settings != oldWidget.settings;
}
