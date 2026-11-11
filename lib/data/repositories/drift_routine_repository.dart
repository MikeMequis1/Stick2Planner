import 'package:drift/drift.dart';

import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../db/app_database.dart';
import '../db/converters.dart';
import '../mappers/mappers.dart';
import '../sync/sync_outbox.dart';

final class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(this._db, {SyncOutboxRecorder? outbox})
    : _outbox = outbox ?? SyncOutboxRecorder(_db);

  final AppDatabase _db;
  final SyncOutboxRecorder _outbox;

  @override
  Future<List<Routine>> loadAll() async {
    final routineRows = await (_db.select(
      _db.routines,
    )..orderBy([(table) => OrderingTerm(expression: table.name)])).get();
    if (routineRows.isEmpty) return const [];

    final itemRows = await (_db.select(
      _db.routineItems,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final completionRows = await _db.select(_db.routineCompletions).get();

    final itemsByRoutine = <String, List<RoutineItemRow>>{};
    for (final row in itemRows) {
      itemsByRoutine.putIfAbsent(row.routineId, () => []).add(row);
    }
    final completions = <String, Set<DateOnly>>{};
    for (final row in completionRows) {
      completions.putIfAbsent(row.routineItemId, () => {}).add(row.date);
    }

    return [
      for (final row in routineRows)
        routineFromRows(row, itemsByRoutine[row.id] ?? const [], completions),
    ];
  }

  @override
  Future<void> save(Routine routine) {
    return _db.transaction(() async {
      await _db
          .into(_db.routines)
          .insertOnConflictUpdate(
            RoutinesCompanion(
              id: Value(routine.id),
              name: Value(routine.name),
              details: Value(routine.details),
              weekdays: Value(routineWeekdayMask(routine.weekdays)),
              createdAt: Value(dateTimeToStorage(routine.createdAt)),
              updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
            ),
          );

      final keepIds = routine.items.map((item) => item.id).toList();
      if (keepIds.isEmpty) {
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routine.id))).go();
      } else {
        await (_db.delete(_db.routineItems)..where(
              (table) =>
                  table.routineId.equals(routine.id) &
                  table.id.isNotIn(keepIds),
            ))
            .go();
      }

      for (final item in routine.items) {
        await _db
            .into(_db.routineItems)
            .insertOnConflictUpdate(
              RoutineItemsCompanion(
                id: Value(item.id),
                routineId: Value(routine.id),
                title: Value(item.title),
                details: Value(item.details),
                position: Value(item.position),
                createdAt: Value(dateTimeToStorage(routine.createdAt)),
                updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
              ),
            );
      }
      await _outbox.recordRoutine(routine);
    });
  }

  @override
  Future<void> delete(String id) {
    return _db.transaction(() async {
      final routine = await _loadById(id);
      await (_db.delete(
        _db.routines,
      )..where((table) => table.id.equals(id))).go();
      if (routine != null) {
        await _outbox.recordRoutine(routine, deletedAt: DateTime.now().toUtc());
      }
    });
  }

  @override
  Future<void> setCompletion({
    required String routineItemId,
    required DateOnly date,
    required bool completed,
    required DateTime at,
  }) {
    return _db.transaction(() async {
      if (completed) {
        await _db
            .into(_db.routineCompletions)
            .insertOnConflictUpdate(
              RoutineCompletionsCompanion(
                routineItemId: Value(routineItemId),
                date: Value(date),
                completedAt: Value(dateTimeToStorage(at)),
              ),
            );
      } else {
        await (_db.delete(_db.routineCompletions)..where(
              (table) =>
                  table.routineItemId.equals(routineItemId) &
                  table.date.equalsValue(date),
            ))
            .go();
      }
      final item = await (_db.select(
        _db.routineItems,
      )..where((table) => table.id.equals(routineItemId))).getSingleOrNull();
      if (item == null) return;
      await (_db.update(_db.routines)
            ..where((table) => table.id.equals(item.routineId)))
          .write(RoutinesCompanion(updatedAt: Value(dateTimeToStorage(at))));
      final routine = await _loadById(item.routineId);
      if (routine != null) await _outbox.recordRoutine(routine);
    });
  }

  Future<Routine?> _loadById(String id) async {
    final row = await (_db.select(
      _db.routines,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final items =
        await (_db.select(_db.routineItems)
              ..where((table) => table.routineId.equals(id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    final itemIds = [for (final item in items) item.id];
    final completions = itemIds.isEmpty
        ? const <RoutineCompletionRow>[]
        : await (_db.select(
            _db.routineCompletions,
          )..where((table) => table.routineItemId.isIn(itemIds))).get();
    final byItem = <String, Set<DateOnly>>{};
    for (final completion in completions) {
      byItem
          .putIfAbsent(completion.routineItemId, () => <DateOnly>{})
          .add(completion.date);
    }
    return routineFromRows(row, items, byItem);
  }
}
