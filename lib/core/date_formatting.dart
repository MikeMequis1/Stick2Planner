import 'package:intl/intl.dart';

import 'date_only.dart';

/// Formatação de datas em pt_BR.
///
/// Requer `initializeDateFormatting('pt_BR')` uma vez na inicialização.
abstract final class DateFormats {
  static String fullDate(DateOnly date) {
    final formatted = DateFormat(
      "EEEE, d 'de' MMMM 'de' y",
      'pt_BR',
    ).format(date.toLocalDateTime());
    return _capitalize(formatted);
  }

  static String shortDate(DateOnly date) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(date.toLocalDateTime());

  static String dayAndMonth(DateOnly date) =>
      DateFormat('d MMM', 'pt_BR').format(date.toLocalDateTime());

  static String monthYear(DateOnly date) => _capitalize(
    DateFormat('MMMM y', 'pt_BR').format(date.toLocalDateTime()),
  );

  /// "seg", "ter"… sem ponto final.
  static String weekdayShort(DateOnly date) {
    final formatted = DateFormat('EEE', 'pt_BR').format(date.toLocalDateTime());
    return _capitalize(formatted.replaceAll('.', ''));
  }

  /// "2 – 8 nov 2026" ou "30 nov – 6 dez 2026".
  static String dateRangeShort(DateOnly start, DateOnly end) {
    final sameMonth = start.month == end.month && start.year == end.year;
    final startPattern = sameMonth ? 'd' : 'd MMM';
    final startLabel = DateFormat(
      startPattern,
      'pt_BR',
    ).format(start.toLocalDateTime()).replaceAll('.', '');
    final endLabel = DateFormat(
      'd MMM y',
      'pt_BR',
    ).format(end.toLocalDateTime()).replaceAll('.', '');
    return '$startLabel – $endLabel';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
