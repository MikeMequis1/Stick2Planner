import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_note_repository.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/sync/sync_apply.dart';
import 'package:stick2planner/data/sync/sync_payload.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 12);

  AppDatabase openDb() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  PostIt buildPostIt(String id, {String? title, DateTime? updatedAt}) => PostIt(
    id: id,
    title: title ?? 'Post-it $id',
    type: PostItType.task,
    status: PostItStatus.active,
    startDate: DateOnly(2026, 11, 4),
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );

  Note buildNote({DateTime? updatedAt}) => Note(
    id: 'n1',
    title: 'Lista',
    type: NoteType.checklist,
    createdAt: now,
    updatedAt: updatedAt ?? now,
    lines: const [
      NoteLine(id: 'l1', noteId: 'n1', position: 0, text: 'Pão'),
      NoteLine(
        id: 'l2',
        noteId: 'n1',
        position: 1,
        text: 'Café',
        isChecked: true,
      ),
    ],
  );

  Future<List<SyncOutboxRow>> outbox(AppDatabase db) =>
      db.select(db.syncOutbox).get();

  test('salvar post-it grava outbox na mesma transação', () async {
    final db = openDb();
    final repository = DriftPostItRepository(db);
    await repository.save(buildPostIt('p1'));

    final rows = await outbox(db);
    expect(rows, hasLength(1));
    expect(rows.single.entity, syncEntityPostIt);
    expect(rows.single.entityId, 'p1');
    expect(rows.single.baseRev, 0);

    final payload = decodeCanonical(rows.single.payload);
    expect(postItFromPayload(payload).title, 'Post-it p1');
  });

  test('edições coalescem e renovam o changeId', () async {
    final db = openDb();
    final repository = DriftPostItRepository(db);
    await repository.save(buildPostIt('p1', title: 'Primeiro'));
    final first = (await outbox(db)).single;

    await repository.save(
      buildPostIt(
        'p1',
        title: 'Segundo',
        updatedAt: now.add(const Duration(minutes: 1)),
      ),
    );
    final rows = await outbox(db);

    expect(rows, hasLength(1));
    expect(rows.single.changeId, isNot(first.changeId));
    expect(
      postItFromPayload(decodeCanonical(rows.single.payload)).title,
      'Segundo',
    );
  });

  test('saveBatch grava todos os post-its e históricos', () async {
    final db = openDb();
    final repository = DriftPostItRepository(db);
    await repository.saveBatch(
      [buildPostIt('p1'), buildPostIt('p2')],
      history: [
        PostItHistoryEntry(
          id: 'h1',
          postItId: 'p1',
          action: PostItHistoryAction.moved,
          createdAt: now,
        ),
      ],
    );

    final rows = await outbox(db);
    expect(rows.map((row) => row.entityId).toSet(), {'p1', 'p2', 'h1'});
    expect(
      rows.firstWhere((row) => row.entity == syncEntityHistory).entityId,
      'h1',
    );
  });

  test('exclusão grava tombstone no payload', () async {
    final db = openDb();
    final repository = DriftPostItRepository(db);
    await repository.save(buildPostIt('p1'));
    await repository.softDelete(
      id: 'p1',
      deletedAt: now.add(const Duration(hours: 1)),
    );

    final row = (await outbox(db)).single;
    final payload = postItFromPayload(decodeCanonical(row.payload));
    expect(payload.deletedAt, isNotNull);
    expect(payload.updatedAt, now.add(const Duration(hours: 1)));
  });

  test('nota leva linhas e checklists no mesmo payload', () async {
    final db = openDb();
    final repository = DriftNoteRepository(db);
    await repository.save(buildNote());

    final row = (await outbox(db)).single;
    expect(row.entity, syncEntityNote);
    final note = noteFromPayload(decodeCanonical(row.payload));
    expect(note.lines, hasLength(2));
    expect(note.lines.last.isChecked, isTrue);
  });

  test('excluir nota enfileira a nota e os post-its desvinculados', () async {
    final db = openDb();
    final notes = DriftNoteRepository(db);
    final postIts = DriftPostItRepository(db);
    await notes.save(buildNote());
    await postIts.save(
      buildPostIt('p1').copyWith(noteId: 'n1', noteExcerpt: 'trecho'),
    );

    await notes.softDelete(
      id: 'n1',
      deletedAt: now.add(const Duration(hours: 1)),
    );

    final rows = await outbox(db);
    final noteRow = rows.firstWhere((row) => row.entity == syncEntityNote);
    expect(
      noteFromPayload(decodeCanonical(noteRow.payload)).deletedAt,
      isNotNull,
    );
    final postItRow = rows.firstWhere((row) => row.entity == syncEntityPostIt);
    expect(
      postItFromPayload(decodeCanonical(postItRow.payload)).noteId,
      isNull,
    );
  });

  test('rollback não deixa outbox órfã', () async {
    final db = openDb();
    final repository = DriftPostItRepository(db);

    await expectLater(
      db.transaction(() async {
        await repository.save(buildPostIt('p1'));
        throw StateError('falha simulada');
      }),
      throwsStateError,
    );

    expect(await repository.loadAll(includeDeleted: true), isEmpty);
    expect(await outbox(db), isEmpty);
  });

  test('aplicação remota não gera outbox e registra a revisão', () async {
    final db = openDb();
    final apply = SyncApplyService(db);
    final payload = postItPayload(buildPostIt('p1'));

    await apply.applyPostIt(payload, 3);

    final loaded = await DriftPostItRepository(db).loadAll();
    expect(loaded.single.id, 'p1');
    expect(await outbox(db), isEmpty);

    final states = await db.select(db.syncRowStates).get();
    expect(states.single.serverRev, 3);
    expect(states.single.entityId, 'p1');
  });

  test('deviceId é estável e o cursor persiste', () async {
    final db = openDb();
    final store = SyncStateStore(db);
    final first = await store.ensureDeviceId();
    final second = await store.ensureDeviceId();
    expect(second, first);

    await store.setCursor(42);
    expect(await store.cursor(), 42);
  });
}

Map<String, Object?> decodeCanonical(String raw) =>
    Map<String, Object?>.from(jsonDecode(raw) as Map);
