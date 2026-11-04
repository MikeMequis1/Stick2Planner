import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android declara internet apenas para sincronização opcional', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    // Sincronização é opcional; sem servidor o app continua funcionando.
    expect(manifest.contains('android.permission.INTERNET'), isTrue);

    // Nada de serviço em primeiro plano permanente nem otimização de bateria.
    expect(manifest.contains('FOREGROUND_SERVICE'), isFalse);
    expect(
      manifest.contains('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
      isFalse,
    );
  });
}
