import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/data/sync/pairing_payload.dart';

void main() {
  test('aceita JSON compacto do QR', () {
    final payload = PairingPayload.parse(
      '{"v":1,"u":"http://192.168.0.10:8090","s":"abc","p":"tok"}',
    );
    expect(payload.url.toString(), 'http://192.168.0.10:8090');
    expect(payload.pairingToken, 'tok');
    expect(payload.serverId, 'abc');
  });

  test('aceita url|token', () {
    final payload = PairingPayload.parse('https://host:8443|ABC123');
    expect(payload.url.scheme, 'https');
    expect(payload.pairingToken, 'ABC123');
  });

  test('recusa formato, URL e token inválidos', () {
    expect(() => PairingPayload.parse(''), throwsFormatException);
    expect(() => PairingPayload.parse('{}'), throwsFormatException);
    expect(
      () => PairingPayload.parse('{"u":"ftp://x","p":"t"}'),
      throwsFormatException,
    );
    expect(
      () => PairingPayload.parse('{"u":"http://x","p":" "}'),
      throwsFormatException,
    );
    expect(() => PairingPayload.parse('a|b|c'), throwsFormatException);
  });
}
