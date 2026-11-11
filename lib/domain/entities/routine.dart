import '../../core/date_only.dart';

/// Rotina semanal: um conjunto de atividades repetido em dias escolhidos.
///
/// A conclusão é por ocorrência (`atividade + data`), nunca global.
final class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.details,
    this.weekdays = const {},
    this.items = const [],
  });

  final String id;
  final String name;
  final String? details;

  /// 1 = segunda ... 7 = domingo.
  final Set<int> weekdays;
  final List<RoutineItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Data local em que a rotina foi criada. A recorrência nunca começa antes
  /// dela, mesmo que o dispositivo fique offline por vários dias.
  DateOnly get createdOn => DateOnly.fromDateTime(createdAt.toLocal());

  /// A rotina só ocorre a partir do dia da criação e nos dias escolhidos.
  ///
  /// `createdAt` é a data de criação do registro, não uma data de início
  /// configurável: as duas informações continuam distintas no modelo, mas a
  /// programação semanal é ancorada na criação para impedir ocorrências
  /// retroativas.
  bool runsOn(DateOnly date) =>
      !date.isBefore(createdOn) && weekdays.contains(date.weekday);

  int completedOn(DateOnly date) =>
      items.where((item) => item.isCompletedOn(date)).length;

  Routine copyWith({
    String? name,
    Object? details = _unset,
    Set<int>? weekdays,
    List<RoutineItem>? items,
    DateTime? updatedAt,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    details: identical(details, _unset) ? this.details : details as String?,
    weekdays: weekdays ?? this.weekdays,
    items: items ?? this.items,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static const Object _unset = Object();
}

/// Atividade de uma rotina.
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
