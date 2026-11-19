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
    final sections = await _loadAllSections();
    final reminders = await _loadAllReminders();

    final itemsByRoutine = <String, List<RoutineItemRow>>{};
    for (final row in itemRows) {
      itemsByRoutine.putIfAbsent(row.routineId, () => []).add(row);
    }
    final completions = <String, Set<DateOnly>>{};
    for (final row in completionRows) {
      completions.putIfAbsent(row.routineItemId, () => {}).add(row.date);
    }
    final sectionsByRoutine = <String, List<RoutineSection>>{};
    for (final section in sections) {
      sectionsByRoutine.putIfAbsent(section.routineId, () => []).add(section);
    }
    final remindersByRoutine = <String, List<RoutineReminder>>{};
    for (final reminder in reminders) {
      remindersByRoutine
          .putIfAbsent(reminder.routineId, () => [])
          .add(reminder);
    }

    return [
      for (final row in routineRows)
        routineFromRows(
          row,
          itemsByRoutine[row.id] ?? const [],
          completions,
          sections: sectionsByRoutine[row.id] ?? const [],
          reminders: remindersByRoutine[row.id] ?? const [],
        ),
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
              mode: Value(routine.mode),
              weekdays: Value(routineWeekdayMask(routine.weekdays)),
              createdAt: Value(dateTimeToStorage(routine.createdAt)),
              updatedAt: Value(dateTimeToStorage(routine.updatedAt)),
            ),
          );

      final itemIds = [for (final item in routine.items) item.id];
      if (itemIds.isEmpty) {
        await (_db.delete(
          _db.routineItems,
        )..where((table) => table.routineId.equals(routine.id))).go();
      } else {
        await (_db.delete(_db.routineItems)..where(
              (table) =>
                  table.routineId.equals(routine.id) &
                  table.id.isNotIn(itemIds),
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

      final sectionIds = [for (final section in routine.sections) section.id];
      if (sectionIds.isEmpty) {
        await (_db.delete(
          _db.routineSections,
        )..where((table) => table.routineId.equals(routine.id))).go();
      } else {
        await (_db.delete(_db.routineSections)..where(
              (table) =>
                  table.routineId.equals(routine.id) &
                  table.id.isNotIn(sectionIds),
            ))
            .go();
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
                createdAt: Value(
                  dateTimeToStorage(section.createdAt ?? routine.createdAt),
                ),
                updatedAt: Value(
                  dateTimeToStorage(section.updatedAt ?? routine.updatedAt),
                ),
              ),
            );

        final intervalIds = [
          for (final interval in section.intervals) interval.id,
        ];
        if (intervalIds.isEmpty) {
          await (_db.delete(
            _db.routineIntervals,
          )..where((table) => table.sectionId.equals(section.id))).go();
        } else {
          await (_db.delete(_db.routineIntervals)..where(
                (table) =>
                    table.sectionId.equals(section.id) &
                    table.id.isNotIn(intervalIds),
              ))
              .go();
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
                  createdAt: Value(
                    dateTimeToStorage(interval.createdAt ?? routine.createdAt),
                  ),
                  updatedAt: Value(
                    dateTimeToStorage(interval.updatedAt ?? routine.updatedAt),
                  ),
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
                    completedAt: Value(
                      dateTimeToStorage(
                        interval.updatedAt ?? routine.updatedAt,
                      ),
                    ),
                  ),
                );
          }
        }
      }

      final reminderIds = [
        for (final reminder in routine.reminders) reminder.id,
      ];
      if (reminderIds.isEmpty) {
        await (_db.delete(
          _db.routineReminders,
        )..where((table) => table.routineId.equals(routine.id))).go();
      } else {
        await (_db.delete(_db.routineReminders)..where(
              (table) =>
                  table.routineId.equals(routine.id) &
                  table.id.isNotIn(reminderIds),
            ))
            .go();
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
                createdAt: Value(
                  dateTimeToStorage(reminder.createdAt ?? routine.createdAt),
                ),
                updatedAt: Value(
                  dateTimeToStorage(reminder.updatedAt ?? routine.updatedAt),
                ),
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

  @override
  Future<void> setIntervalCompletion({
    required String intervalId,
    required DateOnly date,
    required bool completed,
    required DateTime at,
  }) {
    return _db.transaction(() async {
      if (completed) {
        await _db
            .into(_db.routineIntervalCompletions)
            .insertOnConflictUpdate(
              RoutineIntervalCompletionsCompanion(
                intervalId: Value(intervalId),
                date: Value(date),
                completedAt: Value(dateTimeToStorage(at)),
              ),
            );
      } else {
        await (_db.delete(_db.routineIntervalCompletions)..where(
              (table) =>
                  table.intervalId.equals(intervalId) &
                  table.date.equalsValue(date),
            ))
            .go();
      }
      final interval = await (_db.select(
        _db.routineIntervals,
      )..where((table) => table.id.equals(intervalId))).getSingleOrNull();
      if (interval == null) return;
      final section =
          await (_db.select(_db.routineSections)
                ..where((table) => table.id.equals(interval.sectionId)))
              .getSingleOrNull();
      if (section == null) return;
      await (_db.update(_db.routines)
            ..where((table) => table.id.equals(section.routineId)))
          .write(RoutinesCompanion(updatedAt: Value(dateTimeToStorage(at))));
      final routine = await _loadById(section.routineId);
      if (routine != null) await _outbox.recordRoutine(routine);
    });
  }

  Future<List<RoutineSection>> _loadAllSections() async {
    final sectionRows = await (_db.select(
      _db.routineSections,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    if (sectionRows.isEmpty) return const [];
    final intervalRows = await (_db.select(
      _db.routineIntervals,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final completionRows = await _db
        .select(_db.routineIntervalCompletions)
        .get();

    final intervalsBySection = <String, List<RoutineIntervalRow>>{};
    for (final row in intervalRows) {
      intervalsBySection.putIfAbsent(row.sectionId, () => []).add(row);
    }
    final completions = <String, Set<DateOnly>>{};
    for (final row in completionRows) {
      completions.putIfAbsent(row.intervalId, () => {}).add(row.date);
    }

    return [
      for (final row in sectionRows)
        RoutineSection(
          id: row.id,
          routineId: row.routineId,
          title: row.title,
          position: row.position,
          startMinutes: row.startMinutes,
          endMinutes: row.endMinutes,
          createdAt: dateTimeFromStorage(row.createdAt),
          updatedAt: dateTimeFromStorage(row.updatedAt),
          intervals: [
            for (final interval in intervalsBySection[row.id] ?? const [])
              RoutineInterval(
                id: interval.id,
                sectionId: interval.sectionId,
                startMinutes: interval.startMinutes,
                endMinutes: interval.endMinutes,
                position: interval.position,
                title: interval.taskTitle,
                details: interval.taskDetails,
                completedDates: completions[interval.id] ?? const {},
                createdAt: dateTimeFromStorage(interval.createdAt),
                updatedAt: dateTimeFromStorage(interval.updatedAt),
              ),
          ],
        ),
    ];
  }

  Future<List<RoutineReminder>> _loadAllReminders() async {
    final rows = await _db.select(_db.routineReminders).get();
    return [
      for (final row in rows)
        RoutineReminder(
          id: row.id,
          routineId: row.routineId,
          itemId: row.itemId,
          intervalId: row.intervalId,
          mode: row.mode,
          timesPerDay: row.timesPerDay,
          startMinutes: row.startMinutes,
          endMinutes: row.endMinutes,
          times: row.times,
          weekdays: {
            for (var day = 1; day <= 7; day++)
              if (row.weekdays & (1 << (day - 1)) != 0) day,
          },
          enabled: row.enabled,
          paused: row.paused,
          createdAt: dateTimeFromStorage(row.createdAt),
          updatedAt: dateTimeFromStorage(row.updatedAt),
        ),
    ];
  }

  @override
  Future<bool> recordExecution(RoutineExecution execution) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.routineExecutions)
                ..where((table) => table.dedupeKey.equals(execution.dedupeKey)))
              .getSingleOrNull();
      if (existing != null) return false;
      await _db
          .into(_db.routineExecutions)
          .insert(
            RoutineExecutionsCompanion.insert(
              id: execution.id,
              routineId: execution.routineId,
              itemId: Value(execution.itemId),
              intervalId: Value(execution.intervalId),
              reminderId: Value(execution.reminderId),
              date: execution.date,
              executedAt: dateTimeToStorage(execution.executedAt),
              origin: execution.origin,
              dedupeKey: execution.dedupeKey,
            ),
          );
      await _outbox.recordRoutineExecution(execution);
      return true;
    });
  }

  @override
  Future<List<RoutineExecution>> loadExecutions() async {
    final rows = await (_db.select(
      _db.routineExecutions,
    )..orderBy([(table) => OrderingTerm(expression: table.executedAt)])).get();
    return [
      for (final row in rows)
        RoutineExecution(
          id: row.id,
          routineId: row.routineId,
          itemId: row.itemId,
          intervalId: row.intervalId,
          reminderId: row.reminderId,
          date: row.date,
          executedAt: dateTimeFromStorage(row.executedAt),
          origin: row.origin,
          dedupeKey: row.dedupeKey,
        ),
    ];
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
    final sections = await _loadAllSections();
    return routineFromRows(
      row,
      items,
      byItem,
      sections: [
        for (final section in sections)
          if (section.routineId == id) section,
      ],
    );
  }
}
