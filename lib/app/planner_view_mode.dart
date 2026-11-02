import 'package:flutter/material.dart';

import '../domain/calendar/agenda_view_mode.dart';
import 'app_strings.dart';

export '../domain/calendar/agenda_view_mode.dart';

extension AgendaViewModeLabels on AgendaViewMode {
  String get label => switch (this) {
    AgendaViewMode.day => AppStrings.viewModeDay,
    AgendaViewMode.fourDays => AppStrings.viewModeFourDays,
    AgendaViewMode.week => AppStrings.viewModeWeek,
    AgendaViewMode.twoWeeks => AppStrings.viewModeTwoWeeks,
    AgendaViewMode.month => AppStrings.viewModeMonth,
  };
}

/// Modos disponíveis por orientação, do menor para o maior.
List<AgendaViewMode> plannerModesFor(Orientation orientation) {
  return orientation == Orientation.landscape
      ? const [
          AgendaViewMode.week,
          AgendaViewMode.twoWeeks,
          AgendaViewMode.month,
        ]
      : const [
          AgendaViewMode.day,
          AgendaViewMode.fourDays,
          AgendaViewMode.week,
        ];
}

AgendaViewMode defaultModeFor(Orientation orientation) =>
    orientation == Orientation.landscape
    ? AgendaViewMode.week
    : AgendaViewMode.day;
