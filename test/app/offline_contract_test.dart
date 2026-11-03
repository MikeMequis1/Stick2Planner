import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android não declara permissão de internet', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest.contains('android.permission.INTERNET'),
      isFalse,
      reason: 'O app deve continuar totalmente offline nesta etapa.',
    );
  });
}
