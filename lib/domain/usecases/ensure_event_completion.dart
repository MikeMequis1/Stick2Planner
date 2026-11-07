import '../../core/date_only.dart';
import '../entities/post_it.dart';
import '../entities/post_it_history.dart';

/// Resultado da conclusão automática de eventos passados.
final class EventCompletionPlan {
  const EventCompletionPlan({required this.updates, required this.history});

  final List<PostIt> updates;
  final List<PostItHistoryEntry> history;

  bool get hasChanges => updates.isNotEmpty;

  static const empty = EventCompletionPlan(updates: [], history: []);
}

/// Marca eventos ativos cuja data final já passou como concluídos.
///
/// Eventos sem `endDate` não entram; a data é comparada como data local, sem
/// horário, e o estado nunca vira cancelamento/exclusão.
final class EnsureEventCompletion {
  const EnsureEventCompletion();

  EventCompletionPlan call({
    required List<PostIt> postIts,
    required DateOnly today,
    required DateTime now,
    required String Function() idGenerator,
  }) {
    final updates = <PostIt>[];
    final history = <PostItHistoryEntry>[];

    for (final postIt in postIts) {
      final end = postIt.endDate;
      if (!postIt.isEvent ||
          postIt.status != PostItStatus.active ||
          end == null ||
          !end.isBefore(today)) {
        continue;
      }
      updates.add(postIt.copyWith(status: PostItStatus.done, updatedAt: now));
      history.add(
        PostItHistoryEntry(
          id: idGenerator(),
          postItId: postIt.id,
          action: PostItHistoryAction.eventCompleted,
          fromValue: PostItStatus.active.name,
          toValue: PostItStatus.done.name,
          createdAt: now,
        ),
      );
    }

    if (updates.isEmpty) return EventCompletionPlan.empty;
    return EventCompletionPlan(updates: updates, history: history);
  }
}
