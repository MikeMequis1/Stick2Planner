import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/date_only.dart';

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

int dateTimeToStorage(DateTime value) => value.toUtc().millisecondsSinceEpoch;

DateTime dateTimeFromStorage(int value) =>
    DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
