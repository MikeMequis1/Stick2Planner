/// Fonte de data/hora injetável para deixar regras determinísticas nos testes.
abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
