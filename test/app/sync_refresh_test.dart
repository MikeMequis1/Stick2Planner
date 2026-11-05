import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/data/sync/sync_models.dart';
import 'package:stick2planner/data/sync/sync_payload.dart';
import 'package:stick2planner/data/sync/sync_transport.dart';
import 'package:stick2planner/domain/entities/note.dart';
import 'package:stick2planner/domain/entities/post_it.dart';

import '../helpers/test_dependencies.dart';

final class _PullTransport implements SyncTransport {
  @override
  Future<SyncResponse> sync({
    required String deviceId,
    required int since,
    required List<SyncChange> changes,
    int limit = 200,
  }) async {
    final note = Note(
      id: 'remote-note',
      title: 'Nota remota',
      type: NoteType.checklist,
      lines: const [
        NoteLine(
          id: 'remote-line',
          noteId: 'remote-note',
          position: 0,
          text: 'Item',
        ),
      ],
      createdAt: DateTime.utc(2026, 11, 5, 12),
      updatedAt: DateTime.utc(2026, 11, 5, 12),
    );
    final postIt = PostIt(
      id: 'remote-post',
      title: 'Post remoto',
      type: PostItType.task,
      status: PostItStatus.active,
      noteId: 'remote-note',
      createdAt: DateTime.utc(2026, 11, 5, 12),
      updatedAt: DateTime.utc(2026, 11, 5, 12),
    );
    return SyncResponse(
      acks: const [],
      conflicts: const [],
      changes: [
        SyncRemoteChange(
          entity: syncEntityNote,
          entityId: note.id,
          rev: 1,
          deleted: false,
          updatedAt: note.updatedAt,
          payload: notePayload(note),
        ),
        SyncRemoteChange(
          entity: syncEntityPostIt,
          entityId: postIt.id,
          rev: 1,
          deleted: false,
          updatedAt: postIt.updatedAt,
          payload: postItPayload(postIt),
        ),
      ],
      cursor: 2,
      more: false,
    );
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
  test('pull remoto recarrega agenda e notas', () async {
    final tokens = InMemoryTokenStore();
    final dependencies = testDependencies(
      now: DateTime.utc(2026, 11, 5, 12),
      tokens: tokens,
      syncTransportFactory: (url, token) => _PullTransport(),
    );
    addTearDown(dependencies.dispose);
    await dependencies.initialize();

    await tokens.write('token');
    await dependencies.sync.setServerUrl('http://host:8090');

    final report = await dependencies.sync.syncNow();

    expect(report, isNotNull);
    expect(report!.pulled, 2);
    expect(
      dependencies.planner.postIts.map((postIt) => postIt.id),
      contains('remote-post'),
    );
    expect(
      dependencies.notes.notes.map((note) => note.id),
      contains('remote-note'),
    );
  });
}
