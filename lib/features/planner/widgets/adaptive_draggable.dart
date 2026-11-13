import 'package:flutter/material.dart';

import '../../../core/platform_support.dart';
import 'post_it_drag_data.dart';

/// Arrasta post-its/eventos com o gesto adequado ao dispositivo.
///
/// Toque longo no celular preserva o comportamento existente; no desktop o
/// ponteiro inicia o arraste imediatamente, sem exigir 200 ms parado.
class AdaptivePostItDraggable extends StatelessWidget {
  const AdaptivePostItDraggable({
    super.key,
    required this.data,
    required this.feedback,
    required this.child,
    this.childWhenDragging,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDragEnd,
    this.onDraggableCanceled,
  });

  final PostItDragData data;
  final Widget feedback;
  final Widget child;
  final Widget? childWhenDragging;
  final int? maxSimultaneousDrags;
  final VoidCallback? onDragStarted;
  final ValueChanged<DraggableDetails>? onDragEnd;
  final VoidCallback? onDraggableCanceled;

  @override
  Widget build(BuildContext context) {
    if (isDesktopTargetPlatform) {
      return MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Draggable<PostItDragData>(
          data: data,
          maxSimultaneousDrags: maxSimultaneousDrags,
          dragAnchorStrategy: recordingDragAnchorStrategy,
          feedback: feedback,
          childWhenDragging: childWhenDragging,
          onDragStarted: onDragStarted,
          onDragEnd: onDragEnd,
          onDraggableCanceled: (_, _) => onDraggableCanceled?.call(),
          child: child,
        ),
      );
    }

    return LongPressDraggable<PostItDragData>(
      data: data,
      maxSimultaneousDrags: maxSimultaneousDrags,
      delay: const Duration(milliseconds: 200),
      dragAnchorStrategy: recordingDragAnchorStrategy,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      onDraggableCanceled: (_, _) => onDraggableCanceled?.call(),
      child: child,
    );
  }
}
