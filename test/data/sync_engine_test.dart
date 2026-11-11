import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_note_repository.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/repositories/drift_routine_repository.dart';
import 'package:stick2planner/data/sync/sync_engine.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_payload.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/routine.dart';

final class FakeTransport implements SyncTransport {
  FakeTransport(this.handler);

  final FutureOr<SyncResponse> Function(
    int call,
    List<SyncChange> changes,
    int since,
  )
  handler;

  int calls = 0;
  final List<List<SyncChange>> sent = [];
  final List<int> cursors = [];

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    calls++;
    sent.add(changes);
    cursors.add(since);
    return handler(calls, changes, since);
  }

  @override
  Future<ServerHealth> health() => throw UnimplementedError();

  @override
  Future<PairResult> pair({
    required String pairingToken,
    required String deviceId,
    required String deviceName,
  }) => throw UnimplementedError();

  @override
  Future<SyncCounts> stats() async => const SyncCounts();

  @override
  Future<RemoteSyncSnapshot> snapshot() async =>
      const RemoteSyncSnapshot(entities: [], cursor: 0);

  @override
  Future<SyncReplaceResult> replace({
    required String deviceId,
    required List<SyncSnapshotEntity> entities,
  }) async => const SyncReplaceResult(revs: {}, cursor: 0);
}

void main() {
  final t0 = DateTime.utc(2026, 11, 4, 12);

  AppDatabase openDb() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  PostIt localPostIt({
    String id = 'p1',
    String title = 'Local',
    DateTime? updatedAt,
  }) => PostIt(
    id: id,
    title: title,
    type: PostItType.task,
    status: PostItStatus.active,
    startDate: DateOnly(2026, 11, 4),
    createdAt: t0,
    updatedAt: updatedAt ?? t0,
  );

  SyncRemoteChange remotePostIt(PostIt postIt, {int rev = 1}) =>
      SyncRemoteChange(
        entity: syncEntityPostIt,
        entityId: postIt.id,
        rev: rev,
        deleted: postIt.isDeleted,
        updatedAt: postIt.updatedAt,
        payload: postItPayload(postIt),
      );

  SyncResponse response({
    List<SyncAck> acks = const [],
    List<SyncConflict> conflicts = const [],
    List<SyncRemoteChange> changes = const [],
    int cursor = 0,
  }) => SyncResponse(
    acks: acks,
    conflicts: conflicts,
    changes: changes,
    cursor: cursor,
    more: false,
  );

  Future<SyncOutboxRow> onlyOutbox(AppDatabase db) async =>
      (await db.select(db.syncOutbox).get()).single;

  SyncEngine engineFor(AppDatabase db, SyncTransport transport) => SyncEngine(
    database: db,
    transport: transport,
    state: SyncStateStore(db),
    now: () => t0,
  );

  test('push recebe ack, aplica pull e avança cursor', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt());
    final pushed = await onlyOutbox(db);
    final remote = localPostIt(id: 'p2', title: 'Remoto');

    final transport = FakeTransport(
      (call, changes, since) => response(
        acks: [
          SyncAck(
            changeId: pushed.changeId,
            entity: pushed.entity,
            entityId: pushed.entityId,
            rev: 1,
          ),
        ],
        changes: [remotePostIt(remote, rev: 1)],
        cursor: 7,
      ),
    );

    final report = await engineFor(db, transport).run();

    expect(report.pushed, 1);
    expect(report.pulled, 1);
    expect(report.cursor, 7);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
    expect(await SyncStateStore(db).cursor(), 7);

    final postIts = await DriftPostItRepository(db).loadAll();
    expect(postIts.map((postIt) => postIt.id).toSet(), {'p1', 'p2'});

    final state = await db.select(db.syncRowStates).get();
    expect(state.firstWhere((row) => row.entityId == 'p1').serverRev, 1);
  });

  test('falha de rede preserva outbox e cursor', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt());
    final transport = FakeTransport(
      (call, changes, since) =>
          throw const SyncException('offline', retryable: true),
    );

    await expectLater(
      engineFor(db, transport).run(),
      throwsA(isA<SyncException>()),
    );

    expect(await db.select(db.syncOutbox).get(), hasLength(1));
    final state = SyncStateStore(db);
    expect(await state.cursor(), 0);
    expect(await state.lastError(), isNotNull);
  });

  test('servidor vence: aplica versão e cria cópia de conflito', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt(title: 'Local'));
    final pushed = await onlyOutbox(db);
    final serverVersion = localPostIt(
      title: 'Servidor',
      updatedAt: t0.add(const Duration(hours: 1)),
    );

    final transport = FakeTransport(
      (call, changes, since) => response(
        conflicts: [
          SyncConflict(
            entity: syncEntityPostIt,
            entityId: 'p1',
            server: remotePostIt(serverVersion, rev: 5),
          ),
        ],
        cursor: 3,
      ),
    );

    final report = await engineFor(db, transport).run();

    expect(report.conflicts, 1);
    expect(report.copies, 1);

    final postIts = await DriftPostItRepository(db).loadAll();
    expect(postIts.firstWhere((postIt) => postIt.id == 'p1').title, 'Servidor');
    expect(postIts.any((postIt) => postIt.title == '[Conflito] Local'), isTrue);

    final outbox = await db.select(db.syncOutbox).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.changeId, isNot(pushed.changeId));
  });

  test('local vence: reenvia com baseRev do servidor', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt(title: 'Local'));
    final older = localPostIt(
      title: 'Servidor',
      updatedAt: t0.subtract(const Duration(hours: 1)),
    );
    final pushed = await onlyOutbox(db);

    final transport = FakeTransport((call, changes, since) {
      if (call == 1) {
        return response(
          conflicts: [
            SyncConflict(
              entity: syncEntityPostIt,
              entityId: 'p1',
              server: remotePostIt(older, rev: 2),
            ),
          ],
        );
      }
      return response(
        acks: [
          SyncAck(
            changeId: changes.single.changeId,
            entity: changes.single.entity,
            entityId: changes.single.entityId,
            rev: 3,
          ),
        ],
        cursor: 4,
      );
    });

    final report = await engineFor(db, transport).run();

    expect(transport.calls, 2);
    expect(transport.sent.last.single.baseRev, 2);
    expect(transport.sent.last.single.changeId, pushed.changeId);
    expect(report.pushed, 1);
    expect(report.cursor, 4);

    final postIts = await DriftPostItRepository(db).loadAll();
    expect(postIts.single.title, 'Local');
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });

  test('conteúdo igual não gera cópia', () async {
    final db = openDb();
    final local = localPostIt(title: 'Igual');
    await DriftPostItRepository(db).save(local);

    final transport = FakeTransport(
      (call, changes, since) => response(
        conflicts: [
          SyncConflict(
            entity: syncEntityPostIt,
            entityId: 'p1',
            server: remotePostIt(local, rev: 9),
          ),
        ],
        cursor: 2,
      ),
    );

    final report = await engineFor(db, transport).run();

    expect(report.copies, 0);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
    final postIts = await DriftPostItRepository(db).loadAll();
    expect(postIts, hasLength(1));
    expect(postIts.single.title, 'Igual');
  });

  test('tombstone do servidor preserva conteúdo local como cópia', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt(title: 'Conteúdo'));
    final deleted = localPostIt(
      title: 'Conteúdo',
      updatedAt: t0.add(const Duration(hours: 2)),
    ).copyWith(deletedAt: t0.add(const Duration(hours: 2)));

    final transport = FakeTransport(
      (call, changes, since) => response(
        conflicts: [
          SyncConflict(
            entity: syncEntityPostIt,
            entityId: 'p1',
            server: remotePostIt(deleted, rev: 4),
          ),
        ],
        cursor: 5,
      ),
    );

    final report = await engineFor(db, transport).run();

    expect(report.copies, 1);
    final postIts = await DriftPostItRepository(db)
        .loadAll(includeDeleted: true);
    expect(postIts.firstWhere((postIt) => postIt.id == 'p1').isDeleted, isTrue);
    expect(
      postIts.where((postIt) => postIt.title == '[Conflito] Conteúdo'),
      hasLength(1),
    );
  });

  test('falha ao aplicar pull desfaz ack e cursor', () async {
    final db = openDb();
    await DriftPostItRepository(db).save(localPostIt());
    final pushed = await onlyOutbox(db);

    final transport = FakeTransport(
      (call, changes, since) => response(
        acks: [
          SyncAck(
            changeId: pushed.changeId,
            entity: pushed.entity,
            entityId: pushed.entityId,
            rev: 1,
          ),
        ],
        changes: [
          SyncRemoteChange(
            entity: 'settings',
            entityId: 'x',
            rev: 1,
            deleted: false,
            updatedAt: t0,
            payload: const {},
          ),
        ],
        cursor: 11,
      ),
    );

    await expectLater(
      engineFor(db, transport).run(),
      throwsA(isA<SyncException>()),
    );

    expect(await db.select(db.syncOutbox).get(), hasLength(1));
    expect(await SyncStateStore(db).cursor(), 0);
    expect(await db.select(db.syncRowStates).get(), isEmpty);
  });

  test('conflito de nota copia linhas com novos IDs', () async {
    final db = openDb();
    final notes = DriftNoteRepository(db);
    final local = Note(
      id: 'n1',
      title: 'Lista',
      type: NoteType.checklist,
      lines: const [NoteLine(id: 'l1', noteId: 'n1', position: 0, text: 'Pão')],
      createdAt: t0,
      updatedAt: t0,
    );
    await notes.save(local);

    final serverNote = Note(
      id: 'n1',
      title: 'Servidor',
      type: NoteType.checklist,
      lines: const [NoteLine(id: 'l1', noteId: 'n1', position: 0, text: 'Pão')],
      createdAt: t0,
      updatedAt: t0.add(const Duration(hours: 1)),
    );
    final transport = FakeTransport(
      (call, changes, since) => response(
        conflicts: [
          SyncConflict(
            entity: syncEntityNote,
            entityId: 'n1',
            server: SyncRemoteChange(
              entity: syncEntityNote,
              entityId: 'n1',
              rev: 2,
              deleted: false,
              updatedAt: serverNote.updatedAt,
              payload: notePayload(serverNote),
            ),
          ),
        ],
        cursor: 6,
      ),
    );

    await engineFor(db, transport).run();

    final notesAfter = await notes.loadAll();
    expect(notesAfter.firstWhere((note) => note.id == 'n1').title, 'Servidor');
    final copy = notesAfter.firstWhere(
      (note) => note.title == '[Conflito] Lista',
    );
    expect(copy.lines, hasLength(1));
    expect(copy.lines.single.id, isNot('l1'));
    expect(copy.lines.single.noteId, copy.id);
  });

  test('servidor antigo mantém rotinas na outbox sem quebrar o sync', () async {
    final db = openDb();
    await DriftRoutineRepository(db).save(
      Routine(
        id: 'r1',
        name: 'Manhã',
        weekdays: const {3},
        createdAt: t0,
        updatedAt: t0,
      ),
    );
    final transport = FakeTransport(
      (call, changes, since) => response(cursor: 1),
    );
    final engine = SyncEngine(
      database: db,
      transport: transport,
      state: SyncStateStore(db),
      now: () => t0,
      supportsRoutines: false,
    );

    await engine.run();

    expect(transport.sent.single, isEmpty);
    expect((await db.select(db.syncOutbox).get()), hasLength(1));
    expect(
      (await db.select(db.syncOutbox).get()).single.entity,
      syncEntityRoutine,
    );
  });
}
