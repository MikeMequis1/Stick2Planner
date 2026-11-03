import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_settings_repository.dart';
import 'package:flutter_schedule/domain/entities/note.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../../helpers/entities.dart';

void main() {
  test('migra banco v1 preservando preferências e criando tabelas', () async {
    final tempDir = await Directory.systemTemp.createTemp('planner_migrate_');
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File(p.join(tempDir.path, 'planner.sqlite'));

    final legacy = sqlite3.open(file.path);
    legacy
      ..execute(
        'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, '
        'value TEXT NOT NULL) STRICT',
      )
      ..execute(
        "INSERT INTO app_settings (key, value) "
        "VALUES ('planner.selectedDate', '2026-10-31')",
      )
      ..execute('PRAGMA user_version = 1');
    legacy.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final settings = await DriftSettingsRepository(db).loadAll();
    expect(settings['planner.selectedDate'], '2026-10-31');

    await DriftPostItRepository(db).save(
      buildPostIt(
        id: 'pos-migracao',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 2),
        endDate: DateOnly(2026, 11, 3),
      ),
    );

    final postIt = await DriftPostItRepository(db).findById('pos-migracao');
    expect(postIt?.endDate, DateOnly(2026, 11, 3));
  });

  test('migra v2 para v3 convertendo texto legado em Markdown', () async {
    final tempDir = await Directory.systemTemp.createTemp('planner_migrate_');
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File(p.join(tempDir.path, 'planner.sqlite'));

    // Cria o esquema atual e o rebaixa removendo a coluna nova, simulando v2.
    final legacyDb = AppDatabase(NativeDatabase(file));
    await legacyDb.customStatement('ALTER TABLE notes DROP COLUMN markdown');
    await legacyDb.customStatement(
      'INSERT INTO notes (id, title, type, created_at, updated_at) '
      "VALUES ('nota-texto', 'Texto legado', 'text', 0, 0)",
    );
    await legacyDb.customStatement(
      'INSERT INTO notes (id, title, type, created_at, updated_at) '
      "VALUES ('nota-lista', 'Lista legada', 'checklist', 0, 0)",
    );
    await legacyDb.customStatement(
      'INSERT INTO note_lines (id, note_id, position, content) '
      r"VALUES ('l1', 'nota-texto', 0, '# Título'), "
      r"('l2', 'nota-texto', 1, 'Parágrafo do texto')",
    );
    await legacyDb.customStatement(
      'INSERT INTO note_lines (id, note_id, position, content, is_checked) '
      "VALUES ('c1', 'nota-lista', 0, 'Comprar pão', 0), "
      "('c2', 'nota-lista', 1, 'Levar água', 1)",
    );
    await legacyDb.customStatement('PRAGMA user_version = 2');
    await legacyDb.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final notes = await DriftNoteRepository(db).loadAll();
    final textNote = notes.singleWhere((note) => note.id == 'nota-texto');
    expect(textNote.markdown, '# Título\nParágrafo do texto');
    expect(textNote.lines, isEmpty);

    final checklist = notes.singleWhere((note) => note.id == 'nota-lista');
    expect(checklist.markdown, isNull);
    expect(checklist.type, NoteType.checklist);
    expect(checklist.lines.map((line) => line.text), [
      'Comprar pão',
      'Levar água',
    ]);
    expect(checklist.lines[1].isChecked, isTrue);
  });
}
