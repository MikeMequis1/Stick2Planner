import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:stick2planner_server/src/api.dart';
import 'package:stick2planner_server/src/db.dart';
import 'package:test/test.dart';

void main() {
  late PlannerDb db;
  late Handler handler;

  setUp(() {
    db = PlannerDb.memory();
    handler = buildHandler(db: db, adminToken: 'admin-token');
  });

  tearDown(() => db.close());

  Future<({int status, String text, Map<String, String> headers})> raw(
    String method,
    String path, {
    Object? body,
    String? token,
    Map<String, String> headers = const {},
    bool form = false,
  }) async {
    final request = Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? null : (form ? body as String : jsonEncode(body)),
      headers: {
        if (token != null) 'authorization': 'Bearer $token',
        if (!form) 'content-type': 'application/json',
        if (form) 'content-type': 'application/x-www-form-urlencoded',
        ...headers,
      },
    );
    final response = await handler(request);
    return (
      status: response.statusCode,
      text: await response.readAsString(),
      headers: response.headers,
    );
  }

  Future<({int status, Map<String, Object?> body})> call(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
  }) async {
    final response = await raw(method, path, body: body, token: token);
    return (
      status: response.status,
      body: response.text.isEmpty
          ? <String, Object?>{}
          : Map<String, Object?>.from(jsonDecode(response.text) as Map),
    );
  }

  Future<String> pairDevice({String deviceId = 'device-1'}) async {
    final created = await call(
      'POST',
      '/v1/admin/pairing-tokens',
      token: 'admin-token',
    );
    final pairingToken = created.body['pairingToken'] as String;
    final paired = await call(
      'POST',
      '/v1/pair',
      body: {
        'pairingToken': pairingToken,
        'deviceId': deviceId,
        'deviceName': 'Tablet',
      },
    );
    expect(paired.status, 200);
    return paired.body['token'] as String;
  }

  Map<String, Object?> change({
    required String changeId,
    required String entityId,
    int baseRev = 0,
    String title = 'Post-it',
    int updatedAt = 1000,
  }) => {
    'changeId': changeId,
    'entity': 'postIt',
    'entityId': entityId,
    'baseRev': baseRev,
    'updatedAt': updatedAt,
    'deleted': false,
    'payload': jsonEncode({'id': entityId, 'title': title}),
  };

  test('health não exige autenticação', () async {
    final response = await call('GET', '/v1/health');
    expect(response.status, 200);
    expect(response.body['ok'], isTrue);
    expect(response.body['serverId'], isA<String>());
  });

  test('pareamento consome o token uma única vez', () async {
    final token = await pairDevice();
    expect(token, isNotEmpty);

    final created = await call(
      'POST',
      '/v1/admin/pairing-tokens',
      token: 'admin-token',
    );
    final pairingToken = created.body['pairingToken'] as String;
    final first = await call(
      'POST',
      '/v1/pair',
      body: {
        'pairingToken': pairingToken,
        'deviceId': 'device-2',
        'deviceName': 'Celular',
      },
    );
    final second = await call(
      'POST',
      '/v1/pair',
      body: {
        'pairingToken': pairingToken,
        'deviceId': 'device-3',
        'deviceName': 'Outro',
      },
    );
    expect(first.status, 200);
    expect(second.status, 401);
  });

  test('sync exige token de dispositivo', () async {
    final response = await call(
      'POST',
      '/v1/sync',
      body: {'deviceId': 'device-1', 'since': 0, 'changes': []},
    );
    expect(response.status, 401);
  });

  test('push novo grava rev 1 e o pull devolve a mudança', () async {
    final token = await pairDevice();
    final push = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': 0,
        'changes': [change(changeId: 'c1', entityId: 'p1')],
      },
    );

    expect(push.status, 200);
    expect((push.body['acks'] as List).single, containsPair('rev', 1));

    final pulled = push.body['changes'] as List;
    expect(pulled, hasLength(1));
    expect(pulled.single, containsPair('entityId', 'p1'));
    expect(pulled.single, containsPair('rev', 1));
    expect(push.body['cursor'], isA<int>());
  });

  test('reenviar o mesmo changeId é idempotente', () async {
    final token = await pairDevice();
    final payload = {
      'deviceId': 'device-1',
      'since': 0,
      'changes': [change(changeId: 'c1', entityId: 'p1')],
    };
    final first = await call('POST', '/v1/sync', token: token, body: payload);
    final cursor = first.body['cursor'] as int;

    final again = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {...payload, 'since': cursor},
    );

    expect((again.body['acks'] as List).single, containsPair('rev', 1));
    expect(again.body['changes'], isEmpty);
  });

  test('baseRev divergente vira conflito com a versão do servidor', () async {
    final token = await pairDevice();
    await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': 0,
        'changes': [change(changeId: 'c1', entityId: 'p1')],
      },
    );

    final otherToken = await pairDevice(deviceId: 'device-2');
    final conflict = await call(
      'POST',
      '/v1/sync',
      token: otherToken,
      body: {
        'deviceId': 'device-2',
        'since': 0,
        'changes': [change(changeId: 'c2', entityId: 'p1')],
      },
    );

    expect(conflict.status, 200);
    expect(conflict.body['acks'], isEmpty);
    final server =
        ((conflict.body['conflicts'] as List).single
                as Map<String, Object?>)['server']
            as Map<String, Object?>;
    expect(server['rev'], 1);
  });

  test('pull pagina e devolve cursor para continuar', () async {
    final token = await pairDevice();
    await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': 0,
        'changes': [
          change(changeId: 'c1', entityId: 'p1'),
          change(changeId: 'c2', entityId: 'p2'),
          change(changeId: 'c3', entityId: 'p3'),
        ],
      },
    );

    final first = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {'deviceId': 'device-1', 'since': 0, 'limit': 2, 'changes': []},
    );
    expect((first.body['changes'] as List), hasLength(2));
    expect(first.body['more'], isTrue);

    final cursor = first.body['cursor'] as int;
    final second = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': cursor,
        'limit': 2,
        'changes': [],
      },
    );
    expect((second.body['changes'] as List), hasLength(1));
    expect(second.body['more'], isFalse);
  });

  test('revogar dispositivo invalida o token', () async {
    final token = await pairDevice();
    final revoke = await call(
      'POST',
      '/v1/admin/devices/device-1/revoke',
      token: 'admin-token',
    );
    expect(revoke.status, 200);

    final denied = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {'deviceId': 'device-1', 'since': 0, 'changes': []},
    );
    expect(denied.status, 401);
  });

  test('valida entidade e tamanho de payload', () async {
    final token = await pairDevice();
    final badEntity = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': 0,
        'changes': [
          {
            'changeId': 'c1',
            'entity': 'settings',
            'entityId': 'x',
            'baseRev': 0,
            'updatedAt': 1,
            'deleted': false,
            'payload': '{}',
          },
        ],
      },
    );
    expect(badEntity.status, 400);

    final oversize = await call(
      'POST',
      '/v1/sync',
      token: token,
      body: {
        'deviceId': 'device-1',
        'since': 0,
        'changes': [
          change(changeId: 'c2', entityId: 'p1')
            ..['payload'] = 'x' * (1024 * 1024 + 1),
        ],
      },
    );
    expect(oversize.status, 413);
  });

  test('página web exige login e gera QR vivo', () async {
    final page = await raw('GET', '/');
    expect(page.status, 200);
    expect(page.text, contains('ADMIN_TOKEN'));

    final denied = await raw(
      'POST',
      '/login',
      body: 'token=errado',
      form: true,
    );
    expect(denied.status, 401);

    final login = await raw(
      'POST',
      '/login',
      body: 'token=admin-token',
      form: true,
    );
    expect(login.status, 303);
    final cookie = login.headers['set-cookie']!.split(';').first;
    expect(cookie, startsWith('planner_admin='));

    final pair = await raw('GET', '/api/pairing', headers: {'cookie': cookie});
    expect(pair.status, 200);
    final payload = jsonDecode(pair.text) as Map<String, Object?>;
    expect(payload['pairingToken'], isA<String>());
    expect((payload['pairingToken'] as String), isNotEmpty);
    expect(payload['url'], 'http://localhost');
    expect(payload['svg'], startsWith('<svg'));
    expect(payload['ttlMs'], 300000);

    final devices = await raw(
      'GET',
      '/api/devices',
      headers: {'cookie': cookie},
    );
    expect(devices.status, 200);
    expect((jsonDecode(devices.text) as Map)['devices'], isEmpty);

    final noCookie = await raw('GET', '/api/pairing');
    expect(noCookie.status, 401);

    await pairDevice(deviceId: 'web-device');
    final renamed = await raw(
      'POST',
      '/api/devices/web-device/label',
      headers: {'cookie': cookie},
      body: {'label': 'Sala'},
    );
    expect(renamed.status, 200);
    final renamedList = await raw(
      'GET',
      '/api/devices',
      headers: {'cookie': cookie},
    );
    final devicesJson = jsonDecode(renamedList.text) as Map;
    expect(
      (devicesJson['devices'] as List).any(
        (device) => (device as Map)['label'] == 'Sala',
      ),
      isTrue,
    );

    final invalid = await raw(
      'POST',
      '/api/devices/web-device/label',
      headers: {'cookie': cookie},
      body: {'label': '  '},
    );
    expect(invalid.status, 400);

    final revoked = await raw(
      'POST',
      '/api/devices/inexistente/revoke',
      headers: {'cookie': cookie},
    );
    expect(revoked.status, 404);
  });

  test('dashboard exige sessão', () async {
    final page = await raw('GET', '/');
    expect(page.status, 200);
    expect(page.text, contains('token administrativo'));

    final login = await raw(
      'POST',
      '/login',
      body: 'token=admin-token',
      form: true,
    );
    final cookie = login.headers['set-cookie']!.split(';').first;
    final dashboard = await raw('GET', '/', headers: {'cookie': cookie});
    expect(dashboard.status, 200);
    expect(dashboard.text, contains('Dispositivos pareados'));
    expect(dashboard.text, contains('/api/pairing'));
  });

  test('admin exige token administrativo', () async {
    final response = await call('POST', '/v1/admin/pairing-tokens');
    expect(response.status, 401);
  });
}
