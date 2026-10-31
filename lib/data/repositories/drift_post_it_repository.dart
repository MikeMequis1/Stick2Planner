import 'package:drift/drift.dart';

import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import '../../domain/repositories/post_it_repository.dart';
import '../db/app_database.dart';
import '../db/converters.dart';
import '../mappers/mappers.dart';

final class DriftPostItRepository implements PostItRepository {
  DriftPostItRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<PostIt>> loadAll({bool includeDeleted = false}) async {
    final query = _db.select(_db.postIts)
      ..orderBy([
        (table) => OrderingTerm(expression: table.sortOrder),
        (table) => OrderingTerm(expression: table.createdAt),
      ]);
    if (!includeDeleted) {
      query.where((table) => table.deletedAt.isNull());
    }

    final rows = await query.get();
    return rows.map(postItFromRow).toList(growable: false);
  }

  @override
  Future<PostIt?> findById(String id) async {
    final row = await (_db.select(
      _db.postIts,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : postItFromRow(row);
  }

  @override
  Future<void> save(PostIt postIt, {PostItHistoryEntry? history}) {
    return _db.transaction(() async {
      await _db.into(_db.postIts).insertOnConflictUpdate(
        postItToCompanion(postIt),
      );
      if (history != null) {
        await _db
            .into(_db.postItHistoryEntries)
            .insert(postItHistoryToCompanion(history));
      }
    });
  }

  @override
  Future<void> saveAll(List<PostIt> postIts) {
    return _db.transaction(() async {
      for (final postIt in postIts) {
        await _db
            .into(_db.postIts)
            .insertOnConflictUpdate(postItToCompanion(postIt));
      }
    });
  }

  @override
  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    final timestamp = dateTimeToStorage(deletedAt);
    await (_db.update(
      _db.postIts,
    )..where((table) => table.id.equals(id))).write(
      PostItsCompanion(
        deletedAt: Value(timestamp),
        updatedAt: Value(timestamp),
      ),
    );
  }

  @override
  Future<List<PostItHistoryEntry>> loadHistory(String postItId) async {
    final rows =
        await (_db.select(_db.postItHistoryEntries)
              ..where((table) => table.postItId.equals(postItId))
              ..orderBy([(table) => OrderingTerm(expression: table.createdAt)]))
            .get();
    return rows.map(postItHistoryFromRow).toList(growable: false);
  }
}
