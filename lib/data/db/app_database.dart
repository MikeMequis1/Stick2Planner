import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Preferências de visualização e estado leve do aplicativo.
///
/// Chave/valor mantém a tabela estável entre versões: novas preferências não
/// exigem migração de esquema.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Banco local do aplicativo.
///
/// As tabelas de domínio (post-its, notas, histórico) são adicionadas na
/// Etapa 1. O esquema começa na versão 1 com [AppSettings].
@DriftDatabase(tables: [AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
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
