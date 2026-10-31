import '../entities/note.dart';

/// Contrato de persistência das notas e suas linhas.
abstract interface class NoteRepository {
  Future<List<Note>> loadAll({bool includeDeleted = false});

  Future<Note?> findById(String id);

  /// Insere ou atualiza a nota e substitui suas linhas em uma transação.
  Future<void> save(Note note);

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  });
}
