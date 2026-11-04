import 'package:drift/native.dart';
import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/services/sync_coordinator.dart';
import 'package:stick2planner/app/services/token_store.dart';
import 'package:stick2planner/core/clock.dart';
import 'package:stick2planner/data/db/app_database.dart';

/// Relógio fixo para testes determinísticos.
final class FixedClock implements Clock {
  const FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

/// Dependências completas com banco em memória.
AppDependencies testDependencies({
  required DateTime now,
  TokenStore? tokens,
  SyncCoordinator? sync,
  SyncTransportFactory? syncTransportFactory,
}) {
  return AppDependencies.fromDatabase(
    AppDatabase(NativeDatabase.memory()),
    clock: FixedClock(now),
    tokens: tokens ?? InMemoryTokenStore(),
    sync: sync,
    syncTransportFactory: syncTransportFactory,
  );
}

DateTime utcDate(int year, int month, int day, [int hour = 12]) =>
    DateTime.utc(year, month, day, hour);
