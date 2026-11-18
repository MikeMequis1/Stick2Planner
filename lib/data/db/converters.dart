import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/date_only.dart';
import '../../domain/entities/post_it.dart';

/// Persiste [DateOnly] como `aaaa-mm-dd`.
final class DateOnlyConverter extends TypeConverter<DateOnly, String> {
  const DateOnlyConverter();

  @override
  DateOnly fromSql(String fromDb) => DateOnly.parse(fromDb);

  @override
  String toSql(DateOnly value) => value.toIso8601String();
}

/// Persiste listas de IDs de tags como JSON.
final class TagIdsConverter extends TypeConverter<List<String>, String> {
  const TagIdsConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return [
      for (final value in decoded)
        if (value is String && value.isNotEmpty) value,
    ];
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Persiste estados de ocorrências recorrentes como `{"aaaa-mm-dd":"done"}`.
final class OccurrenceStatusesConverter
    extends TypeConverter<Map<DateOnly, PostItStatus>, String> {
  const OccurrenceStatusesConverter();

  @override
  Map<DateOnly, PostItStatus> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! Map) return const {};
    final result = <DateOnly, PostItStatus>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String || entry.value is! String) continue;
      final status = _statusByName(entry.value as String);
      if (status == null) continue;
      try {
        result[DateOnly.parse(entry.key as String)] = status;
      } on Object {
        // Ignora entradas inválidas sem descartar o restante.
      }
    }
    return result;
  }

  @override
  String toSql(Map<DateOnly, PostItStatus> value) => jsonEncode({
    for (final entry in value.entries)
      entry.key.toIso8601String(): entry.value.name,
  });

  static PostItStatus? _statusByName(String name) {
    for (final status in PostItStatus.values) {
      if (status.name == name) return status;
    }
    return null;
  }
}

int dateTimeToStorage(DateTime value) => value.toUtc().millisecondsSinceEpoch;

DateTime dateTimeFromStorage(int value) =>
    DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
