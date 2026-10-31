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

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
