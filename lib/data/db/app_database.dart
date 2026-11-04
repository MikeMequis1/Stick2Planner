import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/date_only.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Banco local do aplicativo.
///
/// Esquema v5: preferências, post-its, notas (texto Markdown ou linhas),
/// histórico, snapshots, fila de sincronização e revisões por entidade.
@DriftDatabase(
  tables: [
    AppSettings,
    Notes,
    NoteLines,
    PostIts,
    PostItHistoryEntries,
    SyncOutbox,
    SyncRowStates,
    SyncStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // v1 tinha apenas app_settings; as tabelas de domínio entram aqui.
        await migrator.createTable(notes);
        await migrator.createTable(noteLines);
        await migrator.createTable(postIts);
        await migrator.createTable(postItHistoryEntries);
      }
      if (from < 3) {
        // Em bancos v1 a tabela acabou de ser criada já no formato v3.
        if (from >= 2) {
          await migrator.addColumn(notes, notes.markdown);
          // Converte notas de texto legadas (linhas) para um único Markdown.
          await customStatement('''
            UPDATE notes SET markdown = (
              SELECT group_concat(content, char(10))
              FROM (
                SELECT content
                FROM note_lines
                WHERE note_id = notes.id
                ORDER BY position ASC
              )
            )
            WHERE type = 'text'
          ''');
          await customStatement('''
            DELETE FROM note_lines
            WHERE note_id IN (SELECT id FROM notes WHERE type = 'text')
          ''');
        }
      }
      if (from < 4 && from >= 2) {
        // Proveniência de snapshots; bancos v1 já criam a tabela atual.
        await migrator.addColumn(postIts, postIts.sourceNoteId);
      }
      if (from < 5) {
        // Fundação de sincronização; nenhuma tabela de domínio muda.
        await migrator.createTable(syncOutbox);
        await migrator.createTable(syncRowStates);
        await migrator.createTable(syncStates);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Conexão em arquivo dentro do diretório de dados do aplicativo.
  ///
  /// O caminho depende de `path_provider`, por isso é resolvido de forma
  /// preguiçosa; testes injetam um executor próprio.
  static QueryExecutor openConnection({String fileName = 'planner.sqlite'}) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      final file = File(p.join(directory.path, fileName));
      return NativeDatabase.createInBackground(file);
    });
  }

  /// Instância pronta para o aplicativo.
  static AppDatabase open() => AppDatabase(openConnection());
}
