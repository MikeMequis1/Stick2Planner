import 'package:drift/drift.dart';

import '../../domain/repositories/settings_repository.dart';
import '../db/app_database.dart';

final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, String>> loadAll() async {
    final rows = await _db.select(_db.appSettings).get();
    return {for (final row in rows) row.key: row.value};
  }

  @override
  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(key: Value(key), value: Value(value)),
        );
  }

  @override
  Future<void> writeAll(Map<String, String> values) {
    return _db.transaction(() async {
      for (final entry in values.entries) {
        await write(entry.key, entry.value);
      }
    });
  }
}
