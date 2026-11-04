import 'package:flutter/widgets.dart';

import '../../../core/date_only.dart';
import '../../../domain/entities/post_it.dart';

/// Resolve os post-its exibidos em um dia da grade.
typedef DayItemsResolver = List<PostIt> Function(DateOnly date);

/// Célula registrada para resolver qual dia está sob o dedo durante a prévia.
class DayPreviewRegistration {
  DayPreviewRegistration({
    required this.date,
    required this.key,
    required this.itemsFor,
  });

  DateOnly date;
  final GlobalKey key;
  DayItemsResolver itemsFor;
}

/// Mapa das células de dia visíveis.
///
/// A prévia por toque longo precisa descobrir qual data está sob o dedo
/// enquanto ele desliza; o gesto fica preso à célula de origem, então a
/// geometria das demais células é consultada por aqui.
class DayPreviewRegistry {
  final List<DayPreviewRegistration> _entries = [];

  void register(DayPreviewRegistration entry) => _entries.add(entry);

  void unregister(DayPreviewRegistration entry) => _entries.remove(entry);

  /// Célula cujo retângulo contém [globalPosition], se houver.
  DayPreviewRegistration? resolve(Offset globalPosition) {
    for (final entry in _entries) {
      final box = entry.key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final local = box.globalToLocal(globalPosition);
      if (local.dx < 0 || local.dy < 0) continue;
      if (local.dx > box.size.width || local.dy > box.size.height) continue;
      return entry;
    }
    return null;
  }
}

/// Disponibiliza o [DayPreviewRegistry] para as células da grade.
class DayPreviewScope extends InheritedWidget {
  const DayPreviewScope({
    super.key,
    required this.registry,
    required super.child,
  });

  final DayPreviewRegistry registry;

  static DayPreviewRegistry? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DayPreviewScope>()?.registry;

  @override
  bool updateShouldNotify(DayPreviewScope oldWidget) =>
      oldWidget.registry != registry;
}
