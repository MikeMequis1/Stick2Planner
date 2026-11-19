import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_routine_repository.dart';
import 'package:stick2planner/domain/entities/routine.dart';
import 'package:stick2planner/domain/entities/tag.dart';

const _v4Schema = '''
CREATE TABLE app_settings (
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  PRIMARY KEY (key)
);
CREATE TABLE notes (
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  markdown TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  PRIMARY KEY (id)
);
CREATE TABLE note_lines (
  id TEXT NOT NULL,
  note_id TEXT NOT NULL REFERENCES notes (id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  content TEXT NOT NULL,
  is_checked INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);
CREATE TABLE post_its (
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  status TEXT NOT NULL,
  is_highlight INTEGER NOT NULL DEFAULT 0,
  details TEXT,
  note_id TEXT REFERENCES notes (id) ON DELETE SET NULL,
  note_excerpt TEXT,
  source_note_id TEXT,
  start_date TEXT,
  end_date TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  last_rollover_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  PRIMARY KEY (id)
);
CREATE TABLE post_it_history_entries (
  id TEXT NOT NULL,
  post_it_id TEXT NOT NULL REFERENCES post_its (id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  from_value TEXT,
  to_value TEXT,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (id)
);
INSERT INTO app_settings VALUES ('planner.themeMode', 'dark');
INSERT INTO notes VALUES ('n1', 'Nota', 'text', '# Título', 1000, 1000, NULL);
INSERT INTO post_its VALUES (
  'p1', 'Post-it', 'task', 'active', 0, NULL, 'n1', 'trecho', 'n1',
  '2026-11-04', NULL, 0, NULL, 1000, 1000, NULL
);
INSERT INTO post_it_history_entries VALUES ('h1', 'p1', 'created', NULL, 'x', 1000);
''';

void main() {
  test(
    'migra v4 para v13 preservando dados e criando tabelas de sync',
    () async {
      final directory = await Directory.systemTemp.createTemp('s2p_migrate_');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}planner.sqlite',
      );

      final raw = sqlite.sqlite3.open(file.path);
      raw.execute(_v4Schema);
      raw.execute('PRAGMA user_version = 4');
      raw.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      expect(db.schemaVersion, 13);

      final notes = await db.select(db.notes).get();
      final postIts = await db.select(db.postIts).get();
      final history = await db.select(db.postItHistoryEntries).get();
      final settings = await db.select(db.appSettings).get();

      expect(notes.single.id, 'n1');
      expect(notes.single.markdown, '# Título');
      expect(postIts.single.id, 'p1');
      expect(postIts.single.sourceNoteId, 'n1');
      expect(postIts.single.recurrenceEndDate, isNull);
      expect(postIts.single.occurrenceStatuses, isEmpty);
      expect(history.single.id, 'h1');
      expect(settings.single.value, 'dark');

      expect(await db.select(db.syncOutbox).get(), isEmpty);
      expect(await db.select(db.syncRowStates).get(), isEmpty);
      expect(await db.select(db.syncStates).get(), isEmpty);
    },
  );

  test('banco novo já nasce com o esquema v13', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.syncStates)
        .insert(SyncStatesCompanion.insert(key: 'device_id', value: 'x'));
    expect(await db.select(db.syncStates).get(), hasLength(1));
  });

  test('migra v10 para v13 preservando rotinas simples', () async {
    final directory = await Directory.systemTemp.createTemp('s2p_routine_v10_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}planner.sqlite',
    );

    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE routines (
        id TEXT NOT NULL,
        name TEXT NOT NULL,
        details TEXT,
        weekdays INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id)
      );
      CREATE TABLE routine_items (
        id TEXT NOT NULL,
        routine_id TEXT NOT NULL REFERENCES routines (id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        details TEXT,
        position INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id)
      );
      CREATE TABLE routine_completions (
        routine_item_id TEXT NOT NULL REFERENCES routine_items (id) ON DELETE CASCADE,
        date TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        PRIMARY KEY (routine_item_id, date)
      );
      INSERT INTO routines VALUES ('r1', 'Antiga', NULL, 1, 1000, 1000);
      INSERT INTO routine_items VALUES ('i1', 'r1', 'Alongar', NULL, 0, 1000, 1000);
      INSERT INTO routine_completions VALUES ('i1', '2026-11-04', 1000);
      PRAGMA user_version = 10;
    ''');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final routines = await DriftRoutineRepository(db).loadAll();
    expect(routines.single.id, 'r1');
    expect(routines.single.mode, RoutineMode.simple);
    expect(routines.single.items.single.title, 'Alongar');
    expect(routines.single.items.single.completedDates, {
      DateOnly(2026, 11, 4),
    });
    expect(routines.single.sections, isEmpty);
    expect(await db.select(db.syncBases).get(), isEmpty);
  });

  test('migra tom de tag removido para a matiz terciária', () async {
    final directory = await Directory.systemTemp.createTemp('s2p_tag_tone_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}planner.sqlite',
    );

    final raw = sqlite.sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE tags (
        id TEXT NOT NULL,
        name TEXT NOT NULL,
        tone TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        PRIMARY KEY (id)
      );
      INSERT INTO tags VALUES (
        't1', 'Antiga', 'tertiarySoft', 1000, 1000, NULL
      );
      PRAGMA user_version = 7;
    ''');
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final tags = await db.select(db.tags).get();
    expect(tags.single.tone, TagTone.tertiary);
  });
}
