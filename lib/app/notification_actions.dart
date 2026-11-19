import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/date_only.dart';
import '../data/db/app_database.dart';
import '../data/repositories/drift_routine_repository.dart';
import '../domain/entities/routine.dart';

/// Executa a ação "Concluir" mesmo quando o app está encerrado.
///
/// O isolate de background abre o banco local, registra a execução idempotente
/// e marca a atividade do dia. A fila de sync é gravada na mesma transação.
@pragma('vm:entry-point')
Future<void> routineNotificationBackgroundAction(
  NotificationResponse response,
) async {
  if (response.actionId != 'done') return;
  final raw = response.payload;
  if (raw == null) return;
  Map<String, Object?> payload;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    payload = Map<String, Object?>.from(decoded);
  } on Object {
    return;
  }

  final routineId = payload['routineId'];
  final dateRaw = payload['date'];
  if (routineId is! String || dateRaw is! String) return;
  final DateOnly date;
  try {
    date = DateOnly.parse(dateRaw);
  } on Object {
    return;
  }

  final itemId = payload['itemId'] as String?;
  final intervalId = payload['intervalId'] as String?;
  final reminderId = payload['reminderId'] as String?;
  final slot = payload['slotMinutes'] as int?;
  final target = intervalId != null
      ? 'interval|$intervalId'
      : itemId != null
      ? 'item|$itemId'
      : 'routine|$routineId';
  final dedupeKey = reminderId == null
      ? '$target|${date.toIso8601String()}|manual'
      : '$target|${date.toIso8601String()}|reminder|$reminderId|${slot ?? 0}';

  final db = AppDatabase.open();
  try {
    final repository = DriftRoutineRepository(db);
    final now = DateTime.now().toUtc();
    final created = await repository.recordExecution(
      RoutineExecution(
        id: '${DateTime.now().microsecondsSinceEpoch}-$target',
        routineId: routineId,
        itemId: itemId,
        intervalId: intervalId,
        reminderId: reminderId,
        date: date,
        executedAt: now,
        origin: RoutineExecutionOrigin.notification,
        dedupeKey: dedupeKey,
      ),
    );
    if (!created) return;
    if (intervalId != null) {
      await repository.setIntervalCompletion(
        intervalId: intervalId,
        date: date,
        completed: true,
        at: now,
      );
    } else if (itemId != null) {
      await repository.setCompletion(
        routineItemId: itemId,
        date: date,
        completed: true,
        at: now,
      );
    }
  } finally {
    await db.close();
  }
}
