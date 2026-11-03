import 'package:wakelock_plus/wakelock_plus.dart';

/// Mantém a tela ligada enquanto o planner está em uso.
///
/// O serviço fica isolado para permitir uma futura opção “Manter tela ligada”
/// nas configurações sem acoplar a UI ao plugin.
abstract interface class ScreenWakeService {
  Future<void> enable();

  Future<void> disable();
}

final class WakelockPlusScreenWakeService implements ScreenWakeService {
  const WakelockPlusScreenWakeService();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
