import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:stick2planner/data/db/app_database.dart';

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
    'migra v4 para v6 preservando dados e criando tabelas de sync',
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

      expect(db.schemaVersion, 6);

      final notes = await db.select(db.notes).get();
      final postIts = await db.select(db.postIts).get();
      final history = await db.select(db.postItHistoryEntries).get();
      final settings = await db.select(db.appSettings).get();

      expect(notes.single.id, 'n1');
      expect(notes.single.markdown, '# Título');
      expect(postIts.single.id, 'p1');
      expect(postIts.single.sourceNoteId, 'n1');
      expect(history.single.id, 'h1');
      expect(settings.single.value, 'dark');

      expect(await db.select(db.syncOutbox).get(), isEmpty);
      expect(await db.select(db.syncRowStates).get(), isEmpty);
      expect(await db.select(db.syncStates).get(), isEmpty);
    },
  );

  test('banco novo já nasce com o esquema v6', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.syncStates)
        .insert(SyncStatesCompanion.insert(key: 'device_id', value: 'x'));
    expect(await db.select(db.syncStates).get(), hasLength(1));
  });
}
