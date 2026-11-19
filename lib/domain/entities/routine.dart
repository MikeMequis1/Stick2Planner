import '../../core/date_only.dart';

/// Formato de organização de uma rotina.
enum RoutineMode { simple, complete }

/// Como os lembretes de uma rotina/atividade são distribuídos.
enum RoutineReminderMode { frequency, times }

/// Origem de uma execução registrada.
enum RoutineExecutionOrigin { app, notification, legacy }

/// Rotina semanal: um conjunto de atividades repetido em dias escolhidos.
///
/// A conclusão é por ocorrência (`atividade/intervalo + data`), nunca global.
final class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.mode = RoutineMode.simple,
    this.details,
    this.weekdays = const {},
    this.items = const [],
    this.sections = const [],
    this.reminders = const [],
  });

  final String id;
  final String name;
  final String? details;
  final RoutineMode mode;

  /// 1 = segunda ... 7 = domingo.
  final Set<int> weekdays;

  /// Atividades do modo simples.
  final List<RoutineItem> items;

  /// Cards do modo completo.
  final List<RoutineSection> sections;

  /// Lembretes da rotina ou de atividades específicas.
  final List<RoutineReminder> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Data local em que a rotina foi criada. A recorrência nunca começa antes
  /// dela, mesmo que o dispositivo fique offline por vários dias.
  DateOnly get createdOn => DateOnly.fromDateTime(createdAt.toLocal());

  /// A rotina só ocorre a partir do dia da criação e nos dias escolhidos.
  bool runsOn(DateOnly date) =>
      !date.isBefore(createdOn) && weekdays.contains(date.weekday);

  int get taskCount => mode == RoutineMode.simple
      ? items.length
      : sections.fold(0, (total, section) => total + section.taskCount);

  int completedOn(DateOnly date) {
    if (mode == RoutineMode.simple) {
      return items.where((item) => item.isCompletedOn(date)).length;
    }
    return sections.fold(
      0,
      (total, section) => total + section.completedOn(date),
    );
  }

  Routine copyWith({
    String? name,
    RoutineMode? mode,
    Object? details = _unset,
    Set<int>? weekdays,
    List<RoutineItem>? items,
    List<RoutineSection>? sections,
    List<RoutineReminder>? reminders,
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    mode: mode ?? this.mode,
    details: identical(details, _unset) ? this.details : details as String?,
    weekdays: weekdays ?? this.weekdays,
    items: items ?? this.items,
    sections: sections ?? this.sections,
    reminders: reminders ?? this.reminders,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static const Object _unset = Object();
}

/// Atividade de uma rotina simples.
final class RoutineItem {
  const RoutineItem({
    required this.id,
    required this.routineId,
    required this.title,
    required this.position,
    this.details,
    this.completedDates = const {},
  });

  final String id;
  final String routineId;
  final String title;
  final String? details;
  final int position;

  /// Datas em que a atividade foi concluída.
  final Set<DateOnly> completedDates;

  bool isCompletedOn(DateOnly date) => completedDates.contains(date);

  RoutineItem copyWith({
    String? title,
    Object? details = _unset,
    int? position,
    Set<DateOnly>? completedDates,
  }) => RoutineItem(
    id: id,
    routineId: routineId,
    title: title ?? this.title,
    details: identical(details, _unset) ? this.details : details as String?,
    position: position ?? this.position,
    completedDates: completedDates ?? this.completedDates,
  );

  static const Object _unset = Object();
}

/// Card de uma rotina completa (ex.: Manhã, Tarde, Estudos).
///
/// Os horários intermediários são as fronteiras internas entre os intervalos.
final class RoutineSection {
  const RoutineSection({
    required this.id,
    required this.routineId,
    required this.title,
    required this.position,
    this.startMinutes,
    this.endMinutes,
    this.intervals = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String routineId;
  final String title;
  final int position;
  final int? startMinutes;
  final int? endMinutes;
  final List<RoutineInterval> intervals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isConfigured => startMinutes != null && endMinutes != null;

  int get taskCount => intervals.where((interval) => interval.hasTask).length;

  int completedOn(DateOnly date) => intervals
      .where((interval) => interval.hasTask && interval.isCompletedOn(date))
      .length;

  /// Fronteiras internas (horários intermediários), em ordem.
  List<int> get intermediateTimes => [
    for (var index = 1; index < intervals.length; index++)
      intervals[index].startMinutes,
  ];

  List<int> get boundaries => [
    ?startMinutes,
    ...intermediateTimes,
    ?endMinutes,
  ];

  RoutineSection copyWith({
    String? title,
    int? position,
    Object? startMinutes = _unset,
    Object? endMinutes = _unset,
    List<RoutineInterval>? intervals,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => RoutineSection(
    id: id,
    routineId: routineId,
    title: title ?? this.title,
    position: position ?? this.position,
    startMinutes: identical(startMinutes, _unset)
        ? this.startMinutes
        : startMinutes as int?,
    endMinutes: identical(endMinutes, _unset)
        ? this.endMinutes
        : endMinutes as int?,
    intervals: intervals ?? this.intervals,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );

  static const Object _unset = Object();
}

/// Intervalo de um card; também representa a tarefa associada.
///
/// Um intervalo sem `title` permanece vazio, mas conserva seu ID estável.
final class RoutineInterval {
  const RoutineInterval({
    required this.id,
    required this.sectionId,
    required this.startMinutes,
    required this.endMinutes,
    required this.position,
    this.title,
    this.details,
    this.completedDates = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sectionId;
  final int startMinutes;
  final int endMinutes;
  final int position;
  final String? title;
  final String? details;
  final Set<DateOnly> completedDates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasTask => title != null && title!.trim().isNotEmpty;

  bool isCompletedOn(DateOnly date) => hasTask && completedDates.contains(date);

  int get durationMinutes => endMinutes - startMinutes;

  RoutineInterval copyWith({
    int? startMinutes,
    int? endMinutes,
    int? position,
    Object? title = _unset,
    Object? details = _unset,
    Set<DateOnly>? completedDates,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => RoutineInterval(
    id: id,
    sectionId: sectionId,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    position: position ?? this.position,
    title: identical(title, _unset) ? this.title : title as String?,
    details: identical(details, _unset) ? this.details : details as String?,
    completedDates: completedDates ?? this.completedDates,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );

  static const Object _unset = Object();
}

/// Configuração de lembretes de uma rotina ou atividade.
///
/// `itemId` aponta para uma atividade simples; `intervalId` para um intervalo
/// completo. Ambos nulos significam lembrete da rotina inteira.
final class RoutineReminder {
  const RoutineReminder({
    required this.id,
    required this.routineId,
    required this.mode,
    required this.weekdays,
    this.itemId,
    this.intervalId,
    this.timesPerDay = 1,
    this.startMinutes = 8 * 60,
    this.endMinutes = 20 * 60,
    this.times = const [],
    this.enabled = true,
    this.paused = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String routineId;
  final String? itemId;
  final String? intervalId;
  final RoutineReminderMode mode;
  final int timesPerDay;
  final int startMinutes;
  final int endMinutes;

  /// Horários explícitos, em minutos desde a meia-noite.
  final List<int> times;

  /// 1 = segunda ... 7 = domingo.
  final Set<int> weekdays;
  final bool enabled;
  final bool paused;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => enabled && !paused;

  String? get targetId => intervalId ?? itemId;

  /// Horários efetivos no dia, ordenados e sem duplicatas.
  List<int> get effectiveTimes {
    if (mode == RoutineReminderMode.times) {
      return (times.toSet().toList()..sort()).where(_validMinute).toList();
    }
    final count = timesPerDay.clamp(1, 48);
    final start = startMinutes.clamp(0, 24 * 60 - 1);
    final end = endMinutes.clamp(start + 1, 24 * 60);
    final span = end - start;
    return [
      for (var index = 0; index < count; index++)
        start + (span * index ~/ count),
    ];
  }

  bool appliesOn(DateOnly date) =>
      isActive && weekdays.contains(date.weekday) && effectiveTimes.isNotEmpty;

  RoutineReminder copyWith({
    RoutineReminderMode? mode,
    Object? itemId = _unset,
    Object? intervalId = _unset,
    int? timesPerDay,
    int? startMinutes,
    int? endMinutes,
    List<int>? times,
    Set<int>? weekdays,
    bool? enabled,
    bool? paused,
    DateTime? updatedAt,
  }) => RoutineReminder(
    id: id,
    routineId: routineId,
    mode: mode ?? this.mode,
    itemId: identical(itemId, _unset) ? this.itemId : itemId as String?,
    intervalId: identical(intervalId, _unset)
        ? this.intervalId
        : intervalId as String?,
    timesPerDay: timesPerDay ?? this.timesPerDay,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    times: times ?? this.times,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
    paused: paused ?? this.paused,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static bool _validMinute(int value) => value >= 0 && value < 24 * 60;

  static const Object _unset = Object();
}

/// Registro imutável de uma execução de atividade.
///
/// `dedupeKey` impede que a mesma ação de notificação ou o mesmo toque manual
/// seja contado duas vezes, inclusive após sincronizações repetidas.
final class RoutineExecution {
  const RoutineExecution({
    required this.id,
    required this.routineId,
    required this.date,
    required this.executedAt,
    required this.origin,
    required this.dedupeKey,
    this.itemId,
    this.intervalId,
    this.reminderId,
  });

  final String id;
  final String routineId;
  final String? itemId;
  final String? intervalId;
  final String? reminderId;
  final DateOnly date;
  final DateTime executedAt;
  final RoutineExecutionOrigin origin;
  final String dedupeKey;

  RoutineExecution copyWith({
    DateTime? executedAt,
    RoutineExecutionOrigin? origin,
  }) => RoutineExecution(
    id: id,
    routineId: routineId,
    date: date,
    executedAt: executedAt ?? this.executedAt,
    origin: origin ?? this.origin,
    dedupeKey: dedupeKey,
    itemId: itemId,
    intervalId: intervalId,
    reminderId: reminderId,
  );
}
