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

int dateTimeToStorage(DateTime value) => value.toUtc().millisecondsSinceEpoch;

DateTime dateTimeFromStorage(int value) =>
    DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
