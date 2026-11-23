import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/date_only.dart';

/// Janela usada para distinguir um, dois ou três toques no dia.
const dayMultiTapWindow = Duration(milliseconds: 300);

/// Coordena a sequência de toques de um dia (fundo e post-its).
///
/// A seleção é feita imediatamente pelo chamador; este coordenador apenas
/// decide quando a ação de um, dois ou três toques deve acontecer.
final class DayTapCoordinator {
  DayTapCoordinator({this.window = dayMultiTapWindow});

  final Duration window;

  Timer? _timer;
  DateOnly? _date;
  int _count = 0;
  VoidCallback? _singleAction;
  VoidCallback? _taskAction;
  VoidCallback? _eventAction;

  void registerTap({
    required DateOnly date,
    required VoidCallback? singleAction,
    required VoidCallback taskAction,
    required VoidCallback eventAction,
  }) {
    if (_date != null && !_date!.isSameDay(date)) {
      _reset();
    }
    _date = date;
    _count++;
    _singleAction = singleAction;
    _taskAction = taskAction;
    _eventAction = eventAction;
    _timer?.cancel();

    if (_count >= 3) {
      final action = _eventAction;
      _reset();
      action?.call();
      return;
    }

    _timer = Timer(window, _fire);
  }

  void _fire() {
    final count = _count;
    final single = _singleAction;
    final task = _taskAction;
    _reset();
    if (count == 1) {
      single?.call();
    } else if (count == 2) {
      task?.call();
    }
  }

  void cancel() => _reset();

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _date = null;
    _count = 0;
    _singleAction = null;
    _taskAction = null;
    _eventAction = null;
  }

  void dispose() => _reset();
}

/// Disponibiliza o coordenador de toques para as células da grade.
class DayTapScope extends InheritedWidget {
  const DayTapScope({
    super.key,
    required this.coordinator,
    required super.child,
  });

  final DayTapCoordinator coordinator;

  static DayTapCoordinator? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DayTapScope>()?.coordinator;

  static DayTapCoordinator of(BuildContext context) {
    final coordinator = maybeOf(context);
    assert(coordinator != null, 'DayTapScope não encontrado na grade.');
    return coordinator!;
  }

  @override
  bool updateShouldNotify(DayTapScope oldWidget) =>
      coordinator != oldWidget.coordinator;
}
