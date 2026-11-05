import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/calendar/agenda_view_mode.dart';
import 'package:stick2planner/domain/calendar/calendar_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarPeriod', () {
    test('dia único contém somente a data selecionada', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 11, 4),
        mode: AgendaViewMode.day,
      );

      expect(period.days, hasLength(1));
      expect(period.weeks, hasLength(1));
      expect(period.columnCount, 1);
      expect(period.start, DateOnly(2026, 11, 4));
      expect(period.end, DateOnly(2026, 11, 4));
    });

    test('quatro dias começam na data selecionada', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 11, 4),
        mode: AgendaViewMode.fourDays,
      );

      expect(period.days, hasLength(4));
      expect(period.columnCount, 4);
      expect(period.start, DateOnly(2026, 11, 4));
      expect(period.end, DateOnly(2026, 11, 7));
    });

    test('quatro dias ancoram a janela fora da data selecionada', () {
      final period = CalendarPeriod.fourDays(
        selectedDate: DateOnly(2026, 11, 5),
        start: DateOnly(2026, 11, 4),
      );

      expect(period.days, hasLength(4));
      expect(period.columnCount, 4);
      expect(period.start, DateOnly(2026, 11, 4));
      expect(period.end, DateOnly(2026, 11, 7));
      expect(period.selectedDate, DateOnly(2026, 11, 5));
      expect(period.contains(DateOnly(2026, 11, 7)), isTrue);
      expect(period.contains(DateOnly(2026, 11, 8)), isFalse);
    });

    test('semana começa na segunda-feira', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 11, 4),
        mode: AgendaViewMode.week,
      );

      expect(period.days, hasLength(7));
      expect(period.start, DateOnly(2026, 11, 2));
      expect(period.end, DateOnly(2026, 11, 8));
      expect(period.weeks, hasLength(1));
    });

    test('duas semanas têm duas linhas de sete dias', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 11, 4),
        mode: AgendaViewMode.twoWeeks,
      );

      expect(period.days, hasLength(14));
      expect(period.weeks, hasLength(2));
      expect(period.weeks[0].days, hasLength(7));
      expect(period.weeks[1].days.first.date, DateOnly(2026, 11, 9));
      expect(period.end, DateOnly(2026, 11, 15));
    });

    test('semana que cruza o mês não atenua dias válidos', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 10, 28),
        mode: AgendaViewMode.week,
      );

      expect(period.start, DateOnly(2026, 10, 26));
      expect(period.end, DateOnly(2026, 11, 1));
      expect(
        period.days.every((day) => day.isCurrentMonth),
        isTrue,
      );
    });

    test('novembro de 2026 usa 42 células e inclui dias de borda', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 11, 4),
        mode: AgendaViewMode.month,
      );

      expect(period.days, hasLength(42));
      expect(period.weeks, hasLength(6));
      expect(period.start, DateOnly(2026, 10, 26));
      expect(period.end, DateOnly(2026, 12, 6));
      expect(period.days.first.isCurrentMonth, isFalse);
      expect(
        period.days.where((day) => day.isCurrentMonth),
        hasLength(30),
      );
      expect(
        period.days.any((day) => day.date == DateOnly(2026, 11, 1)),
        isTrue,
      );
    });

    test('mês de 31 dias não é truncado em 30', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 10, 15),
        mode: AgendaViewMode.month,
      );

      expect(period.days, hasLength(35));
      expect(
        period.days.where((day) => day.isCurrentMonth),
        hasLength(31),
      );
      expect(
        period.days.any((day) => day.date == DateOnly(2026, 10, 31)),
        isTrue,
      );
      expect(period.start, DateOnly(2026, 9, 28));
      expect(period.end, DateOnly(2026, 11, 1));
    });

    test('fevereiro usa a grade mínima de 35 células', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2027, 2, 10),
        mode: AgendaViewMode.month,
      );

      expect(period.days, hasLength(35));
      expect(period.weeks, hasLength(5));
      expect(period.start, DateOnly(2027, 2, 1));
      expect(period.end, DateOnly(2027, 3, 7));
      expect(
        period.days.where((day) => day.isCurrentMonth),
        hasLength(28),
      );
    });

    test('seleção no último dia do mês permanece no mês', () {
      final period = CalendarPeriod.compute(
        selectedDate: DateOnly(2026, 10, 31),
        mode: AgendaViewMode.month,
      );

      expect(period.selectedDate, DateOnly(2026, 10, 31));
      expect(period.contains(period.selectedDate), isTrue);
      expect(period.mode, AgendaViewMode.month);
    });

    test('navegação por mês preserva o dia quando possível', () {
      expect(
        shiftSelectedDate(DateOnly(2026, 1, 31), AgendaViewMode.month, 1),
        DateOnly(2026, 2, 28),
      );
      expect(
        shiftSelectedDate(DateOnly(2028, 1, 31), AgendaViewMode.month, 1),
        DateOnly(2028, 2, 29),
      );
      expect(
        shiftSelectedDate(DateOnly(2026, 3, 31), AgendaViewMode.month, -1),
        DateOnly(2026, 2, 28),
      );
      expect(
        shiftSelectedDate(DateOnly(2026, 12, 15), AgendaViewMode.month, 1),
        DateOnly(2027, 1, 15),
      );
    });

    test('navegação por dias avança o tamanho do período', () {
      expect(
        shiftSelectedDate(DateOnly(2026, 11, 4), AgendaViewMode.day, 1),
        DateOnly(2026, 11, 5),
      );
      expect(
        shiftSelectedDate(DateOnly(2026, 11, 4), AgendaViewMode.fourDays, -1),
        DateOnly(2026, 10, 31),
      );
      expect(
        shiftSelectedDate(DateOnly(2026, 11, 4), AgendaViewMode.week, 1),
        DateOnly(2026, 11, 11),
      );
      expect(
        shiftSelectedDate(DateOnly(2026, 11, 4), AgendaViewMode.twoWeeks, 1),
        DateOnly(2026, 11, 18),
      );
    });
  });
}
