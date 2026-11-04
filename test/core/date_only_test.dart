import 'package:stick2planner/core/date_only.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateOnly', () {
    test('converte para ISO e de volta', () {
      const iso = '2026-10-31';
      final date = DateOnly.parse(iso);

      expect(date.toIso8601String(), iso);
      expect(date.year, 2026);
      expect(date.month, 10);
      expect(date.day, 31);
      expect(DateOnly.fromDateTime(DateTime(2026, 10, 31, 23, 59)), date);
    });

    test('avança corretamente sobre fim de mês e ano', () {
      expect(
        DateOnly(2026, 12, 31).addDays(1),
        DateOnly(2027, 1, 1),
      );
      expect(DateOnly(2026, 2, 28).addDays(1), DateOnly(2026, 3, 1));
      expect(DateOnly(2028, 2, 28).addDays(1), DateOnly(2028, 2, 29));
    });

    test('diferença em dias atravessa meses', () {
      final start = DateOnly(2026, 10, 28);
      final end = DateOnly(2026, 11, 2);

      expect(start.differenceInDays(end), -5);
      expect(end.differenceInDays(start), 5);
    });

    test('semana começa na segunda-feira', () {
      final saturday = DateOnly(2026, 10, 31);

      expect(saturday.weekday, DateTime.saturday);
      expect(saturday.startOfWeek, DateOnly(2026, 10, 26));
    });

    test('fim do mês respeita anos bissextos', () {
      expect(DateOnly(2028, 2, 1).endOfMonth, DateOnly(2028, 2, 29));
      expect(DateOnly(2026, 2, 1).endOfMonth, DateOnly(2026, 2, 28));
      expect(DateOnly(2026, 12, 1).endOfMonth, DateOnly(2026, 12, 31));
    });

    test('ordena e compara por valor', () {
      final first = DateOnly(2026, 1, 9);
      final second = DateOnly(2026, 1, 10);

      expect(first.isBefore(second), isTrue);
      expect(second.isAfter(first), isTrue);
      expect(first.isSameDay(DateOnly(2026, 1, 9)), isTrue);
      expect(first.compareTo(second), lessThan(0));
      expect(first, DateOnly(2026, 1, 9));
      expect(first.hashCode, DateOnly(2026, 1, 9).hashCode);
    });

    test('recusa data inválida', () {
      expect(() => DateOnly(2026, 2, 30), throwsArgumentError);
      expect(() => DateOnly.parse('31/10/2026'), throwsFormatException);
      expect(() => DateOnly.parse('2026-13-01'), throwsArgumentError);
    });
  });
}
