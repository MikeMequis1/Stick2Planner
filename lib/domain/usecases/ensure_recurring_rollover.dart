import '../../core/date_only.dart';
import '../entities/post_it.dart';
import '../entities/post_it_history.dart';

/// Resultado do cálculo de avanço de TO-DOs recorrentes.
final class RecurringRolloverPlan {
  const RecurringRolloverPlan({
    required this.updates,
    required this.history,
  });

  final List<PostIt> updates;
  final List<PostItHistoryEntry> history;

  bool get hasChanges => updates.isNotEmpty;

  static const empty = RecurringRolloverPlan(updates: [], history: []);
}

/// Calcula o avanço diário de TO-DOs recorrentes pendentes.
///
/// Regras:
/// - pendente com data nula/atrasada avança para [today] (uma única escrita);
/// - data futura (adiamento manual) é preservada;
/// - concluído/cancelado não avança;
/// - executar novamente com o mesmo estado não gera alterações (idempotente);
/// - identidade, título, detalhes, nota e histórico de campos são preservados.
final class EnsureRecurringRollover {
  const EnsureRecurringRollover();

  RecurringRolloverPlan call({
    required List<PostIt> postIts,
    required DateOnly today,
    required DateTime now,
    required String Function() idGenerator,
  }) {
    final updates = <PostIt>[];
    final history = <PostItHistoryEntry>[];

    for (final postIt in postIts) {
      if (!postIt.isRecurring || postIt.status != PostItStatus.active) {
        continue;
      }

      final start = postIt.startDate;
      if (start != null && !start.isBefore(today)) {
        continue;
      }

      final updated = postIt.copyWith(
        startDate: today,
        lastRolloverAt: now,
        updatedAt: now,
      );
      updates.add(updated);
      history.add(
        PostItHistoryEntry(
          id: idGenerator(),
          postItId: postIt.id,
          action: PostItHistoryAction.rolloverAdvanced,
          fromValue: start?.toIso8601String(),
          toValue: today.toIso8601String(),
          createdAt: now,
        ),
      );
    }

    if (updates.isEmpty) return RecurringRolloverPlan.empty;
    return RecurringRolloverPlan(updates: updates, history: history);
  }
}
