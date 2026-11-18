import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/repositories/drift_routine_repository.dart';
import 'package:stick2planner/data/repositories/drift_tag_repository.dart';
import 'package:stick2planner/data/sync/sync_engine.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_state_store.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/routine.dart';
import 'package:stick2planner/domain/usecases/routine_sections.dart';
import 'package:stick2planner/domain/entities/tag.dart';

/// Servidor mínimo em memória, com a mesma semântica de rev/conflito.
final class MemorySyncServer {
  final Map<String, int> _revs = {};
  final Map<String, Map<String, Object?>> _payloads = {};
  final Map<String, bool> _deleted = {};
  final Map<String, int> _updated = {};
  final Map<String, int> _applied = {};
  final List<({int seq, String key})> _log = [];
  int _seq = 0;

  String _key(String entity, String id) => '$entity/$id';

  SyncResponse handle({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    required int limit,
  }) {
    final acks = <SyncAck>[];
    final conflicts = <SyncConflict>[];

    for (final change in changes) {
      final key = _key(change.entity, change.entityId);
      final appliedRev = _applied[change.changeId];
      if (appliedRev != null) {
        acks.add(
          SyncAck(
            changeId: change.changeId,
            entity: change.entity,
            entityId: change.entityId,
            rev: appliedRev,
          ),
        );
        continue;
      }

      final currentRev = _revs[key] ?? 0;
      if (currentRev != 0 && change.baseRev != currentRev) {
        conflicts.add(
          SyncConflict(
            entity: change.entity,
            entityId: change.entityId,
            server: SyncRemoteChange(
              entity: change.entity,
              entityId: change.entityId,
              rev: currentRev,
              deleted: _deleted[key] ?? false,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                _updated[key] ?? 0,
                isUtc: true,
              ),
              payload: _payloads[key]!,
            ),
          ),
        );
        continue;
      }

      final nextRev = currentRev + 1;
      _revs[key] = nextRev;
      _payloads[key] = change.payload;
      _deleted[key] = change.deleted;
      _updated[key] = change.updatedAt.millisecondsSinceEpoch;
      _applied[change.changeId] = nextRev;
      _seq++;
      _log.add((seq: _seq, key: key));
      acks.add(
        SyncAck(
          changeId: change.changeId,
          entity: change.entity,
          entityId: change.entityId,
          rev: nextRev,
        ),
      );
    }

    final pending = _log
        .where((entry) => entry.seq > since)
        .take(limit)
        .toList();
    final changesOut = <SyncRemoteChange>[];
    for (final entry in pending) {
      final separator = entry.key.indexOf('/');
      final entity = entry.key.substring(0, separator);
      final id = entry.key.substring(separator + 1);
      changesOut.add(
        SyncRemoteChange(
          entity: entity,
          entityId: id,
          rev: _revs[entry.key]!,
          deleted: _deleted[entry.key] ?? false,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            _updated[entry.key] ?? 0,
            isUtc: true,
          ),
          payload: _payloads[entry.key]!,
        ),
      );
    }
    final cursor = pending.isEmpty ? since : pending.last.seq;

    return SyncResponse(
      acks: acks,
      conflicts: conflicts,
      changes: changesOut,
      cursor: cursor,
      more: _log.where((entry) => entry.seq > cursor).isNotEmpty,
    );
  }
}

final class DeviceTransport implements SyncTransport {
  DeviceTransport(this.server, this.deviceId);

  final MemorySyncServer server;
  final String deviceId;

  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async => server.handle(
    deviceId: deviceId,
    since: since,
    changes: changes,
    limit: limit,
  );

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

  PostIt basePostIt({String title = 'A'}) => PostIt(
    id: 'p1',
    title: title,
    type: PostItType.task,
    status: PostItStatus.active,
    startDate: DateOnly(2026, 11, 4),
    createdAt: t0,
    updatedAt: t0,
  );

  test('dois dispositivos convergem e conflito gera cópia', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );

    await repoA.save(basePostIt(title: 'Original'));
    await engineA.run();

    await engineB.run();
    expect((await repoB.loadAll()).single.title, 'Original');

    // B edita e envia primeiro.
    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(title: 'B', updatedAt: t0.add(const Duration(minutes: 2))),
    );
    await engineB.run();

    // A edita com timestamp mais antigo: perde e vira cópia.
    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(title: 'A2', updatedAt: t0.add(const Duration(minutes: 1))),
    );
    final reportA = await engineA.run();

    expect(reportA.conflicts, 1);
    expect(reportA.copies, 1);
    final finalA = await repoA.loadAll();
    expect(finalA.firstWhere((postIt) => postIt.id == 'p1').title, 'B');
    expect(finalA.any((postIt) => postIt.title == '[Conflito] A2'), isTrue);

    // A envia a cópia no próximo sync; B recebe no pull seguinte.
    await engineA.run();
    await engineB.run();
    expect(
      (await repoB.loadAll()).any((postIt) => postIt.title == '[Conflito] A2'),
      isTrue,
    );
  });

  test('edição local mais nova vence e chega ao outro dispositivo', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );

    await repoA.save(basePostIt(title: 'Original'));
    await engineA.run();
    await engineB.run();

    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(title: 'B', updatedAt: t0.add(const Duration(minutes: 1))),
    );
    await engineB.run();

    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(
        title: 'A-novo',
        updatedAt: t0.add(const Duration(minutes: 5)),
      ),
    );
    await engineA.run();

    await engineB.run();
    expect((await repoB.loadAll()).single.title, 'A-novo');
  });

  test('tag e associação chegam ao outro dispositivo', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final tagsA = DriftTagRepository(dbA);
    final tagsB = DriftTagRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );

    final tag = Tag(
      id: 'tag1',
      name: 'Trabalho',
      tone: TagTone.primary,
      createdAt: t0,
      updatedAt: t0,
    );
    await tagsA.save(tag);
    await repoA.save(basePostIt().copyWith(tagIds: [tag.id]));

    await engineA.run();
    expect(await tagsB.loadAll(), isEmpty);

    await engineB.run();
    final onB = (await tagsB.loadAll()).single;
    expect(onB.name, 'Trabalho');
    expect(onB.tone, TagTone.primary);
    expect((await repoB.loadAll()).single.tagIds, [tag.id]);

    await tagsA.save(
      tag.copyWith(
        name: 'Trabalho novo',
        tone: TagTone.secondarySoft,
        updatedAt: t0.add(const Duration(minutes: 1)),
      ),
    );
    await engineA.run();
    await engineB.run();
    expect((await tagsB.loadAll()).single.name, 'Trabalho novo');
    expect((await tagsB.loadAll()).single.tone, TagTone.secondarySoft);

    await tagsA.softDelete(
      id: tag.id,
      deletedAt: t0.add(const Duration(minutes: 2)),
    );
    await engineA.run();
    await engineB.run();
    expect(await tagsB.loadAll(), isEmpty);
    expect((await repoB.loadAll()).single.tagIds, isEmpty);
  });

  test(
    'rotinas, atividades e conclusões convergem preservando createdAt',
    () async {
      final server = MemorySyncServer();
      final dbA = openDb();
      final dbB = openDb();
      final repoA = DriftRoutineRepository(dbA);
      final repoB = DriftRoutineRepository(dbB);
      final engineA = SyncEngine(
        database: dbA,
        transport: DeviceTransport(server, 'A'),
        state: SyncStateStore(dbA),
        now: () => t0,
      );
      final engineB = SyncEngine(
        database: dbB,
        transport: DeviceTransport(server, 'B'),
        state: SyncStateStore(dbB),
        now: () => t0,
      );

      final routine = Routine(
        id: 'r1',
        name: 'Manhã',
        details: 'Antes do trabalho',
        weekdays: const {3, 4},
        items: const [
          RoutineItem(
            id: 'ri1',
            routineId: 'r1',
            title: 'Alongar',
            position: 0,
          ),
          RoutineItem(id: 'ri2', routineId: 'r1', title: 'Ler', position: 1),
        ],
        createdAt: t0,
        updatedAt: t0,
      );
      await repoA.save(routine);
      await engineA.run();
      await engineB.run();

      final onB = (await repoB.loadAll()).single;
      expect(onB.createdAt, t0);
      expect(onB.items.map((item) => item.title), ['Alongar', 'Ler']);

      await repoB.setCompletion(
        routineItemId: 'ri1',
        date: DateOnly(2026, 11, 4),
        completed: true,
        at: t0.add(const Duration(minutes: 1)),
      );
      await engineB.run();
      await engineA.run();

      final onA = (await repoA.loadAll()).single;
      expect(onA.createdAt, t0);
      expect(onA.items.first.isCompletedOn(DateOnly(2026, 11, 4)), isTrue);

      await repoA.delete(routine.id);
      await engineA.run();
      await engineB.run();
      expect(await repoB.loadAll(), isEmpty);
    },
  );

  test('estado de ocorrência recorrente viaja no payload do evento', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftPostItRepository(dbA);
    final repoB = DriftPostItRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );
    final event = PostIt(
      id: 'ev1',
      title: 'Série',
      type: PostItType.event,
      status: PostItStatus.active,
      startDate: DateOnly(2026, 11, 4),
      recurrence: EventRecurrence.daily,
      recurrenceEndDate: DateOnly(2026, 11, 6),
      occurrenceStatuses: {DateOnly(2026, 11, 5): PostItStatus.done},
      createdAt: t0,
      updatedAt: t0,
    );

    await repoA.save(event);
    await engineA.run();
    await engineB.run();

    final onB = (await repoB.loadAll()).single;
    expect(onB.recurrenceEndDate, DateOnly(2026, 11, 6));
    expect(onB.occurrenceStatuses[DateOnly(2026, 11, 5)], PostItStatus.done);
  });

  test('rotina completa sincroniza cards, intervalos e tarefas', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftRoutineRepository(dbA);
    final repoB = DriftRoutineRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );
    final routine = Routine(
      id: 'r2',
      name: 'Rotina completa',
      mode: RoutineMode.complete,
      weekdays: const {3},
      sections: [
        RoutineSection(
          id: 's1',
          routineId: 'r2',
          title: 'Manhã',
          position: 0,
          startMinutes: 480,
          endMinutes: 720,
          intervals: [
            RoutineInterval(
              id: 'i1',
              sectionId: 's1',
              startMinutes: 480,
              endMinutes: 600,
              position: 0,
              title: 'Estudar',
            ),
            RoutineInterval(
              id: 'i2',
              sectionId: 's1',
              startMinutes: 600,
              endMinutes: 720,
              position: 1,
              title: 'Trabalhar',
              completedDates: {DateOnly(2026, 11, 4)},
            ),
          ],
        ),
      ],
      createdAt: t0,
      updatedAt: t0,
    );

    await repoA.save(routine);
    await engineA.run();
    await engineB.run();

    final onB = (await repoB.loadAll()).single;
    expect(onB.mode, RoutineMode.complete);
    expect(onB.sections.single.title, 'Manhã');
    expect(onB.sections.single.intervals.map((item) => item.title), [
      'Estudar',
      'Trabalhar',
    ]);
    expect(onB.sections.single.intervals.last.completedDates, {
      DateOnly(2026, 11, 4),
    });
  });

  test('card novo, horário dividido e card removido sincronizam', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftRoutineRepository(dbA);
    final repoB = DriftRoutineRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );
    final section = RoutineSection(
      id: 's1',
      routineId: 'r3',
      title: 'Manhã',
      position: 0,
      startMinutes: 480,
      endMinutes: 720,
      intervals: [
        RoutineInterval(
          id: 'i1',
          sectionId: 's1',
          startMinutes: 480,
          endMinutes: 600,
          position: 0,
          title: 'Estudar',
        ),
        RoutineInterval(
          id: 'i2',
          sectionId: 's1',
          startMinutes: 600,
          endMinutes: 720,
          position: 1,
          title: 'Trabalhar',
          completedDates: {DateOnly(2026, 11, 4)},
        ),
      ],
    );
    final routine = Routine(
      id: 'r3',
      name: 'Rotina completa',
      mode: RoutineMode.complete,
      weekdays: const {3},
      sections: [section],
      createdAt: t0,
      updatedAt: t0,
    );
    await repoA.save(routine);
    await engineA.run();
    await engineB.run();

    // B divide o primeiro intervalo e cria outro card.
    final onB = (await repoB.loadAll()).single;
    final split = addSectionTime(
      onB.sections.single,
      minutes: 540,
      idGenerator: () => 'i3',
    );
    final afternoon = RoutineSection(
      id: 's2',
      routineId: 'r3',
      title: 'Tarde',
      position: 1,
      startMinutes: 780,
      endMinutes: 900,
      intervals: const [
        RoutineInterval(
          id: 'i4',
          sectionId: 's2',
          startMinutes: 780,
          endMinutes: 900,
          position: 0,
          title: 'Almoçar',
        ),
      ],
    );
    await repoB.save(
      onB.copyWith(
        sections: [split, afternoon],
        updatedAt: t0.add(const Duration(minutes: 1)),
      ),
    );
    await engineB.run();
    await engineA.run();

    var onA = (await repoA.loadAll()).single;
    expect(onA.sections.map((item) => item.id), ['s1', 's2']);
    expect(onA.sections.first.intervals.map((item) => item.id), [
      'i1',
      'i3',
      'i2',
    ]);
    expect(onA.sections.first.intervals[1].title, isNull);
    expect(onA.sections.last.intervals.single.title, 'Almoçar');

    // A remove o horário intermediário (une i1/i3) e exclui o card da tarde.
    final merged = removeSectionTime(onA.sections.first, minutes: 540);
    await repoA.save(
      onA.copyWith(
        sections: [merged],
        updatedAt: t0.add(const Duration(minutes: 2)),
      ),
    );
    await engineA.run();
    await engineB.run();

    final finalB = (await repoB.loadAll()).single;
    expect(finalB.sections.map((item) => item.id), ['s1']);
    expect(finalB.sections.single.intervals.map((item) => item.id), [
      'i1',
      'i2',
    ]);
    expect(finalB.sections.single.intervals.first.title, 'Estudar');
    expect(finalB.sections.single.intervals.first.endMinutes, 600);
    expect(finalB.sections.single.intervals.last.completedDates, {
      DateOnly(2026, 11, 4),
    });

    await repoA.delete('r3');
    await engineA.run();
    await engineB.run();
    expect(await repoB.loadAll(), isEmpty);
    expect(await dbB.select(dbB.routineSections).get(), isEmpty);
    expect(await dbB.select(dbB.routineIntervals).get(), isEmpty);
    expect(await dbB.select(dbB.routineIntervalCompletions).get(), isEmpty);
  });

  test('mescla conflito de rotina quando dispositivos alteram elementos diferentes', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftRoutineRepository(dbA);
    final repoB = DriftRoutineRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );
    final routine = Routine(
      id: 'r5',
      name: 'Rotina',
      mode: RoutineMode.complete,
      weekdays: const {3},
      sections: const [
        RoutineSection(
          id: 's1',
          routineId: 'r5',
          title: 'Manhã',
          position: 0,
          startMinutes: 480,
          endMinutes: 600,
          intervals: [
            RoutineInterval(
              id: 'i1',
              sectionId: 's1',
              startMinutes: 480,
              endMinutes: 600,
              position: 0,
              title: 'Estudar',
            ),
          ],
        ),
        RoutineSection(
          id: 's2',
          routineId: 'r5',
          title: 'Tarde',
          position: 1,
          startMinutes: 780,
          endMinutes: 900,
          intervals: [
            RoutineInterval(
              id: 'i2',
              sectionId: 's2',
              startMinutes: 780,
              endMinutes: 900,
              position: 0,
              title: 'Trabalhar',
            ),
          ],
        ),
      ],
      createdAt: t0,
      updatedAt: t0,
    );
    await repoA.save(routine);
    await engineA.run();
    await engineB.run();

    // B edita o card da manhã e conclui a tarefa.
    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(
        sections: [
          onB.sections.first.copyWith(
            intervals: [
              onB.sections.first.intervals.single.copyWith(
                title: 'Manhã B',
                completedDates: {DateOnly(2026, 11, 4)},
              ),
            ],
          ),
          onB.sections.last,
        ],
        updatedAt: t0.add(const Duration(minutes: 2)),
      ),
    );
    await engineB.run();

    // A edita outro card e adiciona um card novo.
    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(
        sections: [
          onA.sections.first,
          onA.sections.last.copyWith(
            intervals: [
              onA.sections.last.intervals.single.copyWith(title: 'Tarde A'),
            ],
          ),
          const RoutineSection(
            id: 's3',
            routineId: 'r5',
            title: 'Noite',
            position: 2,
            startMinutes: 1140,
            endMinutes: 1260,
            intervals: [
              RoutineInterval(
                id: 'i3',
                sectionId: 's3',
                startMinutes: 1140,
                endMinutes: 1260,
                position: 0,
                title: 'Ler',
              ),
            ],
          ),
        ],
        updatedAt: t0.add(const Duration(minutes: 1)),
      ),
    );
    final report = await engineA.run();
    expect(report.conflicts, 1);
    expect(report.copies, 0);

    Future<void> expectMerged(DriftRoutineRepository repo) async {
      final merged = (await repo.loadAll()).single;
      expect(merged.sections.map((section) => section.id), ['s1', 's2', 's3']);
      expect(merged.sections[0].intervals.single.title, 'Manhã B');
      expect(merged.sections[0].intervals.single.completedDates, {
        DateOnly(2026, 11, 4),
      });
      expect(merged.sections[1].intervals.single.title, 'Tarde A');
      expect(merged.sections[2].intervals.single.title, 'Ler');
    }

    await expectMerged(repoA);
    await engineB.run();
    await expectMerged(repoB);
    expect(await dbA.select(dbA.syncOutbox).get(), isEmpty);
  });

  test('conflito no mesmo elemento mantém original e cópia', () async {
    final server = MemorySyncServer();
    final dbA = openDb();
    final dbB = openDb();
    final repoA = DriftRoutineRepository(dbA);
    final repoB = DriftRoutineRepository(dbB);
    final engineA = SyncEngine(
      database: dbA,
      transport: DeviceTransport(server, 'A'),
      state: SyncStateStore(dbA),
      now: () => t0,
    );
    final engineB = SyncEngine(
      database: dbB,
      transport: DeviceTransport(server, 'B'),
      state: SyncStateStore(dbB),
      now: () => t0,
    );
    final routine = Routine(
      id: 'r4',
      name: 'Rotina',
      mode: RoutineMode.complete,
      weekdays: const {3},
      sections: const [
        RoutineSection(
          id: 's1',
          routineId: 'r4',
          title: 'Manhã',
          position: 0,
          startMinutes: 480,
          endMinutes: 600,
          intervals: [
            RoutineInterval(
              id: 'i1',
              sectionId: 's1',
              startMinutes: 480,
              endMinutes: 600,
              position: 0,
              title: 'Estudar',
            ),
          ],
        ),
      ],
      createdAt: t0,
      updatedAt: t0,
    );
    await repoA.save(routine);
    await engineA.run();
    await engineB.run();

    // B altera a tarefa e envia primeiro.
    final onB = (await repoB.loadAll()).single;
    await repoB.save(
      onB.copyWith(
        sections: [
          onB.sections.single.copyWith(
            intervals: [
              onB.sections.single.intervals.single.copyWith(
                title: 'Trabalhar B',
              ),
            ],
          ),
        ],
        updatedAt: t0.add(const Duration(minutes: 2)),
      ),
    );
    await engineB.run();

    // A altera o mesmo card com timestamp mais antigo: vira cópia.
    final onA = (await repoA.loadAll()).single;
    await repoA.save(
      onA.copyWith(
        sections: [
          onA.sections.single.copyWith(
            intervals: [
              onA.sections.single.intervals.single.copyWith(title: 'Estudar A'),
            ],
          ),
        ],
        updatedAt: t0.add(const Duration(minutes: 1)),
      ),
    );
    final report = await engineA.run();
    expect(report.conflicts, 1);
    expect(report.copies, 1);

    final routinesA = await repoA.loadAll();
    expect(routinesA, hasLength(2));
    final originalA = routinesA.singleWhere((item) => item.id == 'r4');
    final copyA = routinesA.singleWhere((item) => item.id != 'r4');
    expect(originalA.name, 'Rotina');
    expect(originalA.sections.single.id, 's1');
    expect(originalA.sections.single.intervals.single.id, 'i1');
    expect(originalA.sections.single.intervals.single.title, 'Trabalhar B');
    expect(copyA.name, '[Conflito] Rotina');
    expect(copyA.sections.single.id, isNot('s1'));
    expect(copyA.sections.single.intervals.single.id, isNot('i1'));
    expect(copyA.sections.single.intervals.single.title, 'Estudar A');

    // A cópia chega a B sem sobrescrever os cards da rotina original.
    await engineA.run();
    await engineB.run();
    final routinesB = await repoB.loadAll();
    expect(routinesB, hasLength(2));
    final originalB = routinesB.singleWhere((item) => item.id == 'r4');
    expect(originalB.sections.single.id, 's1');
    expect(originalB.sections.single.intervals.single.title, 'Trabalhar B');
    expect(
      routinesB.any(
        (item) =>
            item.name == '[Conflito] Rotina' && item.sections.single.id != 's1',
      ),
      isTrue,
    );
  });
}
