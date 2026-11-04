import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'sync_models.dart';

final class ServerHealth {
  const ServerHealth({
    required this.ok,
    required this.version,
    required this.serverId,
  });

  final bool ok;
  final String version;
  final String serverId;
}

final class PairResult {
  const PairResult({required this.deviceId, required this.token});

  final String deviceId;
  final String token;
}

/// Contrato mínimo do transporte, para testes sem rede.
abstract interface class SyncTransport {
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  });

  Future<ServerHealth> health();

  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  });
}

final class HttpSyncTransport implements SyncTransport {
  HttpSyncTransport({
    required Uri baseUrl,
    required this.token,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : baseUrl = _normalize(baseUrl),
       _client = client ?? http.Client();

  final Uri baseUrl;
  final String token;
  final Duration timeout;
  final http.Client _client;

  static Uri _normalize(Uri uri) {
    var path = uri.path;
    if (path.endsWith('/')) path = path.substring(0, path.length - 1);
    return uri.replace(path: path);
  }

  Uri _endpoint(String path) => baseUrl.replace(path: '${baseUrl.path}$path');

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    final json = await _post('/v1/sync', {
      'deviceId': deviceId,
      'since': since,
      'limit': limit,
      'changes': [for (final change in changes) change.toJson()],
    });
    return SyncResponse.fromJson(json);
  }

  @override
  Future<ServerHealth> health() async {
    final json = await _get('/v1/health');
    return ServerHealth(
      ok: json['ok'] == true,
      version: json['version'] as String? ?? '',
      serverId: json['serverId'] as String? ?? '',
    );
  }

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) async {
    final json = await _post('/v1/pair', {
      'pairingToken': pairingToken,
      'deviceId': deviceId,
      'deviceName': deviceName,
    });
    final resultDevice = json['deviceId'];
    final token = json['token'];
    if (resultDevice is! String || token is! String) {
      throw const SyncException('resposta de pareamento inválida');
    }
    return PairResult(deviceId: resultDevice, token: token);
  }

  Future<Map<String, Object?>> _get(String path) async {
    final response = await _send(
      () => _client.get(_endpoint(path), headers: _headers()),
    );
    return _decode(response);
  }

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint(path),
        headers: _headers(),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Map<String, String> _headers() => {
    'content-type': 'application/json',
    if (token.isNotEmpty) 'authorization': 'Bearer $token',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const SyncException('tempo esgotado', retryable: true);
    } on SocketException catch (error) {
      throw SyncException('sem conexão: ${error.message}', retryable: true);
    } on http.ClientException catch (error) {
      throw SyncException('falha de rede: ${error.message}', retryable: true);
    }
  }

  Map<String, Object?> _decode(http.Response response) {
    final status = response.statusCode;
    if (status == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, Object?>.from(decoded);
      throw const SyncException('resposta inválida');
    }
    throw SyncException(
      'HTTP $status',
      statusCode: status,
      retryable: status == 429 || status >= 500,
    );
  }
}
