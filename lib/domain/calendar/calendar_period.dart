import '../../core/date_only.dart';
import 'agenda_view_mode.dart';

/// Um dia dentro da grade, incluindo dias de borda do mês.
final class CalendarDay {
  const CalendarDay({required this.date, required this.isCurrentMonth});

  final DateOnly date;
  final bool isCurrentMonth;
}

/// Uma linha de 7 dias (ou N dias nos modos curtos).
final class CalendarWeek {
  const CalendarWeek({required this.days});

  final List<CalendarDay> days;

  DateOnly get start => days.first.date;
  DateOnly get end => days.last.date;
}

/// Janela visível da agenda derivada da data selecionada e do modo.
final class CalendarPeriod {
  const CalendarPeriod({
    required this.selectedDate,
    required this.mode,
    required this.days,
    required this.weeks,
    required this.start,
    required this.end,
  });

  final DateOnly selectedDate;
  final AgendaViewMode mode;
  final List<CalendarDay> days;
  final List<CalendarWeek> weeks;
  final DateOnly start;
  final DateOnly end;

  int get columnCount => weeks.first.days.length;

  bool get isMonth => mode.isMonth;

  bool contains(DateOnly date) => !date.isBefore(start) && !date.isAfter(end);

  factory CalendarPeriod.fourDays({
    required DateOnly selectedDate,
    required DateOnly start,
  }) {
    return _singleRow(
      selectedDate: selectedDate,
      mode: AgendaViewMode.fourDays,
      start: start,
      length: 4,
    );
  }

  factory CalendarPeriod.compute({
    required DateOnly selectedDate,
    required AgendaViewMode mode,
  }) {
    switch (mode) {
      case AgendaViewMode.day:
        return _singleRow(
          selectedDate: selectedDate,
          mode: mode,
          start: selectedDate,
          length: 1,
        );
      case AgendaViewMode.fourDays:
        return _singleRow(
          selectedDate: selectedDate,
          mode: mode,
          start: selectedDate,
          length: 4,
        );
      case AgendaViewMode.week:
        return _singleRow(
          selectedDate: selectedDate,
          mode: mode,
          start: selectedDate.startOfWeek,
          length: 7,
        );
      case AgendaViewMode.twoWeeks:
        final start = selectedDate.startOfWeek;
        final days = _range(start, 14);
        return CalendarPeriod(
          selectedDate: selectedDate,
          mode: mode,
          days: days,
          weeks: [
            CalendarWeek(days: days.sublist(0, 7)),
            CalendarWeek(days: days.sublist(7)),
          ],
          start: days.first.date,
          end: days.last.date,
        );
      case AgendaViewMode.month:
        return _month(selectedDate);
    }
  }

  static CalendarPeriod _singleRow({
    required DateOnly selectedDate,
    required AgendaViewMode mode,
    required DateOnly start,
    required int length,
  }) {
    final days = _range(start, length);
    return CalendarPeriod(
      selectedDate: selectedDate,
      mode: mode,
      days: days,
      weeks: [CalendarWeek(days: days)],
      start: days.first.date,
      end: days.last.date,
    );
  }

  static CalendarPeriod _month(DateOnly selectedDate) {
    final firstOfMonth = DateOnly(selectedDate.year, selectedDate.month, 1);
    final leading = firstOfMonth.weekday - DateTime.monday;
    final daysInMonth = DateOnly.daysInMonth(
      selectedDate.year,
      selectedDate.month,
    );
    final usedCells = leading + daysInMonth;
    final totalCells = usedCells <= 35 ? 35 : 42;
    final gridStart = firstOfMonth.addDays(-leading);
    final days = <CalendarDay>[
      for (var index = 0; index < totalCells; index++)
        _day(gridStart.addDays(index), selectedDate),
    ];
    final weeks = <CalendarWeek>[
      for (var index = 0; index < totalCells; index += 7)
        CalendarWeek(days: days.sublist(index, index + 7)),
    ];

    return CalendarPeriod(
      selectedDate: selectedDate,
      mode: AgendaViewMode.month,
      days: days,
      weeks: weeks,
      start: days.first.date,
      end: days.last.date,
    );
  }

  static List<CalendarDay> _range(DateOnly start, int length) => [
    for (var index = 0; index < length; index++)
      CalendarDay(date: start.addDays(index), isCurrentMonth: true),
  ];

  static CalendarDay _day(DateOnly date, DateOnly reference) => CalendarDay(
    date: date,
    isCurrentMonth:
        date.year == reference.year && date.month == reference.month,
  );
}

/// Avança/retrocede a data selecionada em um período.
///
/// Mês preserva o dia quando possível (31 jan → 28/29 fev).
DateOnly shiftSelectedDate(
  DateOnly selected,
  AgendaViewMode mode,
  int direction,
) {
  return switch (mode) {
    AgendaViewMode.day => selected.addDays(direction),
    AgendaViewMode.fourDays => selected.addDays(4 * direction),
    AgendaViewMode.week => selected.addDays(7 * direction),
    AgendaViewMode.twoWeeks => selected.addDays(14 * direction),
    AgendaViewMode.month => addMonths(selected, direction),
  };
}

DateOnly addMonths(DateOnly date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final maxDay = DateOnly.daysInMonth(year, month);
  final day = date.day > maxDay ? maxDay : date.day;
  return DateOnly(year, month, day);
}
