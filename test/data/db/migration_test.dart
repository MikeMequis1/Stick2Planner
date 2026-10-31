import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_settings_repository.dart';
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
}
