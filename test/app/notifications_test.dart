import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/services/notification_service.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/routine.dart';

void main() {
  final now = DateTime(2026, 11, 9, 7);

  PostIt postIt({
    required String id,
    required String title,
    PostItStatus status = PostItStatus.active,
    int? timeMinutes = 600,
    int? reminderMinutes = 30,
  }) => PostIt(
    id: id,
    title: title,
    type: PostItType.event,
    status: status,
    startDate: DateOnly(2026, 11, 9),
    timeMinutes: timeMinutes,
    reminderMinutes: reminderMinutes,
    createdAt: now,
    updatedAt: now,
  );

  test('gera resumo diário e lembrete antecipado', () {
    final plan = buildNotificationPlan(
      postIts: [postIt(id: 'e1', title: 'Consulta')],
      routines: [
        Routine(
          id: 'r1',
          name: 'Manhã',
          createdAt: now,
          updatedAt: now,
          weekdays: const {1},
          items: const [
            RoutineItem(
              id: 'i1',
              routineId: 'r1',
              title: 'Alongar',
              position: 0,
            ),
          ],
        ),
      ],
      now: now,
    );

    expect(plan.where((item) => item.id == 1000), hasLength(1));
    final summary = plan.firstWhere((item) => item.id == 1000);
    expect(summary.at, DateTime(2026, 11, 9, 8));
    expect(summary.body, contains('Consulta'));
    expect(summary.body, contains('Manhã'));

    final reminder = plan.firstWhere((item) => item.id >= 100000);
    expect(reminder.at, DateTime(2026, 11, 9, 9, 30));
    expect(reminder.body, contains('Consulta'));
  });

  test('não gera lembrete sem horário, concluído ou já passado', () {
    final plan = buildNotificationPlan(
      postIts: [
        postIt(id: 'no-time', title: 'Sem hora', timeMinutes: null),
        postIt(id: 'done', title: 'Concluída', status: PostItStatus.done),
        postIt(id: 'late', title: 'Passada', reminderMinutes: 300),
      ],
      routines: const [],
      now: now,
    );

    final reminders = plan.where((item) => item.id >= 100000);
    expect(reminders, isEmpty);
  });

  test('não gera resumo quando não há atividades', () {
    final plan = buildNotificationPlan(
      postIts: const [],
      routines: const [],
      now: now,
    );
    expect(plan, isEmpty);
  });
}
