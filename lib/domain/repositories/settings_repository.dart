/// Contrato de preferências persistidas localmente.
abstract interface class SettingsRepository {
  Future<Map<String, String>> loadAll();

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> writeAll(Map<String, String> values);
}
