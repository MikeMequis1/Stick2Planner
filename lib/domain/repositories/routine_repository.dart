import '../../core/date_only.dart';
import '../entities/routine.dart';

/// Persistência local das rotinas e do estado por ocorrência.
abstract interface class RoutineRepository {
  Future<List<Routine>> loadAll();

  /// Salva a rotina e suas atividades; itens removidos são apagados.
  Future<void> save(Routine routine);

  Future<void> delete(String id);

  Future<void> setCompletion({
    required String routineItemId,
    required DateOnly date,
    required bool completed,
    required DateTime at,
  });
}
