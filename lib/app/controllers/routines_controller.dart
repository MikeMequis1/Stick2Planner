// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/usecases/routine_sections.dart';

final class RoutineItemInput {
  const RoutineItemInput({this.id, required this.title, this.details});

  final String? id;
  final String title;
  final String? details;
}

/// Estado e ações das rotinas semanais.
final class RoutinesController extends ChangeNotifier {
  RoutinesController({
    required RoutineRepository repository,
    required Clock clock,
    Uuid? uuid,
  }) : _repository = repository,
       _clock = clock,
       _uuid = uuid ?? const Uuid();

  final RoutineRepository _repository;
  final Clock _clock;
  final Uuid _uuid;

  List<Routine> _routines = const [];
  List<RoutineExecution> _executions = const [];
  bool _loading = true;
  String? _error;

  List<Routine> get routines => List.unmodifiable(_routines);
  List<RoutineExecution> get executions => List.unmodifiable(_executions);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> initialize() => refresh();

  Future<void> refresh() async {
    try {
      _routines = await _repository.loadAll();
      _executions = await _repository.loadExecutions();
      _error = null;
    } on Object {
      _error = 'load_failed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Routine> routinesOn(DateOnly date) => [
    for (final routine in _routines)
      if (routine.runsOn(date)) routine,
  ];

  Future<Routine> saveRoutine({
    String? id,
    required String name,
    String? details,
    RoutineMode mode = RoutineMode.simple,
    required Set<int> weekdays,
    required List<RoutineItemInput> items,
    List<RoutineSection> sections = const [],
    List<RoutineReminder>? reminders,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw const FormatException('routine_empty_name');
    }
    if (normalizedName.length > 80) {
      throw const FormatException('routine_name_too_long');
    }
    if (weekdays.isEmpty) {
      throw const FormatException('routine_no_weekdays');
    }

    final now = _clock.now().toUtc();
    final existing = id == null ? null : _routineById(id);
    final routineId = existing?.id ?? _uuid.v4();
    final previousItems = {
      for (final item in existing?.items ?? const <RoutineItem>[])
        item.id: item,
    };
    final previousIntervals = {
      for (final section in existing?.sections ?? const <RoutineSection>[])
        for (final interval in section.intervals) interval.id: interval,
    };
    final drafts = [
      for (var index = 0; index < items.length; index++)
        if (items[index].title.trim().isNotEmpty)
          (
            input: items[index],
            title: items[index].title.trim(),
            details: _normalizeDetails(items[index].details),
            position: index,
          ),
    ];

    final normalizedSections = mode == RoutineMode.complete
        ? [
            for (
              var sectionIndex = 0;
              sectionIndex < sections.length;
              sectionIndex++
            )
              sections[sectionIndex].copyWith(
                position: sectionIndex,
                createdAt: sections[sectionIndex].createdAt ?? now,
                intervals: [
                  for (
                    var intervalIndex = 0;
                    intervalIndex < sections[sectionIndex].intervals.length;
                    intervalIndex++
                  )
                    sections[sectionIndex].intervals[intervalIndex].copyWith(
                      position: intervalIndex,
                      createdAt:
                          previousIntervals[sections[sectionIndex]
                                  .intervals[intervalIndex]
                                  .id]
                              ?.createdAt ??
                          now,
                    ),
                ],
              ),
          ]
        : const <RoutineSection>[];

    if (mode == RoutineMode.complete) {
      final sectionErrors = validateRoutineSections(normalizedSections);
      if (sectionErrors.isNotEmpty) {
        throw RoutineSectionValidationException(sectionErrors);
      }
    }

    final itemIds = {
      for (final draft in drafts)
        if (draft.input.id != null) draft.input.id!,
    };
    final intervalIds = {
      for (final section in normalizedSections)
        for (final interval in section.intervals) interval.id,
    };
    final normalizedReminders = [
      for (final reminder in reminders ?? existing?.reminders ?? const [])
        if ((reminder.itemId == null && reminder.intervalId == null) ||
            (reminder.itemId != null && itemIds.contains(reminder.itemId)) ||
            (reminder.intervalId != null &&
                intervalIds.contains(reminder.intervalId)))
          RoutineReminder(
            id: reminder.id,
            routineId: routineId,
            itemId: reminder.itemId,
            intervalId: reminder.intervalId,
            mode: reminder.mode,
            timesPerDay: reminder.timesPerDay.clamp(1, 48),
            startMinutes: reminder.startMinutes.clamp(0, 24 * 60 - 1),
            endMinutes: reminder.endMinutes.clamp(
              reminder.startMinutes.clamp(0, 24 * 60 - 1) + 1,
              24 * 60,
            ),
            times: reminder.times.toSet().toList()..sort(),
            weekdays: reminder.weekdays.isEmpty
                ? weekdays
                : {...reminder.weekdays},
            enabled: reminder.enabled,
            paused: reminder.paused,
            createdAt: reminder.createdAt ?? now,
            updatedAt: now,
          ),
    ];

    final routine = Routine(
      id: routineId,
      name: normalizedName,
      mode: mode,
      details: _normalizeDetails(details),
      weekdays: {...weekdays},
      items: mode == RoutineMode.simple
          ? [
              for (final draft in drafts)
                RoutineItem(
                  id: draft.input.id ?? _uuid.v4(),
                  routineId: routineId,
                  title: draft.title,
                  details: draft.details,
                  position: draft.position,
                  completedDates:
                      previousItems[draft.input.id]?.completedDates ?? const {},
                ),
            ]
          : const [],
      sections: normalizedSections,
      reminders: normalizedReminders,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _repository.save(routine);
    await refresh();
    return routine;
  }

  Future<void> deleteRoutine(Routine routine) async {
    await _repository.delete(routine.id);
    await refresh();
  }

  /// Reordena atividades de uma rotina e persiste a nova ordem na hora.
  ///
  /// [newIndex] já vem ajustado pelo `onReorderItem` do [ReorderableListView].
  Future<void> reorderItems(Routine routine, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    final items = [...routine.items];
    if (oldIndex < 0 || oldIndex >= items.length) return;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex.clamp(0, items.length), moved);
    await _saveItems(routine, items);
  }

  /// Remove uma atividade e persiste a nova ordem imediatamente.
  Future<void> removeItem(Routine routine, RoutineItem item) async {
    final items = [
      for (final current in routine.items)
        if (current.id != item.id) current,
    ];
    if (items.length == routine.items.length) return;
    await _saveItems(routine, items);
  }

  Future<void> _saveItems(Routine routine, List<RoutineItem> items) async {
    final reordered = [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(position: index),
    ];
    await _repository.save(
      routine.copyWith(items: reordered, updatedAt: _clock.now().toUtc()),
    );
    await refresh();
  }

  Future<void> toggleCompletion(RoutineItem item, DateOnly date) async {
    final routine = _routineById(item.routineId);
    if (routine == null || !routine.runsOn(date)) return;
    final completed = item.isCompletedOn(date);
    final at = _clock.now().toUtc();
    await _repository.setCompletion(
      routineItemId: item.id,
      date: date,
      completed: !completed,
      at: at,
    );
    if (!completed) {
      await _recordExecution(
        routineId: routine.id,
        itemId: item.id,
        date: date,
        at: at,
        origin: RoutineExecutionOrigin.app,
        dedupeKey: 'item|${item.id}|${date.toIso8601String()}|manual',
      );
    }
    await refresh();
  }

  Future<void> toggleIntervalCompletion(
    RoutineInterval interval,
    DateOnly date,
  ) async {
    Routine? routine;
    for (final candidate in _routines) {
      if (candidate.sections.any(
        (section) => section.id == interval.sectionId,
      )) {
        routine = candidate;
        break;
      }
    }
    if (routine == null || !routine.runsOn(date)) return;
    final completed = interval.isCompletedOn(date);
    final at = _clock.now().toUtc();
    await _repository.setIntervalCompletion(
      intervalId: interval.id,
      date: date,
      completed: !completed,
      at: at,
    );
    if (!completed) {
      await _recordExecution(
        routineId: routine.id,
        intervalId: interval.id,
        date: date,
        at: at,
        origin: RoutineExecutionOrigin.app,
        dedupeKey: 'interval|${interval.id}|${date.toIso8601String()}|manual',
      );
    }
    await refresh();
  }

  /// Registra uma execução idempotente (interface, notificação ou legado).
  Future<bool> recordExecution({
    required String routineId,
    required DateOnly date,
    required RoutineExecutionOrigin origin,
    String? itemId,
    String? intervalId,
    String? reminderId,
    int? slotMinutes,
  }) async {
    final routine = _routineById(routineId);
    if (routine == null || !routine.runsOn(date)) return false;
    final at = _clock.now().toUtc();
    final target = intervalId != null
        ? 'interval|$intervalId'
        : itemId != null
        ? 'item|$itemId'
        : 'routine|$routineId';
    final suffix = reminderId == null
        ? 'manual'
        : 'reminder|$reminderId|${slotMinutes ?? 0}';
    final created = await _recordExecution(
      routineId: routineId,
      itemId: itemId,
      intervalId: intervalId,
      reminderId: reminderId,
      date: date,
      at: at,
      origin: origin,
      dedupeKey: '$target|${date.toIso8601String()}|$suffix',
    );
    if (intervalId != null) {
      await _repository.setIntervalCompletion(
        intervalId: intervalId,
        date: date,
        completed: true,
        at: at,
      );
    } else if (itemId != null) {
      await _repository.setCompletion(
        routineItemId: itemId,
        date: date,
        completed: true,
        at: at,
      );
    }
    if (created) await refresh();
    return created;
  }

  Future<bool> _recordExecution({
    required String routineId,
    required DateOnly date,
    required DateTime at,
    required RoutineExecutionOrigin origin,
    required String dedupeKey,
    String? itemId,
    String? intervalId,
    String? reminderId,
  }) {
    return _repository.recordExecution(
      RoutineExecution(
        id: _uuid.v4(),
        routineId: routineId,
        itemId: itemId,
        intervalId: intervalId,
        reminderId: reminderId,
        date: date,
        executedAt: at,
        origin: origin,
        dedupeKey: dedupeKey,
      ),
    );
  }

  Routine? _routineById(String id) {
    for (final routine in _routines) {
      if (routine.id == id) return routine;
    }
    return null;
  }

  static String? _normalizeDetails(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
