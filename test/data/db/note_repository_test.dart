import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/entities.dart';

void main() {
  late AppDatabase db;
  late DriftNoteRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftNoteRepository(db);
  });

  tearDown(() => db.close());

  test('grava nota e linhas na ordem', () async {
    final note = buildNote(lines: ['pão', 'leite', 'café']);

    await repository.save(note);
    final loaded = await repository.findById(note.id);

    expect(loaded, isNotNull);
    expect(loaded!.type, NoteType.checklist);
    expect(loaded.lines.map((line) => line.text), ['pão', 'leite', 'café']);
    expect(loaded.plainText, 'pão\nleite\ncafé');
  });

  test('atualizar substitui linhas removidas', () async {
    final note = buildNote(lines: ['a', 'b']);
    await repository.save(note);

    final updated = buildNote(
      lines: ['a', 'c'],
      updatedAt: DateTime.utc(2026, 11, 1, 9),
    );
    await repository.save(updated);

    final loaded = await repository.findById(note.id);
    expect(loaded!.lines.map((line) => line.text), ['a', 'c']);
  });

  test('exclusão lógica remove da listagem padrão e preserva linhas', () async {
    final note = buildNote();
    await repository.save(note);

    await repository.softDelete(
      id: note.id,
      deletedAt: DateTime.utc(2026, 11, 1),
    );

    expect(await repository.loadAll(), isEmpty);
    expect(await repository.loadAll(includeDeleted: true), hasLength(1));
    expect(await repository.findById(note.id), isNotNull);
  });

  test('excluir nota desvincula post-it e preserva o trecho', () async {
    final note = buildNote(id: 'nota-1');
    await repository.save(note);
    final postItRepository = DriftPostItRepository(db);
    await postItRepository.save(
      buildPostIt(id: 'p1', noteId: note.id, noteExcerpt: 'Primeira'),
    );

    await repository.softDelete(id: note.id, deletedAt: DateTime.utc(2026, 11, 1));

    final postIt = await postItRepository.findById('p1');
    expect(postIt!.noteId, isNull);
    expect(postIt.noteExcerpt, 'Primeira');
  });

  test('persiste nota e linhas após reabrir o banco', () async {
    final tempDir = await Directory.systemTemp.createTemp('planner_notes_');
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File(p.join(tempDir.path, 'planner.sqlite'));

    var database = AppDatabase(NativeDatabase(file));
    await DriftNoteRepository(database).save(
      buildNote(id: 'nota-1', lines: ['um', 'dois']),
    );
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);

    final loaded = await DriftNoteRepository(database).findById('nota-1');
    expect(loaded, isNotNull);
    expect(loaded!.lines.map((line) => line.text), ['um', 'dois']);
  });
}
