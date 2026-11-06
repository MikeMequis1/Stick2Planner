import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/calendar/event_recurrence.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

void main() {
  PostIt event({
    String id = 'e1',
    DateOnly? start,
    DateOnly? end,
    EventRecurrence recurrence = EventRecurrence.none,
    int interval = 1,
  }) => PostIt(
    id: id,
    title: 'Evento',
    type: PostItType.event,
    status: PostItStatus.active,
    startDate: start,
    endDate: end,
    recurrence: recurrence,
    recurrenceInterval: interval,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  test('evento único permanece inalterado', () {
    final base = event(start: DateOnly(2026, 11, 4));
    final result = expandEventOccurrences(
      [base],
      from: DateOnly(2026, 11, 1),
      to: DateOnly(2026, 11, 30),
    );
    expect(result, hasLength(1));
    expect(result.single.startDate, DateOnly(2026, 11, 4));
  });

  test('diário gera uma ocorrência por dia', () {
    final result = expandEventOccurrences(
      [event(start: DateOnly(2026, 11, 4), recurrence: EventRecurrence.daily)],
      from: DateOnly(2026, 11, 4),
      to: DateOnly(2026, 11, 7),
    );
    expect(
      result.map((postIt) => postIt.startDate),
      [
        DateOnly(2026, 11, 4),
        DateOnly(2026, 11, 5),
        DateOnly(2026, 11, 6),
        DateOnly(2026, 11, 7),
      ],
    );
  });

  test('semanal respeita o intervalo de semanas e a duração', () {
    final result = expandEventOccurrences(
      [
        event(
          start: DateOnly(2026, 11, 4),
          end: DateOnly(2026, 11, 5),
          recurrence: EventRecurrence.weekly,
          interval: 2,
        ),
      ],
      from: DateOnly(2026, 11, 1),
      to: DateOnly(2026, 12, 31),
    );
    expect(result.map((postIt) => postIt.startDate), [
      DateOnly(2026, 11, 4),
      DateOnly(2026, 11, 18),
      DateOnly(2026, 12, 2),
      DateOnly(2026, 12, 16),
      DateOnly(2026, 12, 30),
    ]);
    expect(result.every((postIt) => postIt.durationInDays == 2), isTrue);
    expect(result.every((postIt) => postIt.id == 'e1'), isTrue);
  });

  test('mensal respeita o intervalo e clampa o dia', () {
    final result = expandEventOccurrences(
      [
        event(
          start: DateOnly(2026, 1, 31),
          recurrence: EventRecurrence.monthly,
          interval: 2,
        ),
      ],
      from: DateOnly(2026, 1, 1),
      to: DateOnly(2026, 9, 30),
    );
    expect(result.map((postIt) => postIt.startDate), [
      DateOnly(2026, 1, 31),
      DateOnly(2026, 3, 31),
      DateOnly(2026, 5, 31),
      DateOnly(2026, 7, 31),
      DateOnly(2026, 9, 30),
    ]);
  });

  test('anual preserva mês/dia e clampa 29 de fevereiro', () {
    final result = expandEventOccurrences(
      [
        event(
          start: DateOnly(2024, 2, 29),
          recurrence: EventRecurrence.yearly,
        ),
      ],
      from: DateOnly(2024, 1, 1),
      to: DateOnly(2028, 12, 31),
    );
    expect(result.map((postIt) => postIt.startDate), [
      DateOnly(2024, 2, 29),
      DateOnly(2025, 2, 28),
      DateOnly(2026, 2, 28),
      DateOnly(2027, 2, 28),
      DateOnly(2028, 2, 29),
    ]);
  });
}
