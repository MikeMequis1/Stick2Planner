import 'package:flutter/widgets.dart';

// Parâmetros nomeados não podem usar campos privados como initializing formals.
// ignore_for_file: prefer_initializing_formals

import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../core/date_only.dart';
import '../../domain/calendar/calendar_period.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import '../../domain/repositories/post_it_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/ensure_recurring_rollover.dart';
import '../../domain/usecases/validate_post_it.dart';
import '../planner_view_mode.dart';
import '../settings_keys.dart';

/// Estado e ações da agenda e das preferências de visualização.
final class PlannerController extends ChangeNotifier {
  PlannerController({
    required PostItRepository postItRepository,
    required SettingsRepository settingsRepository,
    required Clock clock,
    ValidatePostIt validatePostIt = const ValidatePostIt(),
  }) : _postItRepository = postItRepository,
       _settingsRepository = settingsRepository,
       _clock = clock,
       _validatePostIt = validatePostIt,
       _selectedDate = DateOnly.fromDateTime(clock.now());

  final PostItRepository _postItRepository;
  final SettingsRepository _settingsRepository;
  final Clock _clock;
  final ValidatePostIt _validatePostIt;

  DateOnly _selectedDate;
  AgendaViewMode _portraitMode = AgendaViewMode.day;
  AgendaViewMode _landscapeMode = AgendaViewMode.week;
  List<PostIt> _postIts = const [];
  bool _isLoading = true;
  bool _initialized = false;
  String? _error;

  /// Serializa mutações para evitar conflitos em arrastes/edições rápidos.
  Future<void> _mutationQueue = Future<void>.value();

  DateOnly get selectedDate => _selectedDate;
  DateOnly get today => DateOnly.fromDateTime(_clock.now());
  AgendaViewMode get portraitMode => _portraitMode;
  AgendaViewMode get landscapeMode => _landscapeMode;
  List<PostIt> get postIts => List.unmodifiable(_postIts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AgendaViewMode modeFor(Orientation orientation) =>
      orientation == Orientation.landscape ? _landscapeMode : _portraitMode;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final settings = await _settingsRepository.loadAll();
      _selectedDate =
          _parseDate(settings[SettingsKeys.selectedDate]) ?? today;
      _portraitMode = _parseMode(
        settings[SettingsKeys.portraitMode],
        AgendaViewMode.day,
      );
      _landscapeMode = _parseMode(
        settings[SettingsKeys.landscapeMode],
        AgendaViewMode.week,
      );
      _postIts = await _postItRepository.loadAll();
      await _applyRecurringRollover();
      _error = null;
    } on Object {
      _error = 'load_failed';
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _postIts = await _postItRepository.loadAll();
      _error = null;
    } on Object {
      _error = 'load_failed';
    }
    notifyListeners();
  }

  Future<void> selectDate(DateOnly date) async {
    if (date == _selectedDate) return;
    _selectedDate = date;
    notifyListeners();
    await _settingsRepository.write(
      SettingsKeys.selectedDate,
      date.toIso8601String(),
    );
  }

  Future<void> goToToday() => selectDate(today);

  /// Avança um período relativo ao modo visível, mantendo a data como âncora.
  Future<void> nextPeriod(AgendaViewMode mode) =>
      selectDate(shiftSelectedDate(_selectedDate, mode, 1));

  Future<void> previousPeriod(AgendaViewMode mode) =>
      selectDate(shiftSelectedDate(_selectedDate, mode, -1));

  bool canDecreaseMode(Orientation orientation) {
    final modes = plannerModesFor(orientation);
    return modes.indexOf(modeFor(orientation)) > 0;
  }

  bool canIncreaseMode(Orientation orientation) {
    final modes = plannerModesFor(orientation);
    return modes.indexOf(modeFor(orientation)) < modes.length - 1;
  }

  /// Ajusta a quantidade de dias visíveis dentro dos modos da orientação.
  Future<void> cycleMode(int delta, Orientation orientation) async {
    final modes = plannerModesFor(orientation);
    final currentIndex = modes.indexOf(modeFor(orientation));
    final nextIndex = (currentIndex + delta).clamp(0, modes.length - 1);
    if (nextIndex == currentIndex) return;
    await setMode(modes[nextIndex], orientation);
  }

  Future<void> setMode(
    AgendaViewMode mode,
    Orientation orientation,
  ) async {
    if (orientation == Orientation.landscape) {
      if (_landscapeMode == mode) return;
      _landscapeMode = mode;
      notifyListeners();
      await _settingsRepository.write(
        SettingsKeys.landscapeMode,
        mode.name,
      );
    } else {
      if (_portraitMode == mode) return;
      _portraitMode = mode;
      notifyListeners();
      await _settingsRepository.write(SettingsKeys.portraitMode, mode.name);
    }
  }

  /// Post-its ativos que cobrem [date] (eventos multi-dia aparecem em cada dia).
  List<PostIt> postItsOn(DateOnly date) {
    return [
      for (final postIt in _postIts)
        if (_coversDate(postIt, date)) postIt,
    ];
  }

  List<PostIt> get undatedPostIts => [
    for (final postIt in _postIts)
      if (postIt.startDate == null) postIt,
  ];

  int countByStatus(PostItStatus status) =>
      _postIts.where((postIt) => postIt.status == status).length;

  /// TO-DO recorrente pendente adiado para uma data futura.
  bool isPostponed(PostIt postIt) => postIt.isPostponedOn(today);

  /// Avança TO-DOs recorrentes pendentes conforme a data local atual.
  ///
  /// Idempotente; chamado na inicialização, no retorno do app e antes de
  /// operações relevantes. Não depende de timers.
  Future<void> ensureRecurringRollover() {
    return _exclusive(() async {
      await _applyRecurringRollover();
      notifyListeners();
    });
  }

  /// Hook do ciclo de vida (`AppLifecycleState.resumed`).
  Future<void> handleAppResumed() => ensureRecurringRollover();

  Future<void> setPostItStatus(
    PostIt postIt,
    PostItStatus status,
  ) {
    return _exclusive(() async {
      await _applyRecurringRollover();
      final current = _findCurrent(postIt.id);
      if (current == null || current.status == status) return;

      final now = _clock.now().toUtc();
      var updated = current.copyWith(status: status, updatedAt: now);
      if (current.isRecurring && status == PostItStatus.active) {
        final start = current.startDate;
        if (start == null || start.isBefore(today)) {
          updated = updated.copyWith(
            startDate: today,
            lastRolloverAt: now,
          );
        }
      }

      await _postItRepository.save(
        updated,
        history: _history(
          updated.id,
          PostItHistoryAction.statusChanged,
          now,
          fromValue: current.status.name,
          toValue: status.name,
        ),
      );
      await _reload();
    });
  }

  /// Valida e persiste a criação/edição de um post-it já montado.
  Future<void> savePostIt(PostIt postIt) => _exclusive(() async {
    _validatePostIt(postIt);
    await _postItRepository.save(
      postIt,
      history: _history(
        postIt.id,
        PostItHistoryAction.created,
        postIt.updatedAt,
      ),
    );
    await _reload();
  });

  /// Cria tarefa, evento ou recorrente, com validação e ordem no fim do dia.
  Future<PostIt> createPostIt({
    required String title,
    required PostItType type,
    bool isHighlight = false,
    String? details,
    DateOnly? startDate,
    DateOnly? endDate,
  }) {
    return _exclusive(() async {
      await _applyRecurringRollover();
      final now = _clock.now().toUtc();
      final resolvedStart = type == PostItType.recurringTodo
          ? _initialRecurringDate(startDate)
          : startDate;
      final postIt = PostIt(
        id: const Uuid().v4(),
        title: title.trim(),
        type: type,
        status: PostItStatus.active,
        isHighlight: type == PostItType.event && isHighlight,
        details: _normalizeDetails(details),
        startDate: resolvedStart,
        endDate: _normalizeEndDate(type, resolvedStart, endDate),
        sortOrder: _nextOrderFor(resolvedStart),
        lastRolloverAt: type == PostItType.recurringTodo ? now : null,
        createdAt: now,
        updatedAt: now,
      );
      _validatePostIt(postIt);
      await _postItRepository.save(
        postIt,
        history: _history(postIt.id, PostItHistoryAction.created, now),
      );
      await _reload();
      return postIt;
    });
  }

  /// Atualiza campos editáveis preservando id, estado, nota e histórico.
  Future<void> updatePostIt(
    PostIt existing, {
    required String title,
    required PostItType type,
    bool isHighlight = false,
    String? details,
    DateOnly? startDate,
    DateOnly? endDate,
  }) {
    return _exclusive(() async {
      await _applyRecurringRollover();
      final current = _findCurrent(existing.id) ?? existing;
      final effectiveType = current.isRecurring ? current.type : type;
      final effectiveStart = current.isRecurring
          ? current.startDate
          : startDate;
      final dateChanged =
          current.startDate?.toIso8601String() !=
          effectiveStart?.toIso8601String();
      final now = _clock.now().toUtc();
      final updated = current.copyWith(
        title: title.trim(),
        type: effectiveType,
        isHighlight:
            effectiveType == PostItType.event ? isHighlight : false,
        details: _normalizeDetails(details),
        startDate: effectiveStart,
        endDate: _normalizeEndDate(
          effectiveType,
          effectiveStart,
          endDate,
        ),
        sortOrder:
            dateChanged && effectiveType != PostItType.event
            ? _nextOrderFor(effectiveStart)
            : current.sortOrder,
        updatedAt: now,
      );

      _validatePostIt(updated);
      await _postItRepository.save(
        updated,
        history: _history(
          updated.id,
          PostItHistoryAction.updated,
          now,
          fromValue: current.title,
          toValue: updated.title,
        ),
      );
      await _reload();
    });
  }

  /// Exclusão definitiva lógica: apaga da agenda, preserva registro e histórico.
  Future<void> deletePostIt(PostIt postIt) {
    return _exclusive(() async {
      final now = _clock.now().toUtc();
      await _postItRepository.softDelete(
        id: postIt.id,
        deletedAt: now,
        history: _history(postIt.id, PostItHistoryAction.deleted, now),
      );
      await _reload();
    });
  }

  /// Move um post-it para [targetDate]; eventos mantêm a duração.
  Future<void> movePostIt(
    PostIt postIt,
    DateOnly targetDate, {
    int? targetIndex,
  }) {
    return _exclusive(() async {
      await _applyRecurringRollover();
      final current = _findCurrent(postIt.id);
      if (current == null) return;

      final today = this.today;
      var target = targetDate;
      var postponed = false;
      if (current.isRecurring) {
        if (target.isBefore(today)) target = today;
        postponed = target.isAfter(today);
      }

      final sourceDate = current.startDate;
      if (current.isEvent) {
        if (sourceDate != null && sourceDate.isSameDay(target)) return;
      } else if (sourceDate != null &&
          sourceDate.isSameDay(target) &&
          targetIndex == null) {
        return;
      }

      final now = _clock.now().toUtc();
      final moved = _movedCopy(current, target, now);
      final updates = <PostIt>[];
      final history = <PostItHistoryEntry>[
        _history(
          current.id,
          postponed
              ? PostItHistoryAction.manualPostponed
              : PostItHistoryAction.moved,
          now,
          fromValue: sourceDate?.toIso8601String(),
          toValue: target.toIso8601String(),
        ),
      ];

      if (current.isEvent) {
        updates.add(moved);
      } else {
        final targetItems = _sortedDayItems(
          target,
        ).where((item) => item.id != current.id).toList();
        final insertion = (targetIndex ?? targetItems.length).clamp(
          0,
          targetItems.length,
        );
        targetItems.insert(insertion, moved);
        updates.addAll(_reindex(targetItems, now));

        if (sourceDate != null && !sourceDate.isSameDay(target)) {
          final sourceItems = _sortedDayItems(
            sourceDate,
          ).where((item) => item.id != current.id).toList();
          updates.addAll(_reindex(sourceItems, now));
        }
      }

      await _postItRepository.saveBatch(updates, history: history);
      await _reload();
    });
  }

  /// Redimensiona um evento, ajustando início e/ou fim.
  Future<void> resizeEvent(
    PostIt postIt, {
    required DateOnly startDate,
    required DateOnly endDate,
  }) {
    return _exclusive(() async {
      final current = _findCurrent(postIt.id) ?? postIt;
      if (!current.isEvent) {
        throw ArgumentError('Somente eventos podem ser redimensionados.');
      }
      final normalizedEnd = endDate.isBefore(startDate)
          ? startDate
          : endDate;
      final updated = current.copyWith(
        startDate: startDate,
        endDate: normalizedEnd.isSameDay(startDate) ? null : normalizedEnd,
        updatedAt: _clock.now().toUtc(),
      );

      _validatePostIt(updated);
      await _postItRepository.save(
        updated,
        history: _history(
          updated.id,
          PostItHistoryAction.resized,
          updated.updatedAt,
          fromValue: _rangeLabel(current),
          toValue: _rangeLabel(updated),
        ),
      );
      await _reload();
    });
  }

  /// Reposiciona um post-it dentro do dia (índice zero-based).
  Future<void> reorderPostIt(PostIt postIt, int newIndex) {
    return _exclusive(() async {
      final current = _findCurrent(postIt.id);
      final date = current?.startDate;
      if (current == null ||
          current.isEvent ||
          date == null) {
        return;
      }

      final items = _sortedDayItems(date);
      final from = items.indexWhere((item) => item.id == current.id);
      if (from < 0) return;
      final to = newIndex.clamp(0, items.length - 1);
      if (from == to) return;

      final moved = items.removeAt(from);
      items.insert(to, moved);
      await _postItRepository.saveBatch(
        _reindex(items, _clock.now().toUtc()),
        history: [
          _history(
            current.id,
            PostItHistoryAction.reordered,
            _clock.now().toUtc(),
            fromValue: '$from',
            toValue: '$to',
          ),
        ],
      );
      await _reload();
    });
  }

  Future<void> movePostItUp(PostIt postIt) =>
      reorderPostIt(postIt, _indexInDay(postIt) - 1);

  Future<void> movePostItDown(PostIt postIt) =>
      reorderPostIt(postIt, _indexInDay(postIt) + 1);

  bool canMovePostItUp(PostIt postIt) =>
      !postIt.isEvent &&
      postIt.startDate != null &&
      _indexInDay(postIt) > 0;

  bool canMovePostItDown(PostIt postIt) {
    if (postIt.isEvent || postIt.startDate == null) return false;
    final index = _indexInDay(postIt);
    return index >= 0 && index < _sortedDayItems(postIt.startDate!).length - 1;
  }

  Future<void> _reload() async {
    _postIts = await _postItRepository.loadAll();
    _error = null;
    notifyListeners();
  }

  Future<void> _applyRecurringRollover() async {
    final plan = const EnsureRecurringRollover()(
      postIts: _postIts,
      today: today,
      now: _clock.now().toUtc(),
      idGenerator: () => const Uuid().v4(),
    );
    if (!plan.hasChanges) return;

    await _postItRepository.saveBatch(
      plan.updates,
      history: plan.history,
    );
    _postIts = await _postItRepository.loadAll();
  }

  DateOnly _initialRecurringDate(DateOnly? startDate) {
    final today = this.today;
    if (startDate == null || startDate.isBefore(today)) return today;
    return startDate;
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _mutationQueue.then((_) => action());
    _mutationQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  PostIt? _findCurrent(String id) {
    for (final postIt in _postIts) {
      if (postIt.id == id) return postIt;
    }
    return null;
  }

  List<PostIt> _sortedDayItems(DateOnly date) {
    final items = [
      for (final postIt in _postIts)
        if (!postIt.isEvent &&
            postIt.startDate != null &&
            postIt.startDate!.isSameDay(date))
          postIt,
    ];
    items.sort((a, b) {
      final byOrder = a.sortOrder.compareTo(b.sortOrder);
      if (byOrder != 0) return byOrder;
      final byCreated = a.createdAt.compareTo(b.createdAt);
      if (byCreated != 0) return byCreated;
      return a.id.compareTo(b.id);
    });
    return items;
  }

  int _indexInDay(PostIt postIt) {
    final date = postIt.startDate;
    if (date == null) return -1;
    return _sortedDayItems(
      date,
    ).indexWhere((item) => item.id == postIt.id);
  }

  int _nextOrderFor(DateOnly? date) {
    if (date == null) {
      final undated = [
        for (final postIt in _postIts)
          if (postIt.startDate == null && !postIt.isEvent) postIt,
      ];
      if (undated.isEmpty) return 0;
      return undated
              .map((postIt) => postIt.sortOrder)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }
    final items = _sortedDayItems(date);
    if (items.isEmpty) return 0;
    return items.last.sortOrder + 1;
  }

  List<PostIt> _reindex(List<PostIt> items, DateTime now) {
    return [
      for (var index = 0; index < items.length; index++)
        items[index].sortOrder == index
            ? items[index]
            : items[index].copyWith(sortOrder: index, updatedAt: now),
    ];
  }

  PostIt _movedCopy(PostIt postIt, DateOnly targetDate, DateTime now) {
    if (!postIt.isEvent) {
      return postIt.copyWith(
        startDate: targetDate,
        endDate: null,
        updatedAt: now,
      );
    }
    return postIt.copyWith(
      startDate: targetDate,
      endDate: postIt.endDate == null
          ? null
          : targetDate.addDays(postIt.durationInDays - 1),
      updatedAt: now,
    );
  }

  static DateOnly? _normalizeEndDate(
    PostItType type,
    DateOnly? startDate,
    DateOnly? endDate,
  ) {
    if (type != PostItType.event || endDate == null) return null;
    if (startDate == null) return endDate;
    return endDate.isSameDay(startDate) ? null : endDate;
  }

  static String? _normalizeDetails(String? details) {
    final trimmed = details?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _rangeLabel(PostIt postIt) {
    final start = postIt.startDate?.toIso8601String() ?? '';
    final end = postIt.effectiveEndDate?.toIso8601String() ?? '';
    return '$start|$end';
  }

  static PostItHistoryEntry _history(
    String postItId,
    PostItHistoryAction action,
    DateTime at, {
    String? fromValue,
    String? toValue,
  }) => PostItHistoryEntry(
    id: const Uuid().v4(),
    postItId: postItId,
    action: action,
    fromValue: fromValue,
    toValue: toValue,
    createdAt: at,
  );

  static bool _coversDate(PostIt postIt, DateOnly date) {
    final start = postIt.startDate;
    if (start == null) return false;
    final end = postIt.effectiveEndDate ?? start;
    return !date.isBefore(start) && !date.isAfter(end);
  }

  static DateOnly? _parseDate(String? value) {
    if (value == null) return null;
    try {
      return DateOnly.parse(value);
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static AgendaViewMode _parseMode(
    String? value,
    AgendaViewMode fallback,
  ) => AgendaViewModeX.fromStorage(value) ?? fallback;
}
