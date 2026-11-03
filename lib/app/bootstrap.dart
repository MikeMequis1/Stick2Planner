import '../core/clock.dart';
import '../data/db/app_database.dart';
import '../data/repositories/drift_note_repository.dart';
import '../data/repositories/drift_post_it_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import 'controllers/notes_controller.dart';
import 'controllers/planner_controller.dart';
import 'services/screen_wake_service.dart';

/// Composição das dependências do aplicativo.
///
/// Mantém a criação de banco, repositórios e controllers em um único ponto;
/// testes montam a mesma estrutura com banco em memória.
final class AppDependencies {
  AppDependencies({
    required this.database,
    required this.planner,
    required this.notes,
    ScreenWakeService? screenWake,
  }) : screenWake = screenWake ?? const WakelockPlusScreenWakeService();

  factory AppDependencies.fromDatabase(
    AppDatabase database, {
    Clock clock = const SystemClock(),
  }) {
    final postItRepository = DriftPostItRepository(database);
    final noteRepository = DriftNoteRepository(database);
    final settingsRepository = DriftSettingsRepository(database);

    return AppDependencies(
      database: database,
      planner: PlannerController(
        postItRepository: postItRepository,
        settingsRepository: settingsRepository,
        clock: clock,
      ),
      notes: NotesController(
        noteRepository: noteRepository,
        clock: clock,
      ),
    );
  }

  static AppDependencies open({Clock clock = const SystemClock()}) =>
      AppDependencies.fromDatabase(AppDatabase.open(), clock: clock);

  final AppDatabase database;
  final PlannerController planner;
  final NotesController notes;
  final ScreenWakeService screenWake;

  Future<void> initialize() async {
    await Future.wait([planner.initialize(), notes.initialize()]);
  }

  Future<void> dispose() async {
    planner.dispose();
    notes.dispose();
    await database.close();
  }
}
