import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/controllers/notes_controller.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/repositories/drift_note_repository.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_dependencies.dart';

void main() {
  group('NotesController', () {
    late AppDependencies dependencies;
    late NotesController notes;
    late DriftNoteRepository repository;

    setUp(() async {
      dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
      await dependencies.initialize();
      notes = dependencies.notes;
      repository = DriftNoteRepository(dependencies.database);
    });

    tearDown(() => dependencies.dispose());

    test('cria nota com linhas na ordem e checklist', () async {
      final note = await notes.createNote(
        title: '  Compras  ',
        type: NoteType.checklist,
        lines: const [
          NoteLineInput(text: 'Pão'),
          NoteLineInput(text: 'Leite', isChecked: true),
          NoteLineInput(text: 'Café'),
        ],
      );

      expect(note.title, 'Compras');
      expect(note.lines.map((line) => line.text), ['Pão', 'Leite', 'Café']);
      expect(note.lines.map((line) => line.position), [0, 1, 2]);
      expect(note.lines[1].isChecked, isTrue);
      expect(note.lines.map((line) => line.id).toSet(), hasLength(3));
    });

    test('edita título, tipo e ordem preservando IDs existentes', () async {
      final note = await notes.createNote(
        title: 'Lista',
        type: NoteType.checklist,
        lines: const [
          NoteLineInput(text: 'a'),
          NoteLineInput(text: 'b'),
          NoteLineInput(text: 'c'),
        ],
      );
      final firstId = note.lines.first.id;

      final updated = await notes.updateNote(
        note,
        title: 'Lista editada',
        type: NoteType.checklist,
        lines: [
          NoteLineInput(id: note.lines[2].id, text: 'c', isChecked: true),
          NoteLineInput(id: firstId, text: 'a'),
        ],
      );

      expect(updated.title, 'Lista editada');
      expect(updated.type, NoteType.checklist);
      expect(updated.lines.map((line) => line.text), ['c', 'a']);
      expect(updated.lines.first.id, note.lines[2].id);
      expect(updated.lines.first.isChecked, isTrue);
      expect(updated.createdAt, note.createdAt);
    });

    test('recusa título vazio sem persistir', () async {
      await expectLater(
        notes.createNote(
          title: '   ',
          type: NoteType.text,
          lines: const [NoteLineInput(text: 'linha')],
        ),
        throwsA(isA<NoteValidationException>()),
      );
      expect(notes.notes, isEmpty);
    });

    test('marca e desmarca linha', () async {
      final note = await notes.createNote(
        title: 'Checklist',
        type: NoteType.checklist,
        lines: const [
          NoteLineInput(text: 'Item 1'),
          NoteLineInput(text: 'Item 2'),
        ],
      );

      await notes.setLineChecked(note, note.lines.first.id, true);
      final refreshed = notes.findById(note.id)!;
      expect(refreshed.lines.first.isChecked, isTrue);
      expect(refreshed.lines[1].isChecked, isFalse);

      await notes.setLineChecked(refreshed, refreshed.lines.first.id, false);
      expect(notes.findById(note.id)!.lines.first.isChecked, isFalse);
    });

    test('persiste nota e linhas após reabrir', () async {
      final note = await notes.createNote(
        title: 'Persistente',
        type: NoteType.checklist,
        lines: const [
          NoteLineInput(text: 'um'),
          NoteLineInput(text: 'dois', isChecked: true),
        ],
      );

      final reopened = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      );
      await reopened.initialize();

      final loaded = reopened.notes.findById(note.id);
      expect(loaded, isNotNull);
      expect(loaded!.lines.map((line) => line.text), ['um', 'dois']);
      expect(loaded.lines[1].isChecked, isTrue);

      reopened.planner.dispose();
      reopened.notes.dispose();
    });

    test('cria nota de texto com Markdown em um único campo', () async {
      const markdown =
          '# Título\n\n'
          '**Negrito** e *itálico* em um parágrafo.\n\n'
          '- item um\n'
          '- item dois\n\n'
          '1. primeiro\n'
          '2. segundo\n\n'
          '[Link](https://example.com)\n\n'
          '```dart\nfinal x = 1;\n```';

      final note = await notes.createNote(
        title: 'Markdown',
        type: NoteType.text,
        markdown: markdown,
      );

      expect(note.markdown, markdown);
      expect(note.lines, isEmpty);

      final stored = await repository.findById(note.id);
      expect(stored, isNotNull);
      expect(stored!.markdown, markdown);
      expect(stored.lines, isEmpty);
      expect(stored.plainText, markdown);
    });

    test('edita Markdown e preserva a formatação após reabrir', () async {
      final note = await notes.createNote(
        title: 'Rascunho',
        type: NoteType.text,
        markdown: '# Original\n\ntexto',
      );

      const edited =
          '## Revisado\n\n'
          'Parágrafo com **ênfase** e [link](https://example.com).\n\n'
          '- [ ] pendente\n'
          '- [x] feito';
      final updated = await notes.updateNote(
        note,
        title: 'Revisado',
        type: NoteType.text,
        markdown: edited,
      );
      expect(updated.markdown, edited);
      expect(updated.lines, isEmpty);

      final reopened = AppDependencies.fromDatabase(
        dependencies.database,
        clock: FixedClock(DateTime(2026, 11, 3, 9)),
      );
      await reopened.initialize();

      final loaded = reopened.notes.findById(note.id);
      expect(loaded, isNotNull);
      expect(loaded!.markdown, edited);
      expect(loaded.lines, isEmpty);

      reopened.planner.dispose();
      reopened.notes.dispose();
    });

    test('converte linhas legadas em Markdown quando não há markdown', () async {
      final note = await notes.createNote(
        title: 'Legada',
        type: NoteType.text,
        lines: const [
          NoteLineInput(text: '# Título'),
          NoteLineInput(text: 'Parágrafo'),
        ],
      );

      expect(note.markdown, '# Título\nParágrafo');
      expect(note.lines, isEmpty);
    });

    test('excluir nota remove da lista e preserva tombstone', () async {
      final note = await notes.createNote(
        title: 'Descartável',
        type: NoteType.text,
        lines: const [NoteLineInput(text: 'texto')],
      );

      await notes.deleteNote(note);

      expect(notes.notes, isEmpty);
      expect(await repository.loadAll(), isEmpty);
      expect(await repository.loadAll(includeDeleted: true), hasLength(1));
    });
  });

  group('Vínculos nota ↔ post-it', () {
    late AppDependencies dependencies;
    late NotesController notes;

    setUp(() async {
      dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
      await dependencies.initialize();
      notes = dependencies.notes;
    });

    tearDown(() => dependencies.dispose());

    test('trecho copiado mantém snapshot sem vínculo vivo', () async {
      final note = await notes.createNote(
        title: 'Original',
        type: NoteType.text,
        markdown: '# Original\n\nLinha A\nLinha B',
      );

      final postIt = await dependencies.planner.createPostIt(
        title: 'Linha A',
        type: PostItType.task,
        noteExcerpt: 'Linha A\nLinha B',
      );
      await notes.updateNote(
        note,
        title: 'Original alterada',
        type: NoteType.text,
        markdown: '# Original alterada\n\nConteúdo novo',
      );

      final stored = dependencies.planner.postIts.single;
      expect(postIt.noteId, isNull);
      expect(stored.noteId, isNull);
      expect(stored.noteExcerpt, 'Linha A\nLinha B');
      expect(notes.findById(note.id)!.markdown, contains('Conteúdo novo'));
    });

    test('nota completa mantém vínculo vivo e permite desvincular', () async {
      final note = await notes.createNote(
        title: 'Nota viva',
        type: NoteType.text,
        lines: const [NoteLineInput(text: 'Conteúdo')],
      );
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
      );

      await dependencies.planner.linkNote(task, note);
      var current = dependencies.planner.postIts.single;
      expect(current.noteId, note.id);
      expect(current.noteExcerpt, isNull);

      final history = await DriftPostItRepository(
        dependencies.database,
      ).loadHistory(task.id);
      expect(
        history.map((entry) => entry.action),
        contains(PostItHistoryAction.noteLinked),
      );

      await dependencies.planner.unlinkNote(current);
      current = dependencies.planner.postIts.single;
      expect(current.noteId, isNull);
      final updatedHistory = await DriftPostItRepository(
        dependencies.database,
      ).loadHistory(task.id);
      expect(
        updatedHistory.map((entry) => entry.action),
        contains(PostItHistoryAction.noteUnlinked),
      );
    });

    test('excluir nota desvincula post-its e preserva snapshot', () async {
      final note = await notes.createNote(
        title: 'Nota',
        type: NoteType.text,
        lines: const [NoteLineInput(text: 'Trecho')],
      );
      final linked = await dependencies.planner.createPostIt(
        title: 'Vinculada',
        type: PostItType.task,
        noteId: note.id,
      );
      final snapshot = await dependencies.planner.createPostIt(
        title: 'Snapshot',
        type: PostItType.task,
        noteExcerpt: 'Trecho',
      );

      await notes.deleteNote(note);
      await dependencies.planner.refresh();

      final byId = {
        for (final postIt in dependencies.planner.postIts) postIt.id: postIt,
      };
      expect(byId[linked.id]!.noteId, isNull);
      expect(byId[linked.id]!.noteExcerpt, isNull);
      expect(byId[snapshot.id]!.noteExcerpt, 'Trecho');
      expect(byId[snapshot.id]!.title, 'Snapshot');
    });

    test('excluir nota não apaga tarefa nem seu título/detalhes', () async {
      final note = await notes.createNote(
        title: 'Nota',
        type: NoteType.text,
        lines: const [NoteLineInput(text: 'x')],
      );
      final task = await dependencies.planner.createPostIt(
        title: 'Tarefa',
        type: PostItType.task,
        details: 'detalhes',
        startDate: DateOnly(2026, 11, 3),
        noteId: note.id,
      );

      await notes.deleteNote(note);
      await dependencies.planner.refresh();

      final current = dependencies.planner.postIts.single;
      expect(current.id, task.id);
      expect(current.title, 'Tarefa');
      expect(current.details, 'detalhes');
      expect(current.startDate, DateOnly(2026, 11, 3));
      expect(current.noteId, isNull);
    });
  });
}
