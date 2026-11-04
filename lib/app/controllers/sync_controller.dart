// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_models.dart';

enum SyncRunStatus { idle, running, success, failure }

/// Estado observável de sincronização, independente da interface.
final class SyncController extends ChangeNotifier {
  SyncController({required SyncEngine Function() engineFactory})
    : _engineFactory = engineFactory;

  final SyncEngine Function() _engineFactory;

  SyncRunStatus _status = SyncRunStatus.idle;
  SyncReport? _lastReport;
  String? _error;

  SyncRunStatus get status => _status;
  SyncReport? get lastReport => _lastReport;
  String? get error => _error;
  bool get isRunning => _status == SyncRunStatus.running;

  /// Executa uma rodada; chamadas concorrentes são ignoradas.
  Future<SyncReport?> syncNow() async {
    if (isRunning) return null;
    _status = SyncRunStatus.running;
    _error = null;
    notifyListeners();
    try {
      final report = await _engineFactory().run();
      _lastReport = report;
      _status = SyncRunStatus.success;
      return report;
    } on Object catch (error) {
      _error = error.toString();
      _status = SyncRunStatus.failure;
      return null;
    } finally {
      notifyListeners();
    }
  }
}
