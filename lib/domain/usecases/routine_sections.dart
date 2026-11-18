import '../../core/date_only.dart';
import '../entities/routine.dart';

/// Falha ao mesclar dois intervalos que contêm tarefas diferentes.
final class RoutineSectionMergeException implements Exception {
  const RoutineSectionMergeException({
    required this.leftTitle,
    required this.rightTitle,
  });

  final String leftTitle;
  final String rightTitle;
}

enum RoutineSectionValidationError {
  titleEmpty,
  titleTooLong,
  missingBoundary,
  endBeforeStart,
  emptyIntervals,
  invalidInterval,
  gapBetweenIntervals,
  taskTitleTooLong,
}

final class RoutineSectionValidationException implements Exception {
  const RoutineSectionValidationException(this.errors);

  final List<RoutineSectionValidationError> errors;

  @override
  String toString() =>
      'Rotina inválida: ${errors.map((error) => error.name).join(', ')}';
}

const _maxTitle = 80;
const _maxTaskTitle = 120;

/// Cria/reconcilia um card quando o início e o fim são definidos.
///
/// Sem limites, o card fica em rascunho e não cria intervalos. Com ambos,
/// cria um único intervalo vazio se ainda não houver nenhum.
RoutineSection configureSection(
  RoutineSection section, {
  required int? startMinutes,
  required int? endMinutes,
  required String Function() idGenerator,
  DateTime? now,
}) {
  if (startMinutes == null || endMinutes == null) {
    return section.copyWith(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      intervals: const [],
      updatedAt: now,
    );
  }
  if (section.intervals.isEmpty) {
    return section.copyWith(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      intervals: [
        RoutineInterval(
          id: idGenerator(),
          sectionId: section.id,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
          position: 0,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      updatedAt: now,
    );
  }

  final intervals = [...section.intervals];
  final first = intervals.first;
  final last = intervals.last;
  intervals[0] = first.copyWith(startMinutes: startMinutes, updatedAt: now);
  intervals[intervals.length - 1] = last.copyWith(
    endMinutes: endMinutes,
    updatedAt: now,
  );
  return section.copyWith(
    startMinutes: startMinutes,
    endMinutes: endMinutes,
    intervals: intervals,
    updatedAt: now,
  );
}

/// Insere um horário intermediário, dividindo o intervalo que o contém.
///
/// O intervalo original mantém o ID, a tarefa e as conclusões (lado esquerdo);
/// o novo trecho à direita nasce vazio com um novo ID.
RoutineSection addSectionTime(
  RoutineSection section, {
  required int minutes,
  required String Function() idGenerator,
  DateTime? now,
}) {
  final start = section.startMinutes;
  final end = section.endMinutes;
  if (start == null || end == null) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.missingBoundary,
    ]);
  }
  if (minutes <= start || minutes >= end) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  if (section.intermediateTimes.contains(minutes)) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }

  final intervals = [...section.intervals];
  final index = intervals.indexWhere(
    (interval) =>
        interval.startMinutes < minutes && interval.endMinutes > minutes,
  );
  if (index < 0) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  final original = intervals[index];
  intervals[index] = original.copyWith(endMinutes: minutes, updatedAt: now);
  intervals.insert(
    index + 1,
    RoutineInterval(
      id: idGenerator(),
      sectionId: section.id,
      startMinutes: minutes,
      endMinutes: original.endMinutes,
      position: index + 1,
      createdAt: now,
      updatedAt: now,
    ),
  );
  return _reindex(section.copyWith(intervals: intervals, updatedAt: now));
}

/// Move uma fronteira intermediária, mantendo os IDs e tarefas dos intervalos.
RoutineSection moveSectionTime(
  RoutineSection section, {
  required int fromMinutes,
  required int toMinutes,
  DateTime? now,
}) {
  if (fromMinutes == toMinutes) return section;
  final start = section.startMinutes;
  final end = section.endMinutes;
  if (start == null || end == null) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.missingBoundary,
    ]);
  }
  if (toMinutes <= start ||
      toMinutes >= end ||
      section.intermediateTimes.contains(toMinutes)) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  final intervals = [...section.intervals];
  final boundaryIndex = intervals.indexWhere(
    (interval) => interval.startMinutes == fromMinutes,
  );
  if (boundaryIndex <= 0) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  final minMinutes = boundaryIndex >= 2
      ? intervals[boundaryIndex - 2].endMinutes
      : start;
  final maxMinutes = boundaryIndex + 1 < intervals.length
      ? intervals[boundaryIndex + 1].startMinutes
      : end;
  if (toMinutes <= minMinutes || toMinutes >= maxMinutes) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  final left = intervals[boundaryIndex - 1];
  final right = intervals[boundaryIndex];
  intervals[boundaryIndex - 1] = left.copyWith(
    endMinutes: toMinutes,
    updatedAt: now,
  );
  intervals[boundaryIndex] = right.copyWith(
    startMinutes: toMinutes,
    updatedAt: now,
  );
  return section.copyWith(intervals: intervals, updatedAt: now);
}

/// Remove uma fronteira intermediária, unindo os dois intervalos vizinhos.
///
/// Se ambos tiverem tarefas diferentes, [keepIntervalId] é obrigatório para
/// evitar perda silenciosa. O ID escolhido permanece e recebe os dados da
/// tarefa mantida.
RoutineSection removeSectionTime(
  RoutineSection section, {
  required int minutes,
  String? keepIntervalId,
  DateTime? now,
}) {
  final intervals = [...section.intervals];
  final rightIndex = intervals.indexWhere(
    (interval) => interval.startMinutes == minutes,
  );
  if (rightIndex <= 0) {
    throw const RoutineSectionValidationException([
      RoutineSectionValidationError.invalidInterval,
    ]);
  }
  final left = intervals[rightIndex - 1];
  final right = intervals[rightIndex];
  if (left.hasTask && right.hasTask && keepIntervalId == null) {
    throw RoutineSectionMergeException(
      leftTitle: left.title ?? '',
      rightTitle: right.title ?? '',
    );
  }
  final keepRight =
      keepIntervalId == right.id || (!left.hasTask && right.hasTask);
  final kept = keepRight ? right : left;
  final merged = left.copyWith(
    endMinutes: right.endMinutes,
    title: kept.title,
    details: kept.details,
    completedDates: kept.completedDates,
    updatedAt: now,
  );
  intervals[rightIndex - 1] = merged;
  intervals.removeAt(rightIndex);
  return _reindex(section.copyWith(intervals: intervals, updatedAt: now));
}

/// Remove uma tarefa mantendo o intervalo e seu ID.
RoutineSection clearIntervalTask(
  RoutineSection section, {
  required String intervalId,
  DateTime? now,
}) {
  return section.copyWith(
    intervals: [
      for (final interval in section.intervals)
        if (interval.id == intervalId)
          interval.copyWith(
            title: null,
            details: null,
            completedDates: const {},
            updatedAt: now,
          )
        else
          interval,
    ],
    updatedAt: now,
  );
}

List<RoutineSectionValidationError> validateRoutineSections(
  List<RoutineSection> sections,
) {
  final errors = <RoutineSectionValidationError>[];
  for (final section in sections) {
    final title = section.title.trim();
    if (title.isEmpty) {
      errors.add(RoutineSectionValidationError.titleEmpty);
    }
    if (title.length > _maxTitle) {
      errors.add(RoutineSectionValidationError.titleTooLong);
    }
    final start = section.startMinutes;
    final end = section.endMinutes;
    if ((start == null) != (end == null)) {
      errors.add(RoutineSectionValidationError.missingBoundary);
      continue;
    }
    if (start == null || end == null) {
      if (section.intervals.isNotEmpty) {
        errors.add(RoutineSectionValidationError.missingBoundary);
      }
      continue;
    }
    if (end <= start) {
      errors.add(RoutineSectionValidationError.endBeforeStart);
      continue;
    }
    if (section.intervals.isEmpty) {
      errors.add(RoutineSectionValidationError.emptyIntervals);
      continue;
    }

    var expectedStart = start;
    for (final interval in section.intervals) {
      if (interval.startMinutes < start ||
          interval.endMinutes > end ||
          interval.startMinutes >= interval.endMinutes) {
        errors.add(RoutineSectionValidationError.invalidInterval);
      }
      if (interval.startMinutes != expectedStart) {
        errors.add(RoutineSectionValidationError.gapBetweenIntervals);
      }
      expectedStart = interval.endMinutes;
      final taskTitle = interval.title?.trim();
      if (taskTitle != null && taskTitle.length > _maxTaskTitle) {
        errors.add(RoutineSectionValidationError.taskTitleTooLong);
      }
    }
    if (expectedStart != end) {
      errors.add(RoutineSectionValidationError.invalidInterval);
    }
  }
  return errors;
}

RoutineSection _reindex(RoutineSection section) => section.copyWith(
  intervals: [
    for (var index = 0; index < section.intervals.length; index++)
      section.intervals[index].copyWith(position: index),
  ],
);

/// Converte horários selecionados em minutos, mantendo a data local fora disso.
int minutesOf(int hour, int minute) => hour * 60 + minute;

/// Datas concluídas continuam associadas ao intervalo; helper para testes/UI.
Set<DateOnly> mergeCompletionDates(Set<DateOnly> first, Set<DateOnly> second) =>
    {...first, ...second};
