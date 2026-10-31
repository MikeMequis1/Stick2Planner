import '../../core/date_only.dart';

/// Natureza do post-it.
enum PostItType { task, event, recurringTodo }

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
    this.startDate,
    this.endDate,
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

  /// Primeiro dia (data única para tarefas e recorrentes).
  final DateOnly? startDate;

  /// Último dia, apenas para eventos com duração maior que um dia.
  final DateOnly? endDate;

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

  DateOnly? get effectiveEndDate => endDate ?? startDate;

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

  @override
  String toString() =>
      'PostIt(id: $id, type: $type, status: $status, start: $startDate)';
}
