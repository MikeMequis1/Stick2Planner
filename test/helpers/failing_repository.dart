import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';
import 'package:stick2planner/domain/repositories/post_it_repository.dart';

/// Decorator que injeta falhas de escrita para testar consistência/rollback.
final class FailingPostItRepository implements PostItRepository {
  FailingPostItRepository(this.delegate);

  final PostItRepository delegate;

  bool failWrites = true;
  int writeAttempts = 0;

  Never _fail() {
    writeAttempts++;
    throw StateError('falha de persistência simulada');
  }

  @override
  Future<List<PostIt>> loadAll({bool includeDeleted = false}) =>
      delegate.loadAll(includeDeleted: includeDeleted);

  @override
  Future<PostIt?> findById(String id) => delegate.findById(id);

  @override
  Future<void> save(PostIt postIt, {PostItHistoryEntry? history}) {
    if (failWrites) _fail();
    return delegate.save(postIt, history: history);
  }

  @override
  Future<void> saveBatch(
    List<PostIt> postIts, {
    List<PostItHistoryEntry> history = const [],
  }) {
    if (failWrites) _fail();
    return delegate.saveBatch(postIts, history: history);
  }

  @override
  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
    PostItHistoryEntry? history,
  }) {
    if (failWrites) _fail();
    return delegate.softDelete(
      id: id,
      deletedAt: deletedAt,
      history: history,
    );
  }

  @override
  Future<List<PostItHistoryEntry>> loadHistory(String postItId) =>
      delegate.loadHistory(postItId);
}
