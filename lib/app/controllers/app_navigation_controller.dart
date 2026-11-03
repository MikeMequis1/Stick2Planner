import 'package:flutter/foundation.dart';

/// Seções principais do aplicativo, na ordem do trilho/barra de navegação.
enum AppSection { agenda, inbox, notes }

/// Controla a seção visível da casca e permite navegação a partir de rotas
/// empilhadas (por exemplo, detalhe de nota → Agenda).
final class AppNavigationController extends ChangeNotifier {
  AppSection _section = AppSection.agenda;

  AppSection get section => _section;

  void select(AppSection section) {
    if (_section == section) return;
    _section = section;
    notifyListeners();
  }
}
