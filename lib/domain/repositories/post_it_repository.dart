import '../entities/post_it.dart';
import '../entities/post_it_history.dart';

/// Contrato de persistência dos post-its.
///
/// A implementação local é drift; uma futura sincronização adicionará outra
/// implementação sem alterar domínio ou UI.
abstract interface class PostItRepository {
  Future<List<PostIt>> loadAll({bool includeDeleted = false});

  Future<PostIt?> findById(String id);

  /// Insere ou atualiza; quando [history] é informado, grava na mesma
  /// transação.
  Future<void> save(PostIt postIt, {PostItHistoryEntry? history});

  /// Atualização em lote e transacional (reordenação, rollover).
  Future<void> saveAll(List<PostIt> postIts);

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  });

  Future<List<PostItHistoryEntry>> loadHistory(String postItId);
}
