import 'dart:async';

import 'package:drift/native.dart';
import 'package:stick2planner/app/controllers/planner_controller.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/data/db/app_database.dart';
import 'package:stick2planner/data/repositories/drift_post_it_repository.dart';
import 'package:stick2planner/data/repositories/drift_settings_repository.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';
import 'package:stick2planner/domain/repositories/post_it_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  test('move evento atualiza o estado antes da persistência', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = _DelayedPostItRepository(
      DriftPostItRepository(database),
    );
    final controller = PlannerController(
      postItRepository: repository,
      settingsRepository: DriftSettingsRepository(database),
      clock: FixedClock(DateTime(2026, 11, 3, 9)),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    final event = buildPostIt(
      id: 'evento-otimista',
      title: 'Evento',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 3),
      endDate: DateOnly(2026, 11, 5),
    );
    await controller.savePostIt(event);

    repository.blockNextBatch();
    final move = controller.movePostIt(event, DateOnly(2026, 11, 7));
    await Future<void>.delayed(Duration.zero);

    final optimistic = controller.postIts.single;
    expect(optimistic.startDate, DateOnly(2026, 11, 7));
    expect(optimistic.endDate, DateOnly(2026, 11, 9));

    repository.release();
    await move;
    expect(controller.postIts.single.startDate, DateOnly(2026, 11, 7));
    expect(controller.postIts.single.endDate, DateOnly(2026, 11, 9));
  });
}

/// Adia o próximo `saveBatch` para provar que a UI otimista não espera o banco.
final class _DelayedPostItRepository implements PostItRepository {
  _DelayedPostItRepository(this._inner);

  final PostItRepository _inner;
  Completer<void>? _batchGate;

  void blockNextBatch() {
    _batchGate = Completer<void>();
  }

  void release() {
    _batchGate?.complete();
    _batchGate = null;
  }

  @override
  Future<List<PostIt>> loadAll({bool includeDeleted = false}) =>
      _inner.loadAll(includeDeleted: includeDeleted);

  @override
  Future<PostIt?> findById(String id) => _inner.findById(id);

  @override
  Future<void> save(PostIt postIt, {PostItHistoryEntry? history}) =>
      _inner.save(postIt, history: history);

  @override
  Future<void> saveBatch(
    List<PostIt> postIts, {
    List<PostItHistoryEntry> history = const [],
  }) async {
    final gate = _batchGate;
    if (gate != null) await gate.future;
    return _inner.saveBatch(postIts, history: history);
  }

  @override
  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
    PostItHistoryEntry? history,
  }) => _inner.softDelete(
    id: id,
    deletedAt: deletedAt,
    history: history,
  );

  @override
  Future<List<PostItHistoryEntry>> loadHistory(String postItId) =>
      _inner.loadHistory(postItId);
}
