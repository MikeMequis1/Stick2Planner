import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:qr/qr.dart';
import 'package:shelf/shelf.dart';

import 'db.dart';

/// Sessões em memória para a página administrativa de pareamento.
final class AdminSessions {
  AdminSessions({this.ttl = const Duration(hours: 12)});

  final Duration ttl;
  final Map<String, DateTime> _sessions = {};
  final Random _random = Random.secure();

  String create() {
    final token = base64Url
        .encode(List<int>.generate(24, (_) => _random.nextInt(256)))
        .replaceAll('=', '');
    _sessions[token] = DateTime.now().toUtc().add(ttl);
    return token;
  }

  bool valid(String? token) {
    if (token == null) return false;
    final expiry = _sessions[token];
    if (expiry == null) return false;
    if (expiry.isBefore(DateTime.now().toUtc())) {
      _sessions.remove(token);
      return false;
    }
    return true;
  }

  void remove(String? token) {
    if (token != null) _sessions.remove(token);
  }
}

const _sessionCookie = 'planner_admin';

/// Página de login/dashboard e APIs usadas por ela.
Future<Response?> adminWebRoute(
  Request request,
  PlannerDb db,
  String adminToken,
  AdminSessions sessions,
) async {
  final path = request.url.path;
  final session = _cookie(request, _sessionCookie);

  if (path == '' && request.method == 'GET') {
    return sessions.valid(session) ? _dashboard(db) : _loginPage();
  }
  if (path == 'login' && request.method == 'POST') {
    return _login(request, adminToken, sessions);
  }
  if (path == 'logout' && request.method == 'POST') {
    sessions.remove(session);
    return _redirect('/');
  }
  if (path == 'api/pairing' && request.method == 'GET') {
    if (!sessions.valid(session)) return _json(401, {'error': 'unauthorized'});
    final base = _baseUrl(request);
    final created = db.createPairingToken(ttl: const Duration(seconds: 300));
    final payload = jsonEncode({
      'v': 1,
      'u': base,
      's': db.serverId,
      'p': created.token,
    });
    return _json(200, {
      'url': base,
      'serverId': db.serverId,
      'pairingToken': created.token,
      'expiresAt': created.expiresAt,
      'ttlMs': 300 * 1000,
      'svg': qrSvg(payload),
    });
  }
  if (path == 'api/devices' && request.method == 'GET') {
    if (!sessions.valid(session)) return _json(401, {'error': 'unauthorized'});
    return _json(200, {'devices': db.listDevices()});
  }
  if (path.startsWith('api/devices/') &&
      path.endsWith('/label') &&
      request.method == 'POST') {
    if (!sessions.valid(session)) return _json(401, {'error': 'unauthorized'});
    final segments = path.split('/');
    if (segments.length < 4) return _json(400, {'error': 'invalid_device'});
    final id = segments[2];
    final body = await _readJson(request);
    final label = (body?['label'] as String?)?.trim() ?? '';
    if (label.isEmpty || label.length > 64) {
      return _json(400, {'error': 'invalid_label'});
    }
    if (!db.renameDevice(id, label)) {
      return _json(404, {'error': 'not_found'});
    }
    return _json(200, {'label': label});
  }
  if (path.startsWith('api/devices/') &&
      path.endsWith('/revoke') &&
      request.method == 'POST') {
    if (!sessions.valid(session)) return _json(401, {'error': 'unauthorized'});
    final segments = path.split('/');
    if (segments.length < 4) return _json(400, {'error': 'invalid_device'});
    final id = segments[2];
    final revoked = db.revokeDevice(id);
    if (!revoked) return _json(404, {'error': 'not_found'});
    return _json(200, {'revoked': true});
  }

  return null;
}

Future<Response> _login(
  Request request,
  String adminToken,
  AdminSessions sessions,
) async {
  final body = await request.readAsString();
  final form = Uri.splitQueryString(body);
  final token = (form['token'] ?? '').trim();
  if (token.isEmpty || hashToken(token) != hashToken(adminToken)) {
    return Response(
      401,
      body: _loginHtml(error: 'Token administrativo inválido.'),
      headers: _htmlHeaders,
    );
  }
  final session = sessions.create();
  return Response(
    303,
    headers: {
      'location': '/',
      'set-cookie':
          '$_sessionCookie=$session; Path=/; HttpOnly; SameSite=Strict; Max-Age=43200',
    },
  );
}

Response _dashboard(PlannerDb db) => Response(
  200,
  body: _dashboardHtml(serverId: db.serverId),
  headers: _htmlHeaders,
);

Response _loginPage({String? error}) => Response(
  200,
  body: _loginHtml(error: error),
  headers: _htmlHeaders,
);

const _htmlHeaders = {
  'content-type': 'text/html; charset=utf-8',
  'cache-control': 'no-store',
  'x-frame-options': 'DENY',
  'referrer-policy': 'no-referrer',
};

Response _json(int status, Map<String, Object?> body) => Response(
  status,
  body: jsonEncode(body),
  headers: {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
  },
);

Response _redirect(String location) =>
    Response(303, headers: {'location': location});

String? _cookie(Request request, String name) {
  final raw = request.headers['cookie'];
  if (raw == null) return null;
  for (final part in raw.split(';')) {
    final trimmed = part.trim();
    if (trimmed.startsWith('$name=')) {
      return trimmed.substring(name.length + 1);
    }
  }
  return null;
}

String _baseUrl(Request request) {
  final forwarded = request.headers['x-forwarded-proto']
      ?.split(',')
      .first
      .trim();
  final proto = (forwarded == null || forwarded.isEmpty)
      ? request.requestedUri.scheme
      : forwarded;
  final host =
      request.headers['x-forwarded-host']?.split(',').first.trim() ??
      request.headers['host'] ??
      request.requestedUri.authority;
  return '$proto://$host';
}

Future<Map<String, Object?>?> _readJson(Request request) async {
  final text = await request.readAsString();
  if (text.isEmpty) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is Map) return Map<String, Object?>.from(decoded);
  } on FormatException {
    return null;
  }
  return null;
}

/// Gera um QR Code em SVG (texto puro, sem dependências nativas).
String qrSvg(String data, {int moduleSize = 6, int quiet = 4}) {
  final code = QrCode(
    payload: QrPayload.fromString(data),
    errorCorrectLevel: QrErrorCorrectLevel.medium,
  );
  final image = QrImage(code);
  final count = image.moduleCount;
  final size = (count + quiet * 2) * moduleSize;
  final buffer = StringBuffer(
    '<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" '
    'viewBox="0 0 $size $size" shape-rendering="crispEdges" role="img" '
    'aria-label="QR de pareamento">',
  );
  buffer.write('<rect width="$size" height="$size" fill="#ffffff"/>');
  for (var row = 0; row < count; row++) {
    for (var col = 0; col < count; col++) {
      if (!image.isDark(row, col)) continue;
      final x = (col + quiet) * moduleSize;
      final y = (row + quiet) * moduleSize;
      buffer.write(
        '<rect x="$x" y="$y" width="$moduleSize" height="$moduleSize" '
        'fill="#101010"/>',
      );
    }
  }
  buffer.write('</svg>');
  return buffer.toString();
}

String _loginHtml({String? error}) =>
    '''
<!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Stick2Planner · Pareamento</title>
<style>
  :root { color-scheme: dark; }
  body { margin:0; min-height:100vh; display:grid; place-items:center;
    background: radial-gradient(1200px 600px at 20% 0%, #12352a, #0b1411 60%);
    color:#e7f2ed; font:16px/1.5 system-ui, sans-serif; }
  form { width:min(420px, 92vw); background:#121c18cc; border:1px solid #2a3a33;
    border-radius:16px; padding:28px; box-shadow:0 18px 60px #0008; }
  h1 { font-size:20px; margin:0 0 8px; }
  p { margin:0 0 18px; color:#a9bdb4; font-size:14px; }
  input { width:100%; box-sizing:border-box; padding:12px 14px; border-radius:10px;
    border:1px solid #355047; background:#0d1613; color:#e7f2ed; font-size:15px; }
  button { margin-top:14px; width:100%; padding:12px 14px; border:0; border-radius:10px;
    background:#59d3a2; color:#062018; font-weight:700; font-size:15px; cursor:pointer; }
  .err { color:#ff9d9d; margin:0 0 14px; font-size:14px; }
</style></head><body>
<form method="post" action="/login">
  <h1>Stick2Planner · Pareamento</h1>
  <p>Informe o token administrativo (<code>ADMIN_TOKEN</code>) para ver o QR e os
     dispositivos pareados.</p>
  ${error == null ? '' : '<p class="err">${const HtmlEscape().convert(error)}</p>'}
  <input type="password" name="token" placeholder="ADMIN_TOKEN" autofocus required>
  <button type="submit">Entrar</button>
</form>
</body></html>
''';

String _dashboardHtml({required String serverId}) =>
    '''
<!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Stick2Planner · Pareamento</title>
<style>
  :root { color-scheme: dark; }
  body { margin:0; padding:28px 18px; background:
    radial-gradient(1400px 700px at 10% 0%, #12352a, #0b1411 55%);
    color:#e7f2ed; font:16px/1.5 system-ui, sans-serif; }
  main { max-width:1050px; margin:0 auto; display:grid; gap:20px;
    grid-template-columns:minmax(280px, 380px) 1fr; }
  @media (max-width: 820px) { main { grid-template-columns:1fr; } }
  .card { background:#121c18cc; border:1px solid #2a3a33; border-radius:16px;
    padding:20px; }
  h1 { font-size:20px; margin:0 0 4px; }
  h2 { font-size:15px; margin:0 0 14px; color:#bfd4ca; font-weight:600; }
  .sub { color:#93a89e; font-size:13px; margin:0 0 16px; }
  .qr { background:#fff; border-radius:12px; padding:14px; aspect-ratio:1; }
  .qr svg { display:block; width:100%; height:100%; }
  .row { display:flex; justify-content:space-between; align-items:center; gap:12px; }
  .pill { font-size:12px; padding:4px 10px; border-radius:999px;
    background:#1b3a2e; color:#8ff0c4; border:1px solid #2f6b52; }
  code, textarea { font-family:ui-monospace, monospace; font-size:12px; }
  textarea { width:100%; box-sizing:border-box; height:54px; resize:vertical;
    background:#0d1613; color:#cfe6dc; border:1px solid #2f4a40; border-radius:10px;
    padding:8px; }
  button { padding:9px 14px; border-radius:10px; border:1px solid #355047;
    background:#16241f; color:#d9eee5; cursor:pointer; font-size:14px; }
  button.primary { background:#59d3a2; color:#062018; border-color:#59d3a2;
    font-weight:700; }
  button.danger { border-color:#6d3232; color:#ffadad; background:#221314; }
  table { width:100%; border-collapse:collapse; font-size:14px; }
  th, td { text-align:left; padding:9px 6px; border-bottom:1px solid #22332c; }
  th { color:#93a89e; font-weight:600; font-size:12px; text-transform:uppercase;
    letter-spacing:.04em; }
  .muted { color:#7f948b; font-size:12px; }
  .actions { display:flex; gap:10px; flex-wrap:wrap; margin-top:12px; }
</style></head><body>
<main>
  <section class="card">
    <div class="row"><h1>Pareamento</h1><span class="pill" id="server">$serverId</span></div>
    <p class="sub">Escaneie o QR no app ou copie o código abaixo. O código é
       renovado enquanto esta página estiver aberta.</p>
    <div class="qr" id="qr"></div>
    <div class="row" style="margin-top:12px">
      <span class="muted" id="countdown">gerando…</span>
      <button id="refresh">Novo código</button>
    </div>
    <textarea id="code" readonly aria-label="Código de pareamento"></textarea>
    <div class="actions">
      <button class="primary" id="copy">Copiar código</button>
      <form method="post" action="/logout"><button class="danger">Sair</button></form>
    </div>
  </section>
  <section class="card">
    <h2>Dispositivos pareados</h2>
    <table><thead><tr><th>Dispositivo</th><th>Último acesso</th><th>Estado</th><th></th></tr></thead>
      <tbody id="devices"><tr><td colspan="4" class="muted">carregando…</td></tr></tbody>
    </table>
    <p class="muted" style="margin-top:12px">Revogar remove o acesso do token
       imediatamente; o dispositivo pode ser pareado de novo.</p>
  </section>
</main>
<script>
let expiresAt = 0, refreshTimer = null;
const qr = document.getElementById('qr');
const code = document.getElementById('code');
const countdown = document.getElementById('countdown');
document.getElementById('refresh').onclick = loadPairing;
document.getElementById('copy').onclick = async () => {
  try { await navigator.clipboard.writeText(code.value); } catch (_) { code.select(); }
};
async function loadPairing() {
  const res = await fetch('/api/pairing', {cache:'no-store'});
  if (!res.ok) { location = '/'; return; }
  const data = await res.json();
  qr.innerHTML = data.svg;
  code.value = data.url + '|' + data.pairingToken;
  expiresAt = Date.now() + data.ttlMs;
  clearTimeout(refreshTimer);
  refreshTimer = setTimeout(loadPairing, Math.max(5000, data.ttlMs - 30000));
  tick();
}
function tick() {
  const left = Math.max(0, Math.round((expiresAt - Date.now()) / 1000));
  countdown.textContent = left > 0 ? 'expira em ' + left + 's' : 'expirado';
  if (left === 0) loadPairing();
}
async function loadDevices() {
  const res = await fetch('/api/devices', {cache:'no-store'});
  if (!res.ok) { location = '/'; return; }
  const data = await res.json();
  const body = document.getElementById('devices');
  if (!data.devices.length) {
    body.innerHTML = '<tr><td colspan="4" class="muted">nenhum dispositivo</td></tr>';
    return;
  }
  body.innerHTML = data.devices.map((d) => {
    const seen = d.lastSeenAt ? new Date(d.lastSeenAt).toLocaleString() : '—';
    const state = d.revokedAt ? 'revogado' : 'ativo';
    const action = d.revokedAt ? '' :
      '<button data-rename="' + d.deviceId + '">Renomear</button> ' +
      '<button class="danger" data-id="' + d.deviceId + '">Revogar</button>';
    return '<tr><td>' + escapeHtml(d.label) + '<div class="muted">' +
      escapeHtml(d.deviceId) + '</div></td><td>' + seen + '</td><td>' + state +
      '</td><td>' + action + '</td></tr>';
  }).join('');
  body.querySelectorAll('button[data-rename]').forEach((button) => {
    button.onclick = async () => {
      const label = prompt('Novo nome do dispositivo', '');
      if (!label || !label.trim()) return;
      await fetch('/api/devices/' + encodeURIComponent(button.dataset.rename) + '/label',
        {method:'POST', headers:{'content-type':'application/json'},
         body: JSON.stringify({label: label.trim()})});
      loadDevices();
    };
  });
  body.querySelectorAll('button[data-id]').forEach((button) => {
    button.onclick = async () => {
      await fetch('/api/devices/' + encodeURIComponent(button.dataset.id) + '/revoke',
        {method:'POST'});
      loadDevices();
    };
  });
}
function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (c) => ({
    '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
  }[c]));
}
loadPairing();
loadDevices();
setInterval(tick, 1000);
setInterval(loadDevices, 5000);
</script>
</body></html>
''';
