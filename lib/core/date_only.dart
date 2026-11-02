/// Data de calendário sem hora nem fuso.
///
/// Evita deslocamentos de fuso/DST e comparações ambíguas em regras de agenda.
/// Internamente guarda um [DateTime] UTC normalizado à meia-noite.
final class DateOnly implements Comparable<DateOnly> {
  DateOnly(int year, int month, int day)
    : _utc = DateTime.utc(year, month, day) {
    if (_utc.year != year || _utc.month != month || _utc.day != day) {
      throw ArgumentError('Data inválida: $year-$month-$day');
    }
  }

  DateOnly._(this._utc);

  final DateTime _utc;

  factory DateOnly.fromDateTime(DateTime value) =>
      DateOnly(value.year, value.month, value.day);

  factory DateOnly.parse(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) {
      throw FormatException('Data deve estar no formato aaaa-mm-dd', value);
    }
    return DateOnly(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// Segunda-feira = 1 ... domingo = 7.
  int get weekday => _utc.weekday;

  /// Dias desde 1970-01-01; útil para comparação e ordenação.
  int get daysSinceEpoch => _utc.difference(DateTime.utc(1970)).inDays;

  DateOnly addDays(int days) => DateOnly._(_utc.add(Duration(days: days)));

  int differenceInDays(DateOnly other) => _utc.difference(other._utc).inDays;

  DateOnly get startOfWeek => addDays(1 - weekday);

  DateOnly get endOfMonth => DateOnly(year, month, daysInMonth(year, month));

  bool isBefore(DateOnly other) => _utc.isBefore(other._utc);
  bool isAfter(DateOnly other) => _utc.isAfter(other._utc);

  bool isSameDay(DateOnly other) => _utc == other._utc;

  /// Meia-noite local, para date pickers e formatação.
  DateTime toLocalDateTime() => DateTime(year, month, day);

  String toIso8601String() {
    final monthPart = month.toString().padLeft(2, '0');
    final dayPart = day.toString().padLeft(2, '0');
    return '$year-$monthPart-$dayPart';
  }

  static int daysInMonth(int year, int month) {
    final firstOfNextMonth = month == 12
        ? DateTime.utc(year + 1)
        : DateTime.utc(year, month + 1);
    return firstOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  int compareTo(DateOnly other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) => other is DateOnly && _utc == other._utc;

  @override
  int get hashCode => _utc.hashCode;

  @override
  String toString() => toIso8601String();
}
