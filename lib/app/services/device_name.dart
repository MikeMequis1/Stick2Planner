import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Nome amigável do aparelho, usado no pareamento e na página web.
///
/// Sem plugin disponível (testes), cai para o hostname ou um rótulo genérico.
Future<String> resolveDeviceName() async {
  try {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final model = info.model.trim();
      if (model.isNotEmpty) return model;
    }
    final hostname = Platform.localHostname.trim();
    if (hostname.isNotEmpty) return hostname;
  } on Object {
    // Plugin indisponível ou sem permissão: usa fallback.
  }
  return 'Dispositivo';
}
