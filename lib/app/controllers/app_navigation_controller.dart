import 'dart:async';

import 'package:flutter/foundation.dart';

/// Seções principais do aplicativo, na ordem do trilho/barra de navegação.
enum AppSection { agenda, inbox, notes }

/// Controla a seção visível da casca e permite navegação a partir de rotas
/// empilhadas (por exemplo, detalhe de nota → Agenda).
final class AppNavigationController extends ChangeNotifier {
  AppSection _section = AppSection.agenda;
  String? _focusedPostItId;
  Timer? _focusTimer;

  AppSection get section => _section;

  /// Post-it realçado temporariamente ao abrir a Agenda a partir de outro local.
  String? get focusedPostItId => _focusedPostItId;

  void select(AppSection section) {
    if (_section == section) return;
    _section = section;
    notifyListeners();
  }

  void focusPostIt(
    String postItId, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _focusTimer?.cancel();
    _focusedPostItId = postItId;
    notifyListeners();
    _focusTimer = Timer(duration, () {
      _focusedPostItId = null;
      notifyListeners();
    });
  }

  void clearPostItFocus() {
    _focusTimer?.cancel();
    _focusTimer = null;
    if (_focusedPostItId == null) return;
    _focusedPostItId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }
}
