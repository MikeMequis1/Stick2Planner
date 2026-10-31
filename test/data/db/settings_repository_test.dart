import 'package:drift/native.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftSettingsRepository', () {
    test('grava, sobrescreve e lê preferências', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = DriftSettingsRepository(db);

      await repository.write('planner.selectedDate', '2026-10-31');
      await repository.write('planner.selectedDate', '2026-11-01');
      await repository.writeAll({'planner.viewMode.portrait': 'fourDays'});

      final all = await repository.loadAll();
      expect(all['planner.selectedDate'], '2026-11-01');
      expect(all['planner.viewMode.portrait'], 'fourDays');
      expect(await repository.read('inexistente'), isNull);
    });
  });
}
