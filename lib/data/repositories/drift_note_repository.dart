import 'package:drift/drift.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../db/app_database.dart';
import '../db/converters.dart';
import '../mappers/mappers.dart';

final class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Note>> loadAll({bool includeDeleted = false}) async {
    final notesQuery = _db.select(_db.notes)
      ..orderBy([(table) => OrderingTerm(expression: table.updatedAt)]);
    if (!includeDeleted) {
      notesQuery.where((table) => table.deletedAt.isNull());
    }

    final noteRows = await notesQuery.get();
    if (noteRows.isEmpty) return const [];

    final lineRows =
        await (_db.select(_db.noteLines)
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    final linesByNote = <String, List<NoteLineRow>>{};
    for (final line in lineRows) {
      linesByNote.putIfAbsent(line.noteId, () => []).add(line);
    }

    return [
      for (final row in noteRows)
        noteFromRows(row, linesByNote[row.id] ?? const []),
    ];
  }

  @override
  Future<Note?> findById(String id) async {
    final row = await (_db.select(
      _db.notes,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final lineRows =
        await (_db.select(_db.noteLines)
              ..where((table) => table.noteId.equals(id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    return noteFromRows(row, lineRows);
  }

  @override
  Future<void> save(Note note) {
    return _db.transaction(() async {
      await _db.into(_db.notes).insertOnConflictUpdate(noteToCompanion(note));
      await (_db.delete(
        _db.noteLines,
      )..where((table) => table.noteId.equals(note.id))).go();
      if (note.lines.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.noteLines,
            note.lines.map(noteLineToCompanion).toList(growable: false),
          );
        });
      }
    });
  }

  @override
  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) {
    final timestamp = dateTimeToStorage(deletedAt);
    return _db.transaction(() async {
      await (_db.update(_db.notes)..where((table) => table.id.equals(id))).write(
        NotesCompanion(
          deletedAt: Value(timestamp),
          updatedAt: Value(timestamp),
        ),
      );
      // Vínculo deixa de ser válido; o snapshot (noteExcerpt) é preservado.
      await (_db.update(
        _db.postIts,
      )..where((table) => table.noteId.equals(id))).write(
        const PostItsCompanion(noteId: Value(null)),
      );
    });
  }
}
