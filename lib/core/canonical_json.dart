import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Codificação JSON canônica usada em backups e checksums.
///
/// Regras:
/// - objetos com chaves ordenadas por code units UTF-16;
/// - sem espaços ou quebras de linha insignificantes;
/// - apenas inteiros (`double` integral é convertido; fracionário é erro);
/// - strings com escape mínimo (UTF-8 literal para não-ASCII);
/// - ordem de listas preservada.
String canonicalJsonEncode(Object? value) {
  final buffer = StringBuffer();
  _write(value, buffer);
  return buffer.toString();
}

/// SHA-256 hexadecimal (minúsculo) dos bytes UTF-8 de [value] canônico.
String canonicalSha256(Object? value) =>
    sha256.convert(utf8.encode(canonicalJsonEncode(value))).toString();

void _write(Object? value, StringBuffer out) {
  if (value == null) {
    out.write('null');
    return;
  }
  if (value is bool) {
    out.write(value ? 'true' : 'false');
    return;
  }
  if (value is String) {
    out.write(jsonEncode(value));
    return;
  }
  if (value is int) {
    out.write(value.toString());
    return;
  }
  if (value is double) {
    if (!value.isFinite || value != value.roundToDouble()) {
      throw ArgumentError.value(
        value,
        'value',
        'JSON canônico aceita apenas inteiros.',
      );
    }
    out.write(value.toInt().toString());
    return;
  }
  if (value is List) {
    out.write('[');
    for (var index = 0; index < value.length; index++) {
      if (index > 0) out.write(',');
      _write(value[index], out);
    }
    out.write(']');
    return;
  }
  if (value is Map) {
    final keys = <String>[];
    for (final key in value.keys) {
      if (key is! String) {
        throw ArgumentError.value(key, 'key', 'Chaves precisam ser strings.');
      }
      keys.add(key);
    }
    keys.sort();
    out.write('{');
    for (var index = 0; index < keys.length; index++) {
      if (index > 0) out.write(',');
      out.write(jsonEncode(keys[index]));
      out.write(':');
      _write(value[keys[index]], out);
    }
    out.write('}');
    return;
  }
  throw ArgumentError.value(
    value,
    'value',
    'Tipo não suportado no JSON canônico: ${value.runtimeType}.',
  );
}
