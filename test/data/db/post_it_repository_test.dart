import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/db/app_database.dart';
import 'package:flutter_schedule/data/repositories/drift_note_repository.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/domain/entities/post_it_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/entities.dart';

void main() {
  late AppDatabase db;
  late DriftPostItRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftPostItRepository(db);
  });

  tearDown(() => db.close());

  test('grava e lê tarefa sem data', () async {
    final postIt = buildPostIt(details: 'detalhes');

    await repository.save(postIt);

    final loaded = await repository.findById(postIt.id);
    expect(loaded, isNotNull);
    expect(loaded!.title, 'Tarefa');
    expect(loaded.type, PostItType.task);
    expect(loaded.status, PostItStatus.active);
    expect(loaded.details, 'detalhes');
    expect(loaded.startDate, isNull);
  });

  test('preserva intervalo de evento multi-dia', () async {
    final postIt = buildPostIt(
      id: 'evento-1',
      type: PostItType.event,
      isHighlight: true,
      startDate: DateOnly(2026, 11, 2),
      endDate: DateOnly(2026, 11, 6),
    );

    await repository.save(postIt);
    final loaded = await repository.findById(postIt.id);

    expect(loaded!.startDate, DateOnly(2026, 11, 2));
    expect(loaded.endDate, DateOnly(2026, 11, 6));
    expect(loaded.durationInDays, 5);
    expect(loaded.isHighlight, isTrue);
  });

  test('ordena post-its por sortOrder', () async {
    await repository.save(buildPostIt(id: 'p2', sortOrder: 2));
    await repository.save(buildPostIt(id: 'p1', sortOrder: 0));
    await repository.save(buildPostIt(id: 'p3', sortOrder: 1));

    final loaded = await repository.loadAll();

    expect(loaded.map((item) => item.id), ['p1', 'p3', 'p2']);
  });

  test('exclusão lógica mantém o registro', () async {
    final postIt = buildPostIt();
    await repository.save(postIt);

    await repository.softDelete(
      id: postIt.id,
      deletedAt: DateTime.utc(2026, 11, 1, 10),
    );

    expect(await repository.loadAll(), isEmpty);
    final withDeleted = await repository.loadAll(includeDeleted: true);
    expect(withDeleted, hasLength(1));
    expect(withDeleted.single.deletedAt, isNotNull);
    expect(withDeleted.single.updatedAt, DateTime.utc(2026, 11, 1, 10));
  });

  test('grava histórico na mesma transação do post-it', () async {
    final postIt = buildPostIt();
    final history = PostItHistoryEntry(
      id: 'h1',
      postItId: postIt.id,
      action: PostItHistoryAction.created,
      createdAt: DateTime.utc(2026, 10, 31, 12),
    );

    await repository.save(postIt, history: history);

    final loaded = await repository.loadHistory(postIt.id);
    expect(loaded, hasLength(1));
    expect(loaded.single.action, PostItHistoryAction.created);
  });

  test('histórico acumula em ordem cronológica', () async {
    final postIt = buildPostIt();
    await repository.save(
      postIt,
      history: PostItHistoryEntry(
        id: 'h1',
        postItId: postIt.id,
        action: PostItHistoryAction.created,
        createdAt: DateTime.utc(2026, 10, 31, 8),
      ),
    );
    await repository.save(
      postIt,
      history: PostItHistoryEntry(
        id: 'h2',
        postItId: postIt.id,
        action: PostItHistoryAction.statusChanged,
        fromValue: 'active',
        toValue: 'done',
        createdAt: DateTime.utc(2026, 10, 31, 9),
      ),
    );

    final loaded = await repository.loadHistory(postIt.id);
    expect(loaded.map((entry) => entry.id), ['h1', 'h2']);
  });

  test('persiste post-it, ordem e vínculo com nota após reabrir', () async {
    final tempDir = await Directory.systemTemp.createTemp('planner_postits_');
    addTearDown(() => tempDir.delete(recursive: true));
    final file = File(p.join(tempDir.path, 'planner.sqlite'));

    var database = AppDatabase(NativeDatabase(file));
    final noteRepository = DriftNoteRepository(database);
    await noteRepository.save(buildNote(id: 'nota-1'));
    final postItRepository = DriftPostItRepository(database);
    await postItRepository.save(
      buildPostIt(
        id: 'p1',
        noteId: 'nota-1',
        noteExcerpt: 'Primeira',
        startDate: DateOnly(2026, 11, 2),
        sortOrder: 4,
      ),
    );
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final loaded = await DriftPostItRepository(database).findById('p1');

    expect(loaded, isNotNull);
    expect(loaded!.noteId, 'nota-1');
    expect(loaded.noteExcerpt, 'Primeira');
    expect(loaded.startDate, DateOnly(2026, 11, 2));
    expect(loaded.sortOrder, 4);
  });
}
