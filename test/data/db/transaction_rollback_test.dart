import 'package:drift/native.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it_history.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/entities.dart';

void main() {
  test('falha ao gravar histórico reverte o post-it na mesma transação', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftPostItRepository(db);
    final postIt = buildPostIt(id: 'p1', title: 'Não deve persistir');

    await expectLater(
      repository.save(
        postIt,
        history: PostItHistoryEntry(
          id: 'h1',
          postItId: 'post-it-inexistente',
          action: PostItHistoryAction.created,
          createdAt: DateTime.utc(2026, 11, 3),
        ),
      ),
      throwsA(anything),
    );

    expect(await repository.loadAll(includeDeleted: true), isEmpty);
    expect(await repository.loadHistory('p1'), isEmpty);
  });

  test('falha no lote reverte todas as alterações', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DriftPostItRepository(db);
    final first = buildPostIt(
      id: 'p1',
      title: 'Primeira',
      sortOrder: 0,
    );
    final second = buildPostIt(
      id: 'p2',
      title: 'Segunda',
      sortOrder: 1,
    );
    await repository.saveBatch([first, second]);

    await expectLater(
      repository.saveBatch(
        [
          first.copyWith(title: 'Alterada', updatedAt: DateTime.utc(2026, 11, 4)),
          second.copyWith(
            title: 'Também alterada',
            updatedAt: DateTime.utc(2026, 11, 4),
          ),
        ],
        history: [
          PostItHistoryEntry(
            id: 'h1',
            postItId: 'inexistente',
            action: PostItHistoryAction.updated,
            createdAt: DateTime.utc(2026, 11, 4),
          ),
        ],
      ),
      throwsA(anything),
    );

    final persisted = await repository.loadAll();
    expect(persisted.map((postIt) => postIt.title), [
      'Primeira',
      'Segunda',
    ]);
    expect(await repository.loadHistory('p1'), isEmpty);
  });
}
