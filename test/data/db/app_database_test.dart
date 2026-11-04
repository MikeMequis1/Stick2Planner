import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('AppDatabase', () {
    test('grava e lê preferência em banco em memória', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db
          .into(db.appSettings)
          .insert(
            const AppSettingsCompanion(
              key: Value('view.landscape'),
              value: Value('week'),
            ),
          );

      final row = await (db.select(
        db.appSettings,
      )..where((table) => table.key.equals('view.landscape'))).getSingle();

      expect(row.value, 'week');
    });

    test('persiste preferências entre aberturas do banco', () async {
      final tempDir = await Directory.systemTemp.createTemp('planner_db_');
      addTearDown(() => tempDir.delete(recursive: true));
      final file = File(p.join(tempDir.path, 'planner.sqlite'));

      var db = AppDatabase(NativeDatabase(file));
      await db
          .into(db.appSettings)
          .insert(
            const AppSettingsCompanion(
              key: Value('selectedDate'),
              value: Value('2026-10-31'),
            ),
          );
      await db.close();

      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final row = await (db.select(
        db.appSettings,
      )..where((table) => table.key.equals('selectedDate'))).getSingle();

      expect(row.value, '2026-10-31');
    });
  });
}
