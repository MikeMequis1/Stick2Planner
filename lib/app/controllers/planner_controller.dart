import 'package:flutter/widgets.dart';

// Parâmetros nomeados não podem usar campos privados como initializing formals.
// ignore_for_file: prefer_initializing_formals

import '../../core/clock.dart';
import '../../core/date_only.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/repositories/post_it_repository.dart';
import '../../domain/repositories/settings_repository.dart';
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
  PlannerViewMode _portraitMode = PlannerViewMode.day;
  PlannerViewMode _landscapeMode = PlannerViewMode.week;
  List<PostIt> _postIts = const [];
  bool _isLoading = true;
  bool _initialized = false;
  String? _error;

  DateOnly get selectedDate => _selectedDate;
  DateOnly get today => DateOnly.fromDateTime(_clock.now());
  PlannerViewMode get portraitMode => _portraitMode;
  PlannerViewMode get landscapeMode => _landscapeMode;
  List<PostIt> get postIts => List.unmodifiable(_postIts);
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlannerViewMode modeFor(Orientation orientation) =>
      orientation == Orientation.landscape ? _landscapeMode : _portraitMode;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final settings = await _settingsRepository.loadAll();
      _selectedDate =
          _parseDate(settings[SettingsKeys.selectedDate]) ?? today;
      _portraitMode = _parseMode(
        settings[SettingsKeys.portraitMode],
        PlannerViewMode.day,
      );
      _landscapeMode = _parseMode(
        settings[SettingsKeys.landscapeMode],
        PlannerViewMode.week,
      );
      _postIts = await _postItRepository.loadAll();
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

  Future<void> setMode(
    PlannerViewMode mode,
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

  /// Valida e persiste a criação/edição de um post-it.
  ///
  /// A UI de criação chega na Etapa 3; a regra já fica disponível e testada.
  Future<void> savePostIt(PostIt postIt) async {
    _validatePostIt(postIt);
    await _postItRepository.save(postIt);
    await refresh();
  }

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

  static PlannerViewMode _parseMode(
    String? value,
    PlannerViewMode fallback,
  ) => PlannerViewModeX.fromStorage(value) ?? fallback;
}
