import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../core/platform_support.dart';

/// Alça exclusiva para iniciar a reordenação de um item.
///
/// Ficar restrita à alça evita conflito com edição, rolagem, checkbox e
/// navegação horizontal por gesto. Funciona com toque, mouse e caneta.
class ReorderHandle extends StatelessWidget {
  const ReorderHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = isDesktopTargetPlatform
        ? AppStrings.dragToReorderDesktop
        : AppStrings.dragToReorder;
    return ReorderableDragStartListener(
      index: index,
      child: Tooltip(
        message: label,
        child: Semantics(
          button: true,
          label: label,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Eleva o item durante o arraste e mantém o fundo do cartão visível.
Widget reorderProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      final scheme = Theme.of(context).colorScheme;
      return Material(
        elevation: 8 * t,
        color: scheme.surfaceContainerHigh,
        shadowColor: scheme.shadow.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        child: child,
      );
    },
    child: child,
  );
}
