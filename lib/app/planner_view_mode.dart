import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Modos de visualização da agenda, separados por orientação.
enum PlannerViewMode { day, fourDays, week, twoWeeks, month }

extension PlannerViewModeX on PlannerViewMode {
  String get label => switch (this) {
    PlannerViewMode.day => AppStrings.viewModeDay,
    PlannerViewMode.fourDays => AppStrings.viewModeFourDays,
    PlannerViewMode.week => AppStrings.viewModeWeek,
    PlannerViewMode.twoWeeks => AppStrings.viewModeTwoWeeks,
    PlannerViewMode.month => AppStrings.viewModeMonth,
  };

  /// Número de dias cobertos; zero para o mês (grade depende do mês).
  int get visibleDays => switch (this) {
    PlannerViewMode.day => 1,
    PlannerViewMode.fourDays => 4,
    PlannerViewMode.week => 7,
    PlannerViewMode.twoWeeks => 14,
    PlannerViewMode.month => 0,
  };

  static PlannerViewMode? fromStorage(String? value) {
    for (final mode in PlannerViewMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}

/// Modos disponíveis por orientação.
List<PlannerViewMode> plannerModesFor(Orientation orientation) {
  return orientation == Orientation.landscape
      ? const [
          PlannerViewMode.week,
          PlannerViewMode.twoWeeks,
          PlannerViewMode.month,
        ]
      : const [
          PlannerViewMode.day,
          PlannerViewMode.fourDays,
          PlannerViewMode.week,
        ];
}

PlannerViewMode defaultModeFor(Orientation orientation) =>
    orientation == Orientation.landscape
    ? PlannerViewMode.week
    : PlannerViewMode.day;
