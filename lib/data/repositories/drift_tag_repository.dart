import 'package:drift/drift.dart';

import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../db/app_database.dart';
import '../db/converters.dart';
import '../mappers/mappers.dart';
import '../sync/sync_outbox.dart';

final class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._db, {SyncOutboxRecorder? outbox})
    : _outbox = outbox ?? SyncOutboxRecorder(_db);

  final AppDatabase _db;
  final SyncOutboxRecorder _outbox;

  @override
  Future<List<Tag>> loadAll({bool includeDeleted = false}) async {
    final query = _db.select(_db.tags)
      ..orderBy([(table) => OrderingTerm(expression: table.name)]);
    if (!includeDeleted) {
      query.where((table) => table.deletedAt.isNull());
    }
    final rows = await query.get();
    return rows.map(tagFromRow).toList(growable: false);
  }

  @override
  Future<void> save(Tag tag) {
    return _db.transaction(() async {
      await _db.into(_db.tags).insertOnConflictUpdate(tagToCompanion(tag));
      await _outbox.recordTag(tag);
    });
  }

  @override
  Future<void> softDelete({required String id, required DateTime deletedAt}) {
    return _db.transaction(() async {
      final timestamp = dateTimeToStorage(deletedAt);
      await (_db.update(_db.tags)..where((table) => table.id.equals(id))).write(
        TagsCompanion(deletedAt: Value(timestamp), updatedAt: Value(timestamp)),
      );
      final row = await (_db.select(
        _db.tags,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row != null) await _outbox.recordTag(tagFromRow(row));
    });
  }
}
