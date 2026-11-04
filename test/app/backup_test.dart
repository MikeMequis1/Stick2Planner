import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/controllers/notes_controller.dart';
import 'package:stick2planner/app/controllers/planner_controller.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/backup/backup_document.dart';
import 'package:stick2planner/data/backup/backup_file_gateway.dart';
import 'package:stick2planner/data/backup/backup_service.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_note_repository.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/repositories/drift_settings_repository.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

import '../helpers/test_dependencies.dart';

final class FakeBackupGateway implements BackupFileGateway {
  String? savedPath;
  String? savedContents;
  BackupFile? nextPick;

  @override
  Future<String?> saveBackup({
    required String fileName,
    required String contents,
  }) async {
    savedContents = contents;
    savedPath = '/fake/$fileName';
    return savedPath;
  }

  @override
  Future<BackupFile?> pickBackup() async => nextPick;
}

Directory? sharedDir;

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    sharedDir = await Directory.systemTemp.createTemp('s2p_backup_ui_');
  });
  tearDownAll(() async {
    await sharedDir?.delete(recursive: true);
    sharedDir = null;
  });

  Future<AppDependencies> pumpApp(
    WidgetTester tester, {
    required FakeBackupGateway gateway,
  }) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final clock = FixedClock(DateTime(2026, 11, 3, 9));
    final database = AppDatabase(NativeDatabase.memory());
    final directory = sharedDir!;

    final dependencies = AppDependencies(
      database: database,
      planner: PlannerController(
        postItRepository: DriftPostItRepository(database),
        settingsRepository: DriftSettingsRepository(database),
        clock: clock,
      ),
      notes: NotesController(
        noteRepository: DriftNoteRepository(database),
        clock: clock,
      ),
      backup: BackupService(
        database: database,
        backupDirectory: () async => directory,
        now: () => DateTime.utc(2026, 11, 3, 9),
      ),
      backupFiles: gateway,
    );
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> openBackupSection(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-backup-export')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exporta backup com todos os dados', (tester) async {
    final gateway = FakeBackupGateway();
    final dependencies = await pumpApp(tester, gateway: gateway);
    await dependencies.planner.createPostIt(
      title: 'Exportar',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 4),
    );

    await openBackupSection(tester);
    await tester.tap(find.byKey(const Key('settings-backup-export')));
    await tester.pumpAndSettle();

    expect(gateway.savedContents, isNotNull);
    final document = BackupDocument.parse(gateway.savedContents!);
    expect(document.counts.postIts, 1);
    expect(find.textContaining('Backup exportado'), findsOneWidget);
  });

  testWidgets('importa backup após confirmação e substitui dados', (
    tester,
  ) async {
    final gateway = FakeBackupGateway();
    final dependencies = await pumpApp(tester, gateway: gateway);

    await dependencies.planner.createPostIt(
      title: 'Original',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 4),
    );
    final backup = await dependencies.backup.exportToJson();

    await openBackupSection(tester);
    await tester.tap(find.byKey(const Key('settings-backup-export')));
    await tester.pumpAndSettle();

    await dependencies.planner.createPostIt(
      title: 'Temporária',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 5),
    );
    gateway.nextPick = BackupFile(name: 'backup.json', contents: backup);

    await tester.tap(find.byKey(const Key('settings-backup-import')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.backupImportConfirmTitle), findsOneWidget);

    await tester.tap(find.byKey(const Key('backup-import-confirm')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.postIts.map((postIt) => postIt.title), [
      'Original',
    ]);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.textContaining('Backup restaurado'), findsOneWidget);
    expect(await dependencies.backup.listSnapshots(), isNotEmpty);
  });
}
