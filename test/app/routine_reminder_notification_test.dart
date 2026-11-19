import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/services/notification_service.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/routine.dart';

void main() {
  test('distribui oito lembretes diários e preserva dias da semana', () {
    final now = DateTime(2026, 11, 9, 7);
    final routine = Routine(
      id: 'r1',
      name: 'Hidratação',
      weekdays: const {1, 2, 3, 4, 5, 6, 7},
      items: const [
        RoutineItem(
          id: 'water',
          routineId: 'r1',
          title: 'Beber água',
          position: 0,
        ),
      ],
      reminders: const [
        RoutineReminder(
          id: 'rem1',
          routineId: 'r1',
          itemId: 'water',
          mode: RoutineReminderMode.frequency,
          timesPerDay: 8,
          startMinutes: 8 * 60,
          endMinutes: 20 * 60,
          weekdays: {1, 2, 3, 4, 5, 6, 7},
        ),
      ],
      createdAt: DateOnly(2026, 11, 1).toLocalDateTime().toUtc(),
      updatedAt: now.toUtc(),
    );

    final plan = buildNotificationPlan(
      postIts: const [],
      routines: [routine],
      now: now,
    );
    final reminders = [
      for (final notification in plan)
        if (notification.payload != null) notification,
    ];

    expect(reminders, hasLength(56));
    expect(reminders.map((item) => item.id).toSet(), hasLength(56));
    final firstDay = [
      for (final notification in reminders)
        if (DateTime.parse(
              (jsonDecode(notification.payload!) as Map)['date'] as String,
            ).day ==
            9)
          notification,
    ];
    expect(firstDay, hasLength(8));
    expect(firstDay.first.at, DateTime(2026, 11, 9, 8));
    expect(firstDay.last.at.isBefore(DateTime(2026, 11, 9, 20)), isTrue);
    expect(firstDay.first.body, contains('Beber água'));
  });

  test('respeita dias da semana e lembrete pausado', () {
    final now = DateTime(2026, 11, 9, 7);
    final routine = Routine(
      id: 'r2',
      name: 'Estudo',
      weekdays: const {1, 2, 3, 4, 5, 6, 7},
      reminders: const [
        RoutineReminder(
          id: 'rem2',
          routineId: 'r2',
          mode: RoutineReminderMode.times,
          times: [480, 600],
          weekdays: {1},
        ),
        RoutineReminder(
          id: 'rem3',
          routineId: 'r2',
          mode: RoutineReminderMode.times,
          times: [480],
          weekdays: {1, 2, 3, 4, 5, 6, 7},
          paused: true,
        ),
      ],
      createdAt: DateOnly(2026, 11, 1).toLocalDateTime().toUtc(),
      updatedAt: now.toUtc(),
    );

    final plan = buildNotificationPlan(
      postIts: const [],
      routines: [routine],
      now: now,
    );
    final reminders = [
      for (final notification in plan)
        if (notification.payload != null) notification,
    ];

    // Segunda e a próxima segunda, 2 horários cada; o pausado não entra.
    expect(reminders, hasLength(2));
    expect(
      reminders.every(
        (notification) =>
            DateTime.parse(
              (jsonDecode(notification.payload!) as Map)['date'] as String,
            ).weekday ==
            1,
      ),
      isTrue,
    );
  });
}
