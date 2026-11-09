import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stick2planner/data/db/app_database.dart';

void main() {
  test('conexão em arquivo usa WAL e espera por lock', () async {
    final directory = await Directory.systemTemp.createTemp('s2p_db_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'planner.sqlite'));

    final db = AppDatabase(
      NativeDatabase(file, setup: AppDatabase.configureConnection),
    );
    addTearDown(db.close);

    final journal = await db.customSelect('PRAGMA journal_mode').getSingle();
    expect((journal.data['journal_mode'] as String).toLowerCase(), 'wal');
    final busy = await db.customSelect('PRAGMA busy_timeout').getSingle();
    expect(busy.data['timeout'], 5000);
  });
}
