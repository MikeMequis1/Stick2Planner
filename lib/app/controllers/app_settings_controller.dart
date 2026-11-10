import 'dart:async';

import 'package:flutter/material.dart';

// Parâmetros nomeados não podem usar campos privados como initializing formals.
// ignore_for_file: prefer_initializing_formals

import '../../domain/repositories/settings_repository.dart';
import '../app_strings.dart';
import '../services/screen_wake_service.dart';
import '../settings_keys.dart';
import '../theme/app_palette.dart';
import '../../core/date_formatting.dart';

/// Preferências globais do aplicativo.
final class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    required SettingsRepository settingsRepository,
    required ScreenWakeService screenWake,
  }) : _settingsRepository = settingsRepository,
       _screenWake = screenWake;

  final SettingsRepository _settingsRepository;
  final ScreenWakeService _screenWake;

  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.ptBr;
  AppPalette _palette = AppPalette.emerald;
  bool _animationsEnabled = true;
  bool _keepScreenAwake = true;
  bool _showCalendarHints = true;
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  AppPalette get palette => _palette;
  bool get animationsEnabled => _animationsEnabled;
  bool get keepScreenAwake => _keepScreenAwake;
  bool get showCalendarHints => _showCalendarHints;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    try {
      await _loadValues();
    } on Object {
      // Preferências são best-effort; o app continua com os padrões.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Relê as preferências, por exemplo após restaurar um backup.
  Future<void> reload() async {
    try {
      await _loadValues();
    } on Object {
      // Mantém os valores atuais em caso de falha.
    }
    notifyListeners();
  }

  Future<void> _loadValues() async {
    final values = await _settingsRepository.loadAll();
    _themeMode = _parseTheme(values[SettingsKeys.themeMode]);
    _language = _parseLanguage(values[SettingsKeys.language]);
    AppStrings.setLanguage(_language);
    DateFormats.locale = _language.dateLocale;
    _palette = _parsePalette(values[SettingsKeys.palette]);
    _animationsEnabled = values[SettingsKeys.animationsEnabled] != 'false';
    _keepScreenAwake = values[SettingsKeys.keepScreenAwake] != 'false';
    _showCalendarHints = values[SettingsKeys.showCalendarHints] != 'false';
    _notificationsEnabled = values[SettingsKeys.notificationsEnabled] == 'true';
    unawaited(_applyWakeLock());
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _settingsRepository.write(SettingsKeys.themeMode, mode.name);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    AppStrings.setLanguage(language);
    DateFormats.locale = language.dateLocale;
    notifyListeners();
    await _settingsRepository.write(SettingsKeys.language, language.name);
  }

  Future<void> setPalette(AppPalette palette) async {
    if (_palette == palette) return;
    _palette = palette;
    notifyListeners();
    await _settingsRepository.write(SettingsKeys.palette, palette.name);
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    if (_animationsEnabled == enabled) return;
    _animationsEnabled = enabled;
    notifyListeners();
    await _settingsRepository.write(
      SettingsKeys.animationsEnabled,
      enabled.toString(),
    );
  }

  Future<void> setKeepScreenAwake(bool enabled) async {
    if (_keepScreenAwake == enabled) return;
    _keepScreenAwake = enabled;
    notifyListeners();
    unawaited(_applyWakeLock());
    await _settingsRepository.write(
      SettingsKeys.keepScreenAwake,
      enabled.toString(),
    );
  }

  Future<void> setShowCalendarHints(bool enabled) async {
    if (_showCalendarHints == enabled) return;
    _showCalendarHints = enabled;
    notifyListeners();
    await _settingsRepository.write(
      SettingsKeys.showCalendarHints,
      enabled.toString(),
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
    await _settingsRepository.write(
      SettingsKeys.notificationsEnabled,
      enabled.toString(),
    );
  }

  Future<void> _applyWakeLock() async {
    try {
      if (_keepScreenAwake) {
        await _screenWake.enable();
      } else {
        await _screenWake.disable();
      }
    } on Object {
      // Wakelock é best-effort.
    }
  }

  static ThemeMode _parseTheme(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static AppPalette _parsePalette(String? value) {
    for (final palette in AppPalette.values) {
      if (palette.name == value) return palette;
    }
    return AppPalette.emerald;
  }

  static AppLanguage _parseLanguage(String? value) {
    return value == AppLanguage.en.name ? AppLanguage.en : AppLanguage.ptBr;
  }
}
