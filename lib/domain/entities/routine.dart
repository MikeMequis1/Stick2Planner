import '../../core/date_only.dart';

/// Formato de organização de uma rotina.
enum RoutineMode { simple, complete }

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
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    mode: mode ?? this.mode,
    details: identical(details, _unset) ? this.details : details as String?,
    weekdays: weekdays ?? this.weekdays,
    items: items ?? this.items,
    sections: sections ?? this.sections,
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
