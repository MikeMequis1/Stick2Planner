import 'package:uuid/uuid.dart';

import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';

/// Chaves persistidas em `sync_state`.
abstract final class SyncKeys {
  static const deviceId = 'device_id';
  static const cursor = 'cursor';
  static const serverUrl = 'server_url';
  static const enabled = 'enabled';
  static const lastSyncAt = 'last_sync_at';
  static const lastError = 'last_error';
  static const deviceLabel = 'device_label';
}

/// Estado global de sincronização, sempre local ao aparelho.
final class SyncStateStore {
  SyncStateStore(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.syncStates,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String? value) async {
    if (value == null) {
      await (_db.delete(
        _db.syncStates,
      )..where((table) => table.key.equals(key))).go();
      return;
    }
    await _db
        .into(_db.syncStates)
        .insertOnConflictUpdate(
          SyncStatesCompanion.insert(key: key, value: value),
        );
  }

  /// `deviceId` estável por instalação; criado na primeira leitura.
  Future<String> ensureDeviceId() async {
    final existing = await read(SyncKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _uuid.v4();
    await write(SyncKeys.deviceId, generated);
    return generated;
  }

  Future<int> cursor() async =>
      int.tryParse(await read(SyncKeys.cursor) ?? '') ?? 0;

  Future<void> setCursor(int cursor) =>
      write(SyncKeys.cursor, cursor.toString());

  Future<String?> serverUrl() => read(SyncKeys.serverUrl);

  Future<void> setServerUrl(String? url) => write(SyncKeys.serverUrl, url);

  Future<bool> enabled() async => await read(SyncKeys.enabled) == 'true';

  Future<void> setEnabled(bool enabled) =>
      write(SyncKeys.enabled, enabled.toString());

  Future<DateTime?> lastSyncAt() async {
    final raw = await read(SyncKeys.lastSyncAt);
    final milliseconds = int.tryParse(raw ?? '');
    if (milliseconds == null) return null;
    return dateTimeFromStorage(milliseconds);
  }

  Future<void> setLastSyncAt(DateTime value) =>
      write(SyncKeys.lastSyncAt, dateTimeToStorage(value).toString());

  Future<String?> lastError() => read(SyncKeys.lastError);

  Future<void> setLastError(String? error) => write(SyncKeys.lastError, error);

  Future<String?> deviceLabel() => read(SyncKeys.deviceLabel);

  Future<void> setDeviceLabel(String? label) =>
      write(SyncKeys.deviceLabel, label);
}
