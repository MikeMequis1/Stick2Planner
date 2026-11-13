import 'package:flutter/material.dart';

import '../../core/platform_support.dart';

/// Abre um menu de contexto posicionado no ponteiro.
Future<T?> showDesktopContextMenu<T>(
  BuildContext context, {
  required Offset globalPosition,
  required List<PopupMenuEntry<T>> items,
}) {
  if (!isDesktopTargetPlatform) return Future<T?>.value();
  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox || !overlay.hasSize) {
    return Future<T?>.value();
  }
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    ),
    items: items,
  );
}

/// Associa um clique direito a um menu de contexto no desktop.
///
/// Em mobile o widget é transparente: nenhum gesto ou layout adicional é
/// aplicado, preservando long press, arraste e toque existentes.
class DesktopContextMenuRegion extends StatelessWidget {
  const DesktopContextMenuRegion({
    super.key,
    required this.child,
    required this.onOpen,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<Offset>? onOpen;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || onOpen == null || !isDesktopTargetPlatform) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) => onOpen!(details.globalPosition),
      child: child,
    );
  }
}
