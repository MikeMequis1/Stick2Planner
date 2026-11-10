// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';

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
  bool _loading = true;
  String? _error;

  List<Routine> get routines => List.unmodifiable(_routines);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> initialize() => refresh();

  Future<void> refresh() async {
    try {
      _routines = await _repository.loadAll();
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
    required Set<int> weekdays,
    required List<RoutineItemInput> items,
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

    final routine = Routine(
      id: routineId,
      name: normalizedName,
      details: _normalizeDetails(details),
      weekdays: {...weekdays},
      items: [
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
      ],
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

  Future<void> toggleCompletion(RoutineItem item, DateOnly date) async {
    final completed = item.isCompletedOn(date);
    await _repository.setCompletion(
      routineItemId: item.id,
      date: date,
      completed: !completed,
      at: _clock.now().toUtc(),
    );
    await refresh();
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
