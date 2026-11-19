import 'package:drift/drift.dart';

import '../../data/db/app_database.dart';
import '../../data/db/converters.dart';
import '../../data/mappers/mappers.dart';
import 'sync_payload.dart';

/// Aplica alterações vindas do servidor sem gerar novas entradas na outbox.
///
/// O cursor e a revisão por entidade são gravados na mesma transação da
/// aplicação; o chamador é responsável por envolver o lote inteiro.
final class SyncApplyService {
  SyncApplyService(this._db);

  final AppDatabase _db;

  Future<void> applyPostIt(Map<String, Object?> payload, int rev) async {
    final postIt = postItFromPayload(payload);
    await _db.transaction(() async {
      await _db
          .into(_db.postIts)
          .insertOnConflictUpdate(postItToCompanion(postIt));
      await _recordRev(syncEntityPostIt, postIt.id, rev);
    });
  }

  Future<void> applyNote(Map<String, Object?> payload, int rev) async {
    final note = noteFromPayload(payload);
    await _db.transaction(() async {
      await _db.into(_db.notes).insertOnConflictUpdate(noteToCompanion(note));

      final keep = {for (final line in note.lines) line.id};
      final existing = await (_db.select(
        _db.noteLines,
      )..where((table) => table.noteId.equals(note.id))).get();
      for (final row in existing) {
        if (keep.contains(row.id)) continue;
        await (_db.delete(
          _db.noteLines,
        )..where((table) => table.id.equals(row.id))).go();
      }
      for (final line in note.lines) {
        await _db
            .into(_db.noteLines)
            .insertOnConflictUpdate(noteLineToCompanion(line));
      }

      await _recordRev(syncEntityNote, note.id, rev);
    });
  }

  Future<void> applyHistory(Map<String, Object?> payload, int rev) async {
    final entry = historyFromPayload(payload);
    await _db.transaction(() async {
      final parent = await (_db.select(
        _db.postIts,
      )..where((table) => table.id.equals(entry.postItId))).getSingleOrNull();
      // Histórico órfão (post-it removido por substituição de conjunto ou
      // ausente nesta página) não pode violar a FK e bloquear o sync inteiro.
      if (parent != null) {
        await _db
            .into(_db.postItHistoryEntries)
            .insertOnConflictUpdate(postItHistoryToCompanion(entry));
      }
      await _recordRev(syncEntityHistory, entry.id, rev);
    });
  }

  Future<void> applyTag(Map<String, Object?> payload, int rev) async {
    final tag = tagFromPayload(payload);
    await _db.transaction(() async {
      await _db.into(_db.tags).insertOnConflictUpdate(tagToCompanion(tag));
      if (tag.isDeleted) {
        final rows = await _db.select(_db.postIts).get();
        for (final row in rows) {
          if (!row.tagIds.contains(tag.id)) continue;
          await (_db.update(
            _db.postIts,
          )..where((table) => table.id.equals(row.id))).write(
            PostItsCompanion(
              tagIds: Value([
                for (final id in row.tagIds)
                  if (id != tag.id) id,
              ]),
            ),
          );
        }
      }
      await _recordRev(syncEntityTag, tag.id, rev);
    });
  }

  Future<void> applyRoutine(Map<String, Object?> payload, int rev) async {
    final routineId = payload['id'];
    if (routineId is! String || routineId.isEmpty) {
      throw const FormatException('routine.id inválido');
    }
    if (payload['deletedAt'] != null) {
      await _db.transaction(() async {
        final items = await (_db.select(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routineId))).get();
        for (final item in items) {
          await (_db.delete(
            _db.routineCompletions,
          )..where((table) => table.routineItemId.equals(item.id))).go();
        }
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routineId))).go();
        final sections = await (_db.select(
          _db.routineSections,
        )..where((table) => table.routineId.equals(routineId))).get();
        for (final section in sections) {
          final intervals = await (_db.select(
            _db.routineIntervals,
          )..where((table) => table.sectionId.equals(section.id))).get();
          for (final interval in intervals) {
            await (_db.delete(
              _db.routineIntervalCompletions,
            )..where((table) => table.intervalId.equals(interval.id))).go();
          }
          await (_db.delete(
            _db.routineIntervals,
          )..where((table) => table.sectionId.equals(section.id))).go();
        }
        await (_db.delete(
          _db.routineSections,
        )..where((table) => table.routineId.equals(routineId))).go();
        await (_db.delete(
          _db.routineReminders,
        )..where((table) => table.routineId.equals(routineId))).go();
        await (_db.delete(
          _db.routines,
        )..where((table) => table.id.equals(routineId))).go();
        await _recordRev(syncEntityRoutine, routineId, rev);
      });
      return;
    }

    final routine = routineFromPayload(payload);
    await _db.transaction(() async {
      await _db
          .into(_db.routines)
          .insertOnConflictUpdate(
            RoutinesCompanion(
              id: Value(routine.id),
              name: Value(routine.name),
              details: Value(routine.details),
              mode: Value(routine.mode),
              weekdays: Value(routineWeekdayMask(routine.weekdays)),
              createdAt: Value(dateTimeToStorage(routine.createdAt)),
              updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
            ),
          );

      final existing = await (_db.select(
        _db.routineItems,
      )..where((table) => table.routineId.equals(routine.id))).get();
      final keepIds = {for (final item in routine.items) item.id};
      for (final row in existing) {
        if (keepIds.contains(row.id)) continue;
        await (_db.delete(
          _db.routineCompletions,
        )..where((table) => table.routineItemId.equals(row.id))).go();
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.id.equals(row.id))).go();
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
        await (_db.delete(
          _db.routineCompletions,
        )..where((table) => table.routineItemId.equals(item.id))).go();
        for (final date in item.completedDates) {
          await _db
              .into(_db.routineCompletions)
              .insertOnConflictUpdate(
                RoutineCompletionsCompanion(
                  routineItemId: Value(item.id),
                  date: Value(date),
                  completedAt: Value(dateTimeToStorage(routine.updatedAt)),
                ),
              );
        }
      }

      final keepSections = {for (final section in routine.sections) section.id};
      final existingSections = await (_db.select(
        _db.routineSections,
      )..where((table) => table.routineId.equals(routine.id))).get();
      for (final row in existingSections) {
        if (keepSections.contains(row.id)) continue;
        final intervals = await (_db.select(
          _db.routineIntervals,
        )..where((table) => table.sectionId.equals(row.id))).get();
        for (final interval in intervals) {
          await (_db.delete(
            _db.routineIntervalCompletions,
          )..where((table) => table.intervalId.equals(interval.id))).go();
        }
        await (_db.delete(
          _db.routineIntervals,
        )..where((table) => table.sectionId.equals(row.id))).go();
        await (_db.delete(
          _db.routineSections,
        )..where((table) => table.id.equals(row.id))).go();
      }

      for (
        var sectionIndex = 0;
        sectionIndex < routine.sections.length;
        sectionIndex++
      ) {
        final section = routine.sections[sectionIndex];
        await _db
            .into(_db.routineSections)
            .insertOnConflictUpdate(
              RoutineSectionsCompanion(
                id: Value(section.id),
                routineId: Value(routine.id),
                title: Value(section.title),
                position: Value(sectionIndex),
                startMinutes: Value(section.startMinutes),
                endMinutes: Value(section.endMinutes),
                createdAt: Value(dateTimeToStorage(routine.createdAt)),
                updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
              ),
            );
        final keepIntervals = {
          for (final interval in section.intervals) interval.id,
        };
        final existingIntervals = await (_db.select(
          _db.routineIntervals,
        )..where((table) => table.sectionId.equals(section.id))).get();
        for (final row in existingIntervals) {
          if (keepIntervals.contains(row.id)) continue;
          await (_db.delete(
            _db.routineIntervalCompletions,
          )..where((table) => table.intervalId.equals(row.id))).go();
          await (_db.delete(
            _db.routineIntervals,
          )..where((table) => table.id.equals(row.id))).go();
        }
        for (
          var intervalIndex = 0;
          intervalIndex < section.intervals.length;
          intervalIndex++
        ) {
          final interval = section.intervals[intervalIndex];
          await _db
              .into(_db.routineIntervals)
              .insertOnConflictUpdate(
                RoutineIntervalsCompanion(
                  id: Value(interval.id),
                  sectionId: Value(section.id),
                  startMinutes: Value(interval.startMinutes),
                  endMinutes: Value(interval.endMinutes),
                  position: Value(intervalIndex),
                  taskTitle: Value(interval.title),
                  taskDetails: Value(interval.details),
                  createdAt: Value(dateTimeToStorage(routine.createdAt)),
                  updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
                ),
              );
          await (_db.delete(
            _db.routineIntervalCompletions,
          )..where((table) => table.intervalId.equals(interval.id))).go();
          for (final date in interval.completedDates) {
            await _db
                .into(_db.routineIntervalCompletions)
                .insertOnConflictUpdate(
                  RoutineIntervalCompletionsCompanion(
                    intervalId: Value(interval.id),
                    date: Value(date),
                    completedAt: Value(dateTimeToStorage(routine.updatedAt)),
                  ),
                );
          }
        }
      }

      final keepReminders = {
        for (final reminder in routine.reminders) reminder.id,
      };
      final existingReminders = await (_db.select(
        _db.routineReminders,
      )..where((table) => table.routineId.equals(routine.id))).get();
      for (final row in existingReminders) {
        if (keepReminders.contains(row.id)) continue;
        await (_db.delete(
          _db.routineReminders,
        )..where((table) => table.id.equals(row.id))).go();
      }
      for (final reminder in routine.reminders) {
        await _db
            .into(_db.routineReminders)
            .insertOnConflictUpdate(
              RoutineRemindersCompanion(
                id: Value(reminder.id),
                routineId: Value(routine.id),
                itemId: Value(reminder.itemId),
                intervalId: Value(reminder.intervalId),
                mode: Value(reminder.mode),
                timesPerDay: Value(reminder.timesPerDay),
                startMinutes: Value(reminder.startMinutes),
                endMinutes: Value(reminder.endMinutes),
                times: Value(reminder.times),
                weekdays: Value(routineWeekdayMask(reminder.weekdays)),
                enabled: Value(reminder.enabled),
                paused: Value(reminder.paused),
                createdAt: Value(dateTimeToStorage(routine.createdAt)),
                updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
              ),
            );
      }
      await _recordRev(syncEntityRoutine, routine.id, rev);
    });
  }

  Future<void> applyRoutineExecution(
    Map<String, Object?> payload,
    int rev,
  ) async {
    final execution = routineExecutionFromPayload(payload);
    await _db.transaction(() async {
      final byDedupe =
          await (_db.select(_db.routineExecutions)
                ..where((table) => table.dedupeKey.equals(execution.dedupeKey)))
              .getSingleOrNull();
      if (byDedupe == null) {
        await _db
            .into(_db.routineExecutions)
            .insertOnConflictUpdate(
              RoutineExecutionsCompanion(
                id: Value(execution.id),
                routineId: Value(execution.routineId),
                itemId: Value(execution.itemId),
                intervalId: Value(execution.intervalId),
                reminderId: Value(execution.reminderId),
                date: Value(execution.date),
                executedAt: Value(dateTimeToStorage(execution.executedAt)),
                origin: Value(execution.origin),
                dedupeKey: Value(execution.dedupeKey),
              ),
            );
      }
      await _recordRev(syncEntityRoutineExecution, execution.id, rev);
    });
  }

  Future<void> _recordRev(String entity, String entityId, int rev) {
    return _db
        .into(_db.syncRowStates)
        .insertOnConflictUpdate(
          SyncRowStatesCompanion.insert(
            entity: entity,
            entityId: entityId,
            serverRev: rev,
            lastSyncedAt: dateTimeToStorage(DateTime.now().toUtc()),
          ),
        );
  }
}
