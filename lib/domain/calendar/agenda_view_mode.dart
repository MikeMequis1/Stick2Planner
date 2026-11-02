/// Modos de visualização da agenda.
///
/// Os valores são persistidos pelo nome; não renomeie sem migração de
/// preferências.
enum AgendaViewMode { day, fourDays, week, twoWeeks, month }

extension AgendaViewModeX on AgendaViewMode {
  /// Dias cobertos; zero para o mês (grade depende do mês).
  int get visibleDays => switch (this) {
    AgendaViewMode.day => 1,
    AgendaViewMode.fourDays => 4,
    AgendaViewMode.week => 7,
    AgendaViewMode.twoWeeks => 14,
    AgendaViewMode.month => 0,
  };

  bool get isMonth => this == AgendaViewMode.month;

  static AgendaViewMode? fromStorage(String? value) {
    for (final mode in AgendaViewMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}
