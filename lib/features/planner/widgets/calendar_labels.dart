import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/calendar/calendar_period.dart';
import '../../../domain/calendar/agenda_view_mode.dart';

/// Rótulo do período exibido no cabeçalho da agenda.
String calendarPeriodLabel(CalendarPeriod period) {
  return switch (period.mode) {
    AgendaViewMode.day => DateFormats.fullDate(period.selectedDate),
    AgendaViewMode.month => DateFormats.monthYear(period.selectedDate),
    _ => DateFormats.dateRangeShort(period.start, period.end),
  };
}

/// Abreviação do dia da semana para cabeçalhos e textos auxiliares.
String weekdayLabel(DateOnly date) => DateFormats.weekdayShort(date);
