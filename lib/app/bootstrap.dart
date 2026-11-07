import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/clock.dart';
import '../data/backup/backup_file_gateway.dart';
import '../data/backup/backup_service.dart';
import '../data/db/app_database.dart';
import '../data/repositories/drift_note_repository.dart';
import '../data/repositories/drift_post_it_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../data/repositories/drift_tag_repository.dart';
import '../data/sync/sync_state_store.dart';
import 'controllers/app_navigation_controller.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/notes_controller.dart';
import 'controllers/planner_controller.dart';
import 'controllers/tags_controller.dart';
import 'services/screen_wake_service.dart';
import 'services/sync_coordinator.dart';
import 'services/token_store.dart';

/// Diretório privado dos snapshots automáticos de backup.
Future<Directory> defaultBackupDirectory() async {
  final support = await getApplicationSupportDirectory();
  return Directory(p.join(support.path, 'backups'));
}

/// Composição das dependências do aplicativo.
///
/// Mantém a criação de banco, repositórios e controllers em um único ponto;
/// testes montam a mesma estrutura com banco em memória.
final class AppDependencies {
  AppDependencies({
    required this.database,
    required this.planner,
    required this.notes,
    required this.tags,
    AppNavigationController? navigation,
    AppSettingsController? settings,
    ScreenWakeService? screenWake,
    BackupService? backup,
    BackupFileGateway? backupFiles,
    TokenStore? tokens,
    SyncCoordinator? sync,
    SyncTransportFactory? syncTransportFactory,
    Stream<bool>? connectivityChanges,
  }) : navigation = navigation ?? AppNavigationController(),
       screenWake = screenWake ?? const WakelockPlusScreenWakeService(),
       backupFiles = backupFiles ?? const FilePickerBackupGateway(),
       backup =
           backup ??
           BackupService(
             database: database,
             backupDirectory: defaultBackupDirectory,
           ),
       settings =
           settings ??
           AppSettingsController(
             settingsRepository: DriftSettingsRepository(database),
             screenWake: screenWake ?? const WakelockPlusScreenWakeService(),
           ) {
    this.tokens = tokens ?? SecureTokenStore();
    this.sync =
        sync ??
        SyncCoordinator(
          database: database,
          state: SyncStateStore(database),
          tokens: this.tokens,
          transportFactory: syncTransportFactory,
          connectivityChanges: connectivityChanges,
        );
    this.sync.onApplied = () async {
      await planner.refresh();
      await notes.refresh();
      await tags.refresh();
    };
    tags.onDeleted = planner.removeTagFromAll;
  }

  factory AppDependencies.fromDatabase(
    AppDatabase database, {
    Clock clock = const SystemClock(),
    BackupService? backup,
    BackupFileGateway? backupFiles,
    TokenStore? tokens,
    SyncCoordinator? sync,
    SyncTransportFactory? syncTransportFactory,
    Stream<bool>? connectivityChanges,
  }) {
    final postItRepository = DriftPostItRepository(database);
    final noteRepository = DriftNoteRepository(database);
    final settingsRepository = DriftSettingsRepository(database);
    final tagRepository = DriftTagRepository(database);

    return AppDependencies(
      database: database,
      backup: backup,
      backupFiles: backupFiles,
      tokens: tokens,
      sync: sync,
      syncTransportFactory: syncTransportFactory,
      connectivityChanges: connectivityChanges,
      planner: PlannerController(
        postItRepository: postItRepository,
        settingsRepository: settingsRepository,
        clock: clock,
      ),
      notes: NotesController(noteRepository: noteRepository, clock: clock),
      tags: TagsController(repository: tagRepository, clock: clock),
    );
  }

  static AppDependencies open({Clock clock = const SystemClock()}) =>
      AppDependencies.fromDatabase(
        AppDatabase.open(),
        clock: clock,
        connectivityChanges: Connectivity().onConnectivityChanged.map(
          (results) =>
              results.any((result) => result != ConnectivityResult.none),
        ),
      );

  final AppDatabase database;
  final PlannerController planner;
  final NotesController notes;
  final TagsController tags;
  final AppNavigationController navigation;
  final AppSettingsController settings;
  final ScreenWakeService screenWake;
  final BackupService backup;
  final BackupFileGateway backupFiles;
  late final TokenStore tokens;
  late final SyncCoordinator sync;

  Future<void> initialize() async {
    await Future.wait([
      planner.initialize(),
      notes.initialize(),
      tags.initialize(),
      settings.initialize(),
    ]);
    await sync.initialize();
  }

  Future<void> dispose() async {
    sync.dispose();
    planner.dispose();
    notes.dispose();
    tags.dispose();
    navigation.dispose();
    settings.dispose();
    await database.close();
  }
}
