import '../entities/tag.dart';

/// Persistência das tags compartilhadas por eventos e tarefas.
abstract interface class TagRepository {
  Future<List<Tag>> loadAll({bool includeDeleted = false});

  Future<void> save(Tag tag);

  Future<void> softDelete({required String id, required DateTime deletedAt});
}
