import '../../core/date_only.dart';
import '../entities/post_it.dart';
import 'calendar_period.dart';

/// Expande eventos recorrentes em ocorrências dentro de [from]..[to].
///
/// O evento original é a primeira ocorrência; tarefas e eventos únicos são
/// devolvidos sem alteração. Ocorrências mantêm o mesmo ID e a duração do
/// evento original.
List<PostIt> expandEventOccurrences(
  List<PostIt> postIts, {
  required DateOnly from,
  required DateOnly to,
}) {
  final expanded = <PostIt>[];
  for (final postIt in postIts) {
    if (!postIt.isRecurringEvent) {
      expanded.add(postIt);
      continue;
    }
    final base = postIt.startDate;
    if (base == null) {
      expanded.add(postIt);
      continue;
    }

    final duration = postIt.durationInDays.clamp(1, 3660);
    final interval = postIt.safeRecurrenceInterval;
    final firstVisible = from.addDays(-(duration - 1));
    final firstIndex = _firstIndex(
      postIt.recurrence,
      base,
      firstVisible,
      interval,
    );

    for (var index = firstIndex; index < firstIndex + 100000; index++) {
      final start = _occurrenceStart(postIt.recurrence, base, interval, index);
      if (start.isAfter(to)) break;
      final end = start.addDays(duration - 1);
      if (end.isBefore(from)) continue;
      expanded.add(
        postIt.copyWith(startDate: start, endDate: duration > 1 ? end : null),
      );
    }
  }
  return expanded;
}

int _firstIndex(
  EventRecurrence recurrence,
  DateOnly base,
  DateOnly firstVisible,
  int interval,
) {
  final days = firstVisible.differenceInDays(base);
  final months =
      (firstVisible.year - base.year) * 12 + firstVisible.month - base.month;
  final index = switch (recurrence) {
    EventRecurrence.daily => days,
    EventRecurrence.weekly => days ~/ (7 * interval),
    EventRecurrence.monthly => months ~/ interval,
    EventRecurrence.yearly => months ~/ 12,
    EventRecurrence.none => 0,
  };
  final safe = index - 1;
  return safe < 0 ? 0 : safe;
}

DateOnly _occurrenceStart(
  EventRecurrence recurrence,
  DateOnly base,
  int interval,
  int index,
) {
  return switch (recurrence) {
    EventRecurrence.daily => base.addDays(index),
    EventRecurrence.weekly => base.addDays(index * 7 * interval),
    EventRecurrence.monthly => addMonths(base, index * interval),
    EventRecurrence.yearly => addMonths(base, index * 12),
    EventRecurrence.none => base,
  };
}
