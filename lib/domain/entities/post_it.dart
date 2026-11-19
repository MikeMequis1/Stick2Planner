import '../../core/date_only.dart';

/// Natureza do post-it.
enum PostItType { task, event, recurringTodo }

/// Repetição de um evento.
enum EventRecurrence { none, daily, weekly, monthly, yearly }

/// Situação do post-it. Concluir ou cancelar nunca apaga o registro.
enum PostItStatus { active, done, cancelled }

/// Post-it da agenda: tarefa, evento ou TO-DO recorrente.
final class PostIt {
  const PostIt({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isHighlight = false,
    this.details,
    this.noteId,
    this.noteExcerpt,
    this.sourceNoteId,
    this.startDate,
    this.endDate,
    this.recurrence = EventRecurrence.none,
    this.recurrenceInterval = 1,
    this.recurrenceEndDate,
    this.seriesId,
    this.occurrenceStatuses = const {},
    this.timeMinutes,
    this.reminderMinutes,
    this.tagIds = const [],
    this.sortOrder = 0,
    this.lastRolloverAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final PostItType type;
  final PostItStatus status;

  /// Evento marcante/positivo (símbolo `+`).
  final bool isHighlight;

  final String? details;

  /// Nota conectada (referência viva).
  final String? noteId;

  /// Trecho copiado da nota; não acompanha edições posteriores.
  final String? noteExcerpt;

  /// Nota de origem de um snapshot; metadado de proveniência, não vínculo vivo.
  final String? sourceNoteId;

  /// Primeiro dia (data única para tarefas e recorrentes).
  final DateOnly? startDate;

  /// Último dia, apenas para eventos com duração maior que um dia.
  final DateOnly? endDate;

  /// Repetição do evento; `none` para tarefas e eventos únicos.
  final EventRecurrence recurrence;

  /// Intervalo em semanas ou meses conforme [recurrence].
  final int recurrenceInterval;

  /// Última data de início permitida para uma ocorrência recorrente.
  ///
  /// É distinta de [endDate], que representa a duração de uma ocorrência.
  final DateOnly? recurrenceEndDate;

  /// Raiz da série quando este registro é um segmento criado por divisão.
  ///
  /// `null` significa que o próprio `id` é a raiz. Segmentos compartilham o
  /// mesmo [seriesId] sem perder o vínculo histórico.
  final String? seriesId;

  String get effectiveSeriesId => seriesId ?? id;

  /// Conclusão/cancelamento por ocorrência, indexado pela data de início.
  ///
  /// Ausência de chave significa ocorrência ativa, salvo se a série inteira
  /// estiver concluída ou cancelada em [status].
  final Map<DateOnly, PostItStatus> occurrenceStatuses;

  /// Horário opcional do evento/tarefa em minutos desde a meia-noite.
  final int? timeMinutes;

  /// Minutos de antecedência do lembrete; exige [timeMinutes].
  final int? reminderMinutes;

  /// IDs das tags associadas; definições ficam em `tags`.
  final List<String> tagIds;

  /// Ordem visual dentro do dia.
  final int sortOrder;

  /// Último avanço automático de TO-DO recorrente (UTC).
  final DateTime? lastRolloverAt;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  bool get isEvent => type == PostItType.event;

  bool get isRecurring => type == PostItType.recurringTodo;

  bool get hasRecurrence => recurrence != EventRecurrence.none;

  bool get isRecurringEvent => isEvent && hasRecurrence;

  /// Qualquer post-it com regra de recorrência que gera ocorrências.
  ///
  /// Inclui eventos e tarefas; exclui o TO-DO recorrente, que é um único
  /// registro rolado diariamente, e registros Feito.
  bool get isRecurringSeries =>
      hasRecurrence && type != PostItType.recurringTodo && !isHighlight;

  int get safeRecurrenceInterval =>
      recurrenceInterval < 1 ? 1 : recurrenceInterval;

  DateOnly? get effectiveEndDate => endDate ?? startDate;

  /// Estado efetivo de uma ocorrência que começa em [occurrenceStart].
  ///
  /// O estado da série tem precedência: concluir/cancelar o evento inteiro
  /// afeta todas as ocorrências. Caso contrário, vale a marcação individual.
  PostItStatus statusOn(DateOnly occurrenceStart) {
    if (status != PostItStatus.active) return status;
    return occurrenceStatuses[occurrenceStart] ?? PostItStatus.active;
  }

  int get durationInDays {
    final start = startDate;
    final end = effectiveEndDate;
    if (start == null || end == null) return 0;
    return start.differenceInDays(end).abs() + 1;
  }

  /// TO-DO recorrente pendente adiado manualmente para o futuro.
  bool isPostponedOn(DateOnly today) {
    final start = startDate;
    return isRecurring &&
        status == PostItStatus.active &&
        start != null &&
        start.isAfter(today);
  }

  static const Object _unset = Object();

  PostIt copyWith({
    String? title,
    PostItType? type,
    PostItStatus? status,
    bool? isHighlight,
    Object? details = _unset,
    Object? noteId = _unset,
    Object? noteExcerpt = _unset,
    Object? sourceNoteId = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
    EventRecurrence? recurrence,
    int? recurrenceInterval,
    Object? recurrenceEndDate = _unset,
    Object? seriesId = _unset,
    Map<DateOnly, PostItStatus>? occurrenceStatuses,
    Object? timeMinutes = _unset,
    Object? reminderMinutes = _unset,
    List<String>? tagIds,
    int? sortOrder,
    Object? lastRolloverAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) {
    return PostIt(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      isHighlight: isHighlight ?? this.isHighlight,
      details: identical(details, _unset) ? this.details : details as String?,
      noteId: identical(noteId, _unset) ? this.noteId : noteId as String?,
      noteExcerpt: identical(noteExcerpt, _unset)
          ? this.noteExcerpt
          : noteExcerpt as String?,
      sourceNoteId: identical(sourceNoteId, _unset)
          ? this.sourceNoteId
          : sourceNoteId as String?,
      startDate: identical(startDate, _unset)
          ? this.startDate
          : startDate as DateOnly?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateOnly?,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: identical(recurrenceEndDate, _unset)
          ? this.recurrenceEndDate
          : recurrenceEndDate as DateOnly?,
      seriesId: identical(seriesId, _unset)
          ? this.seriesId
          : seriesId as String?,
      occurrenceStatuses: occurrenceStatuses ?? this.occurrenceStatuses,
      timeMinutes: identical(timeMinutes, _unset)
          ? this.timeMinutes
          : timeMinutes as int?,
      reminderMinutes: identical(reminderMinutes, _unset)
          ? this.reminderMinutes
          : reminderMinutes as int?,
      tagIds: tagIds ?? this.tagIds,
      sortOrder: sortOrder ?? this.sortOrder,
      lastRolloverAt: identical(lastRolloverAt, _unset)
          ? this.lastRolloverAt
          : lastRolloverAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  String toString() =>
      'PostIt(id: $id, type: $type, status: $status, start: $startDate)';
}
