import 'package:intl/intl.dart';

import 'date_only.dart';

/// Formatação de datas no idioma atual do aplicativo.
///
/// Requer `initializeDateFormatting(locale)` uma vez na inicialização.
abstract final class DateFormats {
  /// Locale BCP-47 usado pelo `intl`; atualizado por `AppSettingsController`.
  static String locale = 'pt_BR';

  static bool get _english => locale.startsWith('en');

  static String fullDate(DateOnly date) {
    final pattern = _english ? 'EEEE, MMMM d, y' : "EEEE, d 'de' MMMM 'de' y";
    final formatted = DateFormat(
      pattern,
      locale,
    ).format(date.toLocalDateTime());
    return _capitalize(formatted);
  }

  static String shortDate(DateOnly date) => DateFormat(
    _english ? 'MM/dd/yyyy' : 'dd/MM/yyyy',
    locale,
  ).format(date.toLocalDateTime());

  static String dayAndMonth(DateOnly date) => DateFormat(
    _english ? 'MMM d' : 'd MMM',
    locale,
  ).format(date.toLocalDateTime());

  static String monthYear(DateOnly date) =>
      _capitalize(DateFormat('MMMM y', locale).format(date.toLocalDateTime()));

  /// "seg", "ter". sem ponto final.
  static String weekdayShort(DateOnly date) {
    final formatted = DateFormat('EEE', locale).format(date.toLocalDateTime());
    return _capitalize(formatted.replaceAll('.', ''));
  }

  /// "14:30" a partir de minutos desde a meia-noite.
  static String clockTime(int minutes) {
    final normalized = minutes.clamp(0, 24 * 60 - 1);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  /// "2 - 8 nov 2026" ou "30 nov - 6 dez 2026".
  static String dateRangeShort(DateOnly start, DateOnly end) {
    final sameMonth = start.month == end.month && start.year == end.year;
    final startPattern = _english
        ? (sameMonth ? 'd' : 'MMM d')
        : (sameMonth ? 'd' : 'd MMM');
    final endPattern = _english ? 'MMM d y' : 'd MMM y';
    final startLabel = DateFormat(
      startPattern,
      locale,
    ).format(start.toLocalDateTime()).replaceAll('.', '');
    final endLabel = DateFormat(
      endPattern,
      locale,
    ).format(end.toLocalDateTime()).replaceAll('.', '');
    return '$startLabel – $endLabel';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
