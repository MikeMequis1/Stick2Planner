// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/db/app_database.dart';
import '../../data/sync/pairing_payload.dart';
import '../../data/sync/sync_dataset.dart';
import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_models.dart';
import '../../data/sync/sync_state_store.dart';
import '../../data/sync/sync_transport.dart';
import 'token_store.dart';

typedef SyncTransportFactory = SyncTransport Function(
  Uri baseUrl,
  String token,
);

/// Orquestra configuração, pareamento, gatilhos e execução da sincronização.
final class SyncCoordinator extends ChangeNotifier {
  SyncCoordinator({
    required AppDatabase database,
    required SyncStateStore state,
    required TokenStore tokens,
    SyncTransportFactory? transportFactory,
    this.debounce = const Duration(seconds: 2),
    Stream<bool>? connectivityChanges,
    DateTime Function()? now,
  }) : _db = database,
       _state = state,
       _tokens = tokens,
       _transportFactory =
           transportFactory ??
           ((baseUrl, token) =>
               HttpSyncTransport(baseUrl: baseUrl, token: token)),
       _connectivity = connectivityChanges,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final SyncStateStore _state;
  final TokenStore _tokens;
  final SyncTransportFactory _transportFactory;
  final Stream<bool>? _connectivity;
  final DateTime Function() _now;
  final Duration debounce;

  /// Chamado após um pull que trouxe mudanças remotas.
  Future<void> Function()? onApplied;

  StreamSubscription<List<SyncOutboxRow>>? _outboxWatch;
  StreamSubscription<bool>? _connectivityWatch;
  Timer? _debounceTimer;
  bool _busy = false;
  bool _configured = false;
  bool _enabled = false;
  int _pending = 0;
  String? _serverUrl;
  String? _deviceId;
  String? _pairedDeviceLabel;
  DateTime? _lastSyncAt;
  String? _lastError;
  SyncReport? _lastReport;
  SyncPreflight? _pendingPreflight;

  bool get busy => _busy;
  bool get enabled => _enabled;
  bool get configured => _configured;
  int get pendingCount => _pending;
  String? get serverUrl => _serverUrl;
  String? get deviceId => _deviceId;

  /// Rótulo do dispositivo pareado, atualizado pelo servidor quando possível.
  String? get pairedDeviceLabel => _pairedDeviceLabel;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastError => _lastError;
  SyncReport? get lastReport => _lastReport;

  /// Comparação pendente de dados local/remoto; exige escolha do usuário.
  SyncPreflight? get pendingPreflight => _pendingPreflight;

  Future<void> initialize() async {
    _deviceId = await _state.ensureDeviceId();
    _serverUrl = await _state.serverUrl();
    _pairedDeviceLabel = await _state.deviceLabel();
    _enabled = await _state.enabled();
    _lastSyncAt = await _state.lastSyncAt();
    _lastError = await _state.lastError();
    _configured = await _hasCredentials();

    _outboxWatch = _db.select(_db.syncOutbox).watch().listen((rows) {
      _pending = rows.length;
      notifyListeners();
      if (rows.isNotEmpty) _schedule();
    });

    _connectivityWatch = _connectivity?.listen((online) {
      if (online) _schedule(immediate: true);
    });

    notifyListeners();
  }

  Future<bool> _hasCredentials() async {
    final url = await _state.serverUrl();
    String? token;
    try {
      token = await _tokens.read();
    } on Object {
      token = null;
    }
    return url != null && url.isNotEmpty && token != null && token.isNotEmpty;
  }

  Future<void> refreshConfig() async {
    _serverUrl = await _state.serverUrl();
    _enabled = await _state.enabled();
    _configured = await _hasCredentials();
    _pending = (await _db.select(_db.syncOutbox).get()).length;
    notifyListeners();
  }

  Future<void> setServerUrl(String? value) async {
    final normalized = value == null ? null : _normalize(value);
    if (value != null && normalized == null) {
      throw const FormatException('endereço do servidor inválido');
    }
    await _state.setServerUrl(normalized);
    _serverUrl = normalized;
    _pendingPreflight = null;
    _configured = await _hasCredentials();
    notifyListeners();
    if (_enabled) _schedule(immediate: true);
  }

  Future<void> setEnabled(bool value) async {
    await _state.setEnabled(value);
    _enabled = value;
    notifyListeners();
    if (value) {
      _schedule(immediate: true);
    } else {
      _debounceTimer?.cancel();
    }
  }

  /// Testa saúde sem exigir token, para validar o endereço.
  Future<ServerHealth> testConnection(String url) async {
    final normalized = _normalize(url);
    if (normalized == null) {
      throw const FormatException('endereço do servidor inválido');
    }
    return _transportFactory(Uri.parse(normalized), '').health();
  }

  /// Troca código/QR de pareamento por token individual e habilita o sync.
  Future<void> pair(String code, {String deviceName = 'Tablet'}) async {
    final payload = PairingPayload.parse(code);
    _deviceId ??= await _state.ensureDeviceId();
    final transport = _transportFactory(payload.url, '');
    final result = await transport.pair(
      pairingToken: payload.pairingToken,
      deviceId: _deviceId!,
      deviceName: deviceName,
    );
    await _tokens.write(result.token);
    await _state.setServerUrl(_normalize(payload.url.toString()));
    await _state.setEnabled(true);
    _pairedDeviceLabel = deviceName;
    await _state.setDeviceLabel(deviceName);
    _lastError = null;
    _lastReport = null;
    _pendingPreflight = null;
    await refreshConfig();
    _schedule(immediate: true);
  }

  Future<void> disconnect() async {
    await _tokens.clear();
    await _state.setServerUrl(null);
    await _state.setEnabled(false);
    await _state.setDeviceLabel(null);
    _pairedDeviceLabel = null;
    _lastError = null;
    _lastReport = null;
    _pendingPreflight = null;
    await refreshConfig();
  }

  /// Consulta contagens local/remota antes de sincronizar.
  ///
  /// Retorna `null` sem credenciais. Quando há divergência não explicada por
  /// alterações locais, `pendingPreflight` fica preenchido até o usuário
  /// escolher manter local, remoto ou cancelar.
  Future<SyncPreflight?> inspect() async {
    if (!await _hasCredentials()) return null;
    final transport = await _currentTransport();
    final remote = await transport.stats();
    if (remote.deviceLabel.isNotEmpty &&
        remote.deviceLabel != _pairedDeviceLabel) {
      _pairedDeviceLabel = remote.deviceLabel;
      await _state.setDeviceLabel(remote.deviceLabel);
    }
    final local = await SyncDatasetService(_db).counts();
    final pending = (await _db.select(_db.syncOutbox).get()).length;
    final preflight = SyncPreflight(
      local: local,
      remote: remote,
      hasLocalChanges: pending > 0,
      hasSyncedBefore: _lastSyncAt != null,
    );
    _pendingPreflight = preflight.requiresChoice ? preflight : null;
    notifyListeners();
    return preflight;
  }

  Future<SyncReport?> syncNow({
    SyncMode mode = SyncMode.merge,
    bool inspectFirst = true,
  }) async {
    if (_busy) return null;
    if (!await _hasCredentials()) {
      _lastError = 'sync_not_configured';
      notifyListeners();
      return null;
    }
    if (inspectFirst && mode == SyncMode.merge) {
      SyncPreflight? preflight;
      try {
        preflight = await inspect();
      } on Object catch (error) {
        _lastError = error.toString();
        notifyListeners();
        return null;
      }
      if (preflight == null) return null;
      if (preflight.requiresChoice) return null;
    }
    _pendingPreflight = null;
    _busy = true;
    notifyListeners();
    try {
      final transport = await _currentTransport();
      final engine = SyncEngine(
        database: _db,
        transport: transport,
        state: _state,
        now: _now,
      );
      final report = switch (mode) {
        SyncMode.merge => await engine.run(),
        SyncMode.keepLocal => await engine.replaceWithLocal(),
        SyncMode.keepRemote => await engine.replaceWithRemote(),
      };
      _lastReport = report;
      _lastSyncAt = report.finishedAt;
      _lastError = null;
      if (mode == SyncMode.keepRemote ||
          (mode == SyncMode.merge && report.pulled > 0)) {
        try {
          await onApplied?.call();
        } on Object {
          // A falha de refresh não invalida o sync já gravado.
        }
      }
      return report;
    } on Object catch (error) {
      _lastError = error.toString();
      return null;
    } finally {
      _busy = false;
      _pending = (await _db.select(_db.syncOutbox).get()).length;
      notifyListeners();
    }
  }

  Future<SyncTransport> _currentTransport() async {
    final url = (await _state.serverUrl())!;
    final token = (await _tokens.read())!;
    return _transportFactory(Uri.parse(url), token);
  }

  void handleAppResumed() {
    if (_enabled) _schedule(immediate: true);
  }

  void _schedule({bool immediate = false}) {
    if (!_enabled || _pendingPreflight != null) return;
    _debounceTimer?.cancel();
    final delay = immediate ? Duration.zero : debounce;
    _debounceTimer = Timer(delay, () {
      if (!_busy) unawaited(syncNow());
    });
  }

  String? _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return uri.replace(path: path).toString();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _outboxWatch?.cancel();
    _connectivityWatch?.cancel();
    super.dispose();
  }
}
