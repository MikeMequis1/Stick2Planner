import 'package:flutter/widgets.dart';

import '../data/backup/backup_file_gateway.dart';
import '../data/backup/backup_service.dart';
import 'controllers/app_navigation_controller.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/notes_controller.dart';
import 'controllers/planner_controller.dart';
import 'controllers/tags_controller.dart';
import 'services/sync_coordinator.dart';

/// Expõe os controllers para a árvore de widgets.
///
/// Widgets escutam com `ListenableBuilder`; este escopo só injeta dependências.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.planner,
    required this.notes,
    required this.tags,
    required this.navigation,
    required this.settings,
    required this.backup,
    required this.backupFiles,
    required this.sync,
    required super.child,
  });

  final PlannerController planner;
  final NotesController notes;
  final TagsController tags;
  final AppNavigationController navigation;
  final AppSettingsController settings;
  final BackupService backup;
  final BackupFileGateway backupFiles;
  final SyncCoordinator sync;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      planner != oldWidget.planner ||
      notes != oldWidget.notes ||
      tags != oldWidget.tags ||
      navigation != oldWidget.navigation ||
      settings != oldWidget.settings ||
      backup != oldWidget.backup ||
      backupFiles != oldWidget.backupFiles ||
      sync != oldWidget.sync;
}
