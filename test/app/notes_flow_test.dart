import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/app_strings.dart';
import 'package:flutter_schedule/app/bootstrap.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/domain/entities/note.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/features/notes/note_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpPlanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 3, 9));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  Future<void> openNotes(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.notes),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cria nota em lista e converte trecho em snapshot', (
    tester,
  ) async {
    final dependencies = await pumpPlanner(tester);
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Compras da semana',
    );
    await tester.tap(find.text(AppStrings.noteTypeChecklist));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-line-0')),
      'Pão',
    );
    await tester.tap(find.byKey(const Key('note-add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-line-1')),
      'Leite',
    );
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    expect(dependencies.notes.notes, hasLength(1));
    expect(find.text('Compras da semana'), findsOneWidget);

    await tester.tap(find.text('Compras da semana'));
    await tester.pumpAndSettle();
    expect(find.text('Pão'), findsOneWidget);
    expect(find.text('Leite'), findsOneWidget);

    await tester.tap(find.text('Pão'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('note-save')), findsOneWidget);
    Navigator.of(tester.element(find.byKey(const Key('note-save')))).pop();
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Pão'));
    await tester.longPress(find.text('Leite'));
    await tester.pumpAndSettle();
    expect(find.text('2 selecionada(s)'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('note-create-from-selection')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('snapshot-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-snapshot')));
    await tester.pumpAndSettle();

    final postIt = dependencies.planner.postIts.single;
    expect(postIt.noteId, isNull);
    expect(postIt.noteExcerpt, 'Pão\nLeite');
    expect(postIt.type, PostItType.task);
    expect(postIt.startDate, isNull);
  });

  testWidgets('barra Markdown aplica título, negrito e prévia', (tester) async {
    final dependencies = await pumpPlanner(tester);
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Ferramentas',
    );
    await tester.enterText(
      find.byKey(const Key('note-markdown')),
      'Linha',
    );

    final field = tester.widget<TextField>(
      find.byKey(const Key('note-markdown')),
    );
    await tester.tap(find.byKey(const Key('note-md-h1')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, '# Linha');

    field.controller!.selection = const TextSelection(
      baseOffset: 2,
      extentOffset: 7,
    );
    await tester.tap(find.byKey(const Key('note-md-bold')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, '# **Linha**');

    await tester.tap(find.byKey(const Key('note-md-preview')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.markdownPreviewTitle), findsOneWidget);
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(
      tester.getCenter(find.byType(MarkdownBody)).dx,
      greaterThan(
        tester.getCenter(find.byKey(const Key('note-markdown'))).dx,
      ),
    );

    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();
    expect(dependencies.notes.notes.single.markdown, '# **Linha**');
  });

  testWidgets('barra Markdown aplica título, negrito e prévia', (tester) async {
    final dependencies = await pumpPlanner(tester);
    await openNotes(tester);

    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Ferramentas',
    );
    await tester.enterText(
      find.byKey(const Key('note-markdown')),
      'Linha',
    );

    final field = tester.widget<TextField>(
      find.byKey(const Key('note-markdown')),
    );
    await tester.tap(find.byKey(const Key('note-md-h1')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, '# Linha');

    field.controller!.selection = const TextSelection(
      baseOffset: 2,
      extentOffset: 7,
    );
    await tester.tap(find.byKey(const Key('note-md-bold')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, '# **Linha**');

    await tester.tap(find.byKey(const Key('note-md-preview')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.markdownPreviewTitle), findsOneWidget);
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(
      tester.getCenter(find.byType(MarkdownBody)).dx,
      greaterThan(
        tester.getCenter(find.byKey(const Key('note-markdown'))).dx,
      ),
    );

    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();
    expect(dependencies.notes.notes.single.markdown, '# **Linha**');
  });

  testWidgets('cria nota Markdown e renderiza a formatação', (tester) async {
    final dependencies = await pumpPlanner(tester);
    await openNotes(tester);

    const markdown =
        '# Título\n\n'
        '**Negrito** e *itálico* em um parágrafo.\n\n'
        '- item um\n'
        '- item dois\n\n'
        '[Link](https://example.com)';
    await tester.tap(find.byKey(const Key('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Nota Markdown',
    );
    await tester.enterText(
      find.byKey(const Key('note-markdown')),
      markdown,
    );
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    final note = dependencies.notes.notes.single;
    expect(note.type, NoteType.text);
    expect(note.markdown, markdown);
    expect(note.lines, isEmpty);
    expect(find.text('Nota Markdown'), findsOneWidget);

    await tester.tap(find.text('Nota Markdown'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('note-create-from-markdown')),
      findsOneWidget,
    );
    expect(find.textContaining('Título', findRichText: true), findsOneWidget);
    expect(find.textContaining('Negrito', findRichText: true), findsOneWidget);
    expect(find.textContaining('item um', findRichText: true), findsOneWidget);
    // O detalhe interpreta o Markdown em vez de exibir a sintaxe crua.
    expect(find.textContaining('# Título', findRichText: true), findsNothing);
    expect(find.textContaining('**Negrito**', findRichText: true), findsNothing);

    await tester.tap(
      find
          .ancestor(
            of: find.byType(MarkdownBody),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('note-save')), findsOneWidget);
  });

  testWidgets('cria snapshot a partir de um trecho Markdown', (tester) async {
    final dependencies = await pumpPlanner(tester);
    final note = await dependencies.notes.createNote(
      title: 'Receita',
      type: NoteType.text,
      markdown: '# Receita\n\n- farinha\n- água',
    );
    await tester.pumpAndSettle();
    await openNotes(tester);

    await tester.tap(find.text('Receita'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('note-create-from-markdown')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('snapshot-title')),
      'Farinha',
    );
    final field = tester.widget<TextField>(
      find.byKey(const Key('snapshot-markdown')),
    );
    final source = field.controller!.text;
    final start = source.indexOf('- farinha');
    field.controller!.selection = TextSelection(
      baseOffset: start,
      extentOffset: start + '- farinha'.length,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm-markdown-snapshot')));
    await tester.pumpAndSettle();

    final postIt = dependencies.planner.postIts.single;
    expect(postIt.title, 'Farinha');
    expect(postIt.noteId, isNull);
    expect(postIt.noteExcerpt, '- farinha');
    expect(postIt.sourceNoteId, note.id);
    expect(postIt.type, PostItType.task);

    final detail = dependencies.notes.notes.single;
    expect(detail.markdown, '# Receita\n\n- farinha\n- água');

    // Sem seleção, o snapshot usa a nota inteira.
    await tester.tap(find.byKey(const Key('note-create-from-markdown')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('snapshot-title')),
      'Receita completa',
    );
    await tester.tap(find.byKey(const Key('confirm-markdown-snapshot')));
    await tester.pumpAndSettle();

    final full = dependencies.planner.postIts.singleWhere(
      (item) => item.title == 'Receita completa',
    );
    expect(full.noteExcerpt, '# Receita\n\n- farinha\n- água');
    expect(full.noteId, isNull);
  });

  testWidgets('vincula nota a tarefa e abre a nota pelo post-it', (tester) async {
    final dependencies = await pumpPlanner(tester);
    final note = await dependencies.notes.createNote(
      title: 'Nota vinculada',
      type: NoteType.text,
      markdown: 'Conteúdo vivo',
    );
    final task = await dependencies.planner.createPostIt(
      title: 'Tarefa com nota',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 3),
    );

    await openNotes(tester);
    await tester.tap(find.text('Nota vinculada'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('note-link-post-it')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tarefa com nota'));
    await tester.pumpAndSettle();

    expect(
      dependencies.planner.postIts.singleWhere((item) => item.id == task.id).noteId,
      note.id,
    );

    Navigator.of(tester.element(find.byType(NoteDetailPage))).pop();
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text(AppStrings.agenda),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('post-it-${task.id}')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('details-open-note')));
    expect(find.text(AppStrings.linkedNoteChip), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-open-note')));
    await tester.pumpAndSettle();

    expect(find.byType(NoteDetailPage), findsOneWidget);
    expect(find.text('Nota vinculada'), findsOneWidget);
  });

  testWidgets('edita e exclui nota pelo detalhe', (tester) async {
    final dependencies = await pumpPlanner(tester);
    final note = await dependencies.notes.createNote(
      title: 'Nota antiga',
      type: NoteType.text,
      markdown: 'linha',
    );
    await tester.pumpAndSettle();
    await openNotes(tester);

    await tester.tap(find.text('Nota antiga'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('note-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Nota nova',
    );
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();

    expect(dependencies.notes.findById(note.id)!.title, 'Nota nova');

    await tester.tap(find.byKey(const Key('note-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-note')));
    await tester.pumpAndSettle();

    expect(dependencies.notes.notes, isEmpty);
    expect(find.text('Nota nova'), findsNothing);
  });

  testWidgets('snapshot não ganha vínculo ao editar a nota', (tester) async {
    final dependencies = await pumpPlanner(tester);
    final note = await dependencies.notes.createNote(
      title: 'Nota mãe',
      type: NoteType.text,
      markdown: 'Trecho original',
    );
    final snapshot = await dependencies.planner.createPostIt(
      title: 'Snapshot',
      type: PostItType.task,
      noteExcerpt: 'Trecho original',
    );

    await dependencies.notes.updateNote(
      note,
      title: 'Nota editada',
      type: NoteType.text,
      markdown: 'Conteúdo alterado',
    );
    await tester.pumpAndSettle();

    final stored = dependencies.planner.postIts.singleWhere(
      (item) => item.id == snapshot.id,
    );
    expect(stored.noteExcerpt, 'Trecho original');
    expect(stored.noteId, isNull);
  });
}
