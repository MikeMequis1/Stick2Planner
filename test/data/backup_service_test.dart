import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/backup/backup_document.dart';
import 'package:stick2planner/data/backup/backup_service.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_note_repository.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/repositories/drift_routine_repository.dart';
import 'package:stick2planner/data/repositories/drift_settings_repository.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';
import 'package:stick2planner/domain/entities/routine.dart';

void main() {
  final exportedAt = DateTime.utc(2026, 11, 4, 12);

  AppDatabase openDb() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  Future<Directory> tempDir() async {
    final dir = await Directory.systemTemp.createTemp('s2p_backup_');
    addTearDown(() => dir.delete(recursive: true));
    return dir;
  }

  BackupService serviceFor(
    AppDatabase db,
    Directory dir, {
    DateTime Function()? now,
  }) => BackupService(
    database: db,
    backupDirectory: () async => dir,
    now: now ?? () => exportedAt,
  );

  Future<void> seed(AppDatabase db) async {
    final notes = DriftNoteRepository(db);
    final postIts = DriftPostItRepository(db);
    final settings = DriftSettingsRepository(db);

    await notes.save(
      Note(
        id: 'n1',
        title: 'Lista de compras',
        type: NoteType.checklist,
        lines: const [
          NoteLine(
            id: 'l1',
            noteId: 'n1',
            position: 0,
            text: 'Pão',
            isChecked: true,
          ),
          NoteLine(id: 'l2', noteId: 'n1', position: 1, text: 'Café'),
        ],
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
    );

    await postIts.save(
      PostIt(
        id: 'p1',
        title: 'Comprar pão',
        type: PostItType.event,
        status: PostItStatus.active,
        isHighlight: true,
        details: 'Padaria da esquina',
        noteId: 'n1',
        noteExcerpt: 'Pão e café',
        sourceNoteId: 'n1',
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
        sortOrder: 2,
        lastRolloverAt: exportedAt,
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
      history: PostItHistoryEntry(
        id: 'h1',
        postItId: 'p1',
        action: PostItHistoryAction.created,
        toValue: 'Comprar pão',
        createdAt: exportedAt,
      ),
    );

    await postIts.save(
      PostIt(
        id: 'p2',
        title: 'Excluída',
        type: PostItType.task,
        status: PostItStatus.cancelled,
        createdAt: exportedAt,
        updatedAt: exportedAt,
        deletedAt: exportedAt,
      ),
    );

    await settings.write('planner.themeMode', 'dark');
    await settings.write('planner.sync.serverUrl', 'http://ignorado');
  }

  test('exporta tudo e omite credenciais de sync', () async {
    final db = openDb();
    await seed(db);
    final dir = await tempDir();
    final service = serviceFor(db, dir);

    final raw = await service.exportToJson();
    final document = BackupDocument.parse(raw);

    expect(document.counts.postIts, 1);
    expect(document.counts.notes, 1);
    expect(document.counts.noteLines, 2);
    expect(document.counts.history, 1);
    expect(document.checksum, startsWith('sha256:'));

    final settings = (document.data['settings'] as List)
        .cast<Map<String, Object?>>();
    expect(
      settings.map((entry) => entry['key']),
      contains('planner.themeMode'),
    );
    expect(
      settings.map((entry) => entry['key']),
      isNot(contains('planner.sync.serverUrl')),
    );
  });

  test(
    'contagens ignoram itens apagados, mas o backup preserva tombstones',
    () async {
      final db = openDb();
      await seed(db);
      final dir = await tempDir();
      final postIts = DriftPostItRepository(db);
      final notes = DriftNoteRepository(db);

      await postIts.softDelete(id: 'p1', deletedAt: exportedAt);
      await notes.softDelete(id: 'n1', deletedAt: exportedAt);

      final document = await serviceFor(db, dir).buildExport();

      expect(document.counts.postIts, 0);
      expect(document.counts.notes, 0);
      expect(document.counts.noteLines, 0);
      expect(document.counts.history, 0);
      expect(document.data['postIts'], hasLength(2));
      expect(document.data['notes'], hasLength(1));
    },
  );

  test('exporta e restaura rotinas simples e completas', () async {
    final source = openDb();
    await seed(source);
    final routines = DriftRoutineRepository(source);
    await routines.save(
      Routine(
        id: 'r-simple',
        name: 'Simples',
        weekdays: const {1},
        items: [
          RoutineItem(
            id: 'ri1',
            routineId: 'r-simple',
            title: 'Alongar',
            position: 0,
            completedDates: {DateOnly(2026, 11, 4)},
          ),
        ],
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
    );
    await routines.setCompletion(
      routineItemId: 'ri1',
      date: DateOnly(2026, 11, 4),
      completed: true,
      at: exportedAt,
    );
    await routines.save(
      Routine(
        id: 'r-complete',
        name: 'Completa',
        mode: RoutineMode.complete,
        weekdays: const {3},
        sections: [
          RoutineSection(
            id: 'rs1',
            routineId: 'r-complete',
            title: 'Manhã',
            position: 0,
            startMinutes: 480,
            endMinutes: 720,
            intervals: [
              RoutineInterval(
                id: 'rv1',
                sectionId: 'rs1',
                startMinutes: 480,
                endMinutes: 600,
                position: 0,
                title: 'Estudar',
                completedDates: {DateOnly(2026, 11, 4)},
              ),
              const RoutineInterval(
                id: 'rv2',
                sectionId: 'rs1',
                startMinutes: 600,
                endMinutes: 720,
                position: 1,
                title: 'Trabalhar',
              ),
            ],
          ),
        ],
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
    );

    final dir = await tempDir();
    final raw = await serviceFor(source, dir).exportToJson();
    final document = BackupDocument.parse(raw);
    expect(document.counts.routines, 2);

    final target = openDb();
    await serviceFor(target, dir).importJson(raw);
    final restored = await DriftRoutineRepository(target).loadAll();
    expect(restored, hasLength(2));

    final simple = restored.singleWhere((item) => item.id == 'r-simple');
    expect(simple.mode, RoutineMode.simple);
    expect(simple.items.single.completedDates, {DateOnly(2026, 11, 4)});

    final complete = restored.singleWhere((item) => item.id == 'r-complete');
    expect(complete.mode, RoutineMode.complete);
    expect(complete.sections.single.title, 'Manhã');
    expect(complete.sections.single.startMinutes, 480);
    expect(complete.sections.single.endMinutes, 720);
    expect(complete.sections.single.intervals.map((item) => item.title), [
      'Estudar',
      'Trabalhar',
    ]);
    expect(complete.sections.single.intervals.first.completedDates, {
      DateOnly(2026, 11, 4),
    });
    expect(await serviceFor(target, dir).exportToJson(), raw);
  });

  test('ida e volta reconstrói o mesmo estado', () async {
    final source = openDb();
    await seed(source);
    final dir = await tempDir();
    final sourceJson = await serviceFor(source, dir).exportToJson();

    final target = openDb();
    final result = await serviceFor(target, dir).importJson(sourceJson);

    expect(result.counts.postIts, 1);
    expect(result.counts.notes, 1);
    expect(result.counts.noteLines, 2);
    expect(result.counts.history, 1);

    final restoredJson = await serviceFor(target, dir).exportToJson();
    expect(restoredJson, sourceJson);
  });

  test('checksum divergente é recusado sem escrever', () async {
    final source = openDb();
    await seed(source);
    final dir = await tempDir();
    final raw = await serviceFor(source, dir).exportToJson();
    final tampered = raw.replaceFirst('Comprar pão', 'Comprar bolo');

    final target = openDb();
    await expectLater(
      () => serviceFor(target, dir).importJson(tampered),
      throwsA(
        isA<BackupException>().having(
          (error) => error.code,
          'code',
          BackupErrorCode.checksumMismatch,
        ),
      ),
    );

    final postIts = await DriftPostItRepository(target)
        .loadAll(includeDeleted: true);
    expect(postIts, isEmpty);
  });

  test('formatVersion e schemaVersion desconhecidos são recusados', () async {
    final db = openDb();
    await seed(db);
    final dir = await tempDir();
    final service = serviceFor(db, dir);
    final root = jsonDecode(await service.exportToJson()) as Map;

    root['formatVersion'] = 2;
    expect(
      () => BackupDocument.parse(jsonEncode(root)),
      throwsA(
        isA<BackupException>().having(
          (error) => error.code,
          'code',
          BackupErrorCode.unsupportedFormatVersion,
        ),
      ),
    );

    root['formatVersion'] = 1;
    root['schemaVersion'] = 13;
    expect(
      () => BackupDocument.parse(jsonEncode(root)),
      throwsA(
        isA<BackupException>().having(
          (error) => error.code,
          'code',
          BackupErrorCode.unsupportedSchemaVersion,
        ),
      ),
    );
  });

  test('referência inexistente não altera dados existentes', () async {
    final source = openDb();
    await seed(source);
    final dir = await tempDir();
    final service = serviceFor(source, dir);
    final document = BackupDocument.parse(await service.exportToJson());

    final data = Map<String, Object?>.from(document.data);
    final postIts = [
      for (final entry
          in (data['postIts'] as List).cast<Map<String, Object?>>())
        {...entry},
    ];
    postIts.first['noteId'] = 'nota-inexistente';
    data['postIts'] = postIts;

    final broken = BackupDocument(
      schemaVersion: document.schemaVersion,
      appVersion: document.appVersion,
      exportedAt: document.exportedAt,
      data: data,
    ).toJsonString();

    final target = openDb();
    await DriftPostItRepository(target).save(
      PostIt(
        id: 'mantida',
        title: 'Mantida',
        type: PostItType.task,
        status: PostItStatus.active,
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
    );

    await expectLater(
      () => serviceFor(target, dir).importJson(broken),
      throwsA(isA<BackupException>()),
    );

    final postItsAfter = await DriftPostItRepository(target)
        .loadAll(includeDeleted: true);
    expect(postItsAfter.map((postIt) => postIt.id), ['mantida']);
  });

  test('importação limpa outbox, revisões e cursor de sync', () async {
    final source = openDb();
    await seed(source);
    final dir = await tempDir();
    final json = await serviceFor(source, dir).exportToJson();

    final target = openDb();
    await DriftPostItRepository(target).save(
      PostIt(
        id: 'antiga',
        title: 'Antiga',
        type: PostItType.task,
        status: PostItStatus.active,
        createdAt: exportedAt,
        updatedAt: exportedAt,
      ),
    );
    final state = SyncStateStore(target);
    await state.setCursor(9);

    await serviceFor(target, dir).importJson(json);

    expect(await target.select(target.syncOutbox).get(), isEmpty);
    expect(await target.select(target.syncRowStates).get(), isEmpty);
    expect(await target.select(target.syncBases).get(), isEmpty);
    expect(await state.cursor(), 0);
  });

  test('snapshot pré-importação é criado e limitado a cinco', () async {
    final db = openDb();
    await seed(db);
    final dir = await tempDir();
    var clock = exportedAt;
    final service = serviceFor(db, dir, now: () => clock);
    final firstJson = await service.exportToJson();

    for (var index = 0; index < 6; index++) {
      clock = exportedAt.add(Duration(minutes: index));
      final result = await service.importJson(firstJson);
      final snapshot = File(result.snapshot.path);
      expect(await snapshot.exists(), isTrue);
      final parsed = BackupDocument.parse(await snapshot.readAsString());
      expect(parsed.counts.postIts, 1);
    }

    final snapshots = await service.listSnapshots();
    expect(snapshots, hasLength(5));
  });
}
