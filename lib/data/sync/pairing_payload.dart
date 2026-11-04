import 'dart:convert';

/// Conteúdo do QR/código de pareamento gerado pelo servidor.
///
/// Aceita o JSON completo (`{"v":1,"u":"...","s":"...","p":"..."}`) ou um
/// objeto com `url`/`pairingToken`, além de `url|token`.
final class PairingPayload {
  const PairingPayload({
    required this.url,
    required this.pairingToken,
    this.serverId,
  });

  final Uri url;
  final String pairingToken;
  final String? serverId;

  static PairingPayload parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      throw const FormatException('código de pareamento vazio');
    }

    if (text.contains('|')) {
      final parts = text.split('|');
      if (parts.length != 2) {
        throw const FormatException('código de pareamento inválido');
      }
      return PairingPayload(
        url: _parseUrl(parts[0]),
        pairingToken: _require(parts[1]),
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('código de pareamento inválido');
    }
    if (decoded is! Map) {
      throw const FormatException('código de pareamento inválido');
    }

    final url = decoded['u'] ?? decoded['url'];
    final token = decoded['p'] ?? decoded['pairingToken'];
    final serverId = decoded['s'] ?? decoded['serverId'];
    if (url is! String || token is! String) {
      throw const FormatException('código de pareamento incompleto');
    }
    return PairingPayload(
      url: _parseUrl(url),
      pairingToken: _require(token),
      serverId: serverId is String ? serverId : null,
    );
  }

  static Uri _parseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('endereço do servidor inválido');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const FormatException('endereço do servidor inválido');
    }
    return uri;
  }

  static String _require(String value) {
    if (value.trim().isEmpty) {
      throw const FormatException('token de pareamento vazio');
    }
    return value.trim();
  }
}
