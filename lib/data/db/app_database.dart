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
/// Esquema v2: preferências, post-its, notas/linhas e histórico.
@DriftDatabase(
  tables: [AppSettings, Notes, NoteLines, PostIts, PostItHistoryEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

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
