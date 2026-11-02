import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Barra contínua de um evento multi-dia dentro de uma linha da grade.
///
/// O mesmo post-it pode gerar um segmento por semana; as pontas indicam
/// continuação e o ID permanece o mesmo.
class EventBar extends StatelessWidget {
  const EventBar({
    super.key,
    required this.postIt,
    required this.continuesBefore,
    required this.continuesAfter,
    required this.showTitle,
    required this.compact,
    this.onTap,
  });

  final PostIt postIt;
  final bool continuesBefore;
  final bool continuesAfter;

  /// Falso em segmentos de continuação cujo início já apareceu no período;
  /// evita repetir o mesmo conteúdo em outra linha.
  final bool showTitle;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = postItColors(postIt, theme.colorScheme);
    final isResolved = postIt.status != PostItStatus.active;
    final radius = BorderRadius.horizontal(
      left: Radius.circular(continuesBefore ? 2 : 8),
      right: Radius.circular(continuesAfter ? 2 : 8),
    );

    return Semantics(
      button: onTap != null,
      label: postItSemanticLabel(postIt),
      excludeSemantics: true,
      child: Material(
        color: colors.background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
            child: Row(
              children: [
                if (continuesBefore)
                  Icon(
                    Icons.chevron_left,
                    size: compact ? 12 : 16,
                    color: colors.foreground,
                  ),
                Icon(
                  postItIcon(postIt),
                  size: compact ? 12 : 15,
                  color: colors.foreground,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    showTitle ? postIt.title : AppStrings.continuation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 12,
                      height: 1.2,
                      fontWeight: showTitle ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: showTitle ? FontStyle.normal : FontStyle.italic,
                      color: colors.foreground,
                      decoration: isResolved
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                if (continuesAfter)
                  Icon(
                    Icons.chevron_right,
                    size: compact ? 12 : 16,
                    color: colors.foreground,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
