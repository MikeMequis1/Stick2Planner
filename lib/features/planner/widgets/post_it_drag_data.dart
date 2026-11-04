import 'package:flutter/widgets.dart';

import '../../../domain/entities/post_it.dart';

/// Dados carregados durante o arraste de um post-it.
final class PostItDragData {
  PostItDragData(this.postIt);

  final PostIt postIt;

  /// Posição do dedo dentro do widget arrastado, registrada no início do gesto.
  ///
  /// `DragTargetDetails.offset` entrega o canto do feedback ancorado, não a
  /// posição do dedo; somar este deslocamento recupera o ponto real do toque.
  Offset? anchorOffset;

  /// Posição global do dedo a partir do offset informado pelo `DragTarget`.
  Offset pointerAt(Offset feedbackOffset) =>
      feedbackOffset + (anchorOffset ?? Offset.zero);
}

/// Âncora que registra o deslocamento do dedo e mantém o feedback no lugar.
Offset recordingDragAnchorStrategy(
  Draggable<Object> draggable,
  BuildContext context,
  Offset position,
) {
  final anchor = childDragAnchorStrategy(draggable, context, position);
  final data = draggable.data;
  if (data is PostItDragData) {
    data.anchorOffset = anchor;
  }
  return anchor;
}
