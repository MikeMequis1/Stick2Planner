import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Barra contínua de um evento multi-dia dentro de uma linha da grade.
///
/// O mesmo post-it pode gerar um segmento por semana; as pontas indicam
/// continuação e o ID permanece o mesmo.
class EventBar extends StatefulWidget {
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
  State<EventBar> createState() => _EventBarState();
}

class _EventBarState extends State<EventBar> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postIt = widget.postIt;
    final colors = postItColors(postIt, theme.colorScheme);
    final isResolved = postIt.status != PostItStatus.active;
    final radius = BorderRadius.horizontal(
      left: Radius.circular(widget.continuesBefore ? 2 : 8),
      right: Radius.circular(widget.continuesAfter ? 2 : 8),
    );

    return Semantics(
      button: widget.onTap != null,
      label: postItSemanticLabel(postIt),
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Material(
          color: colors.background,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.continuesBefore
                    ? (widget.compact ? 4 : 8)
                    : (widget.compact ? 12 : 24),
                right: widget.continuesAfter
                    ? (widget.compact ? 4 : 8)
                    : (widget.compact ? 12 : 24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.continuesBefore)
                    Icon(
                      Icons.chevron_left,
                      size: widget.compact ? 12 : 16,
                      color: colors.foreground,
                    ),
                  Icon(
                    postItIcon(postIt),
                    size: widget.compact ? 12 : 15,
                    color: colors.foreground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.showTitle ? postIt.title : AppStrings.continuation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.compact ? 10 : 12,
                        height: 1.2,
                        fontWeight: widget.showTitle
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontStyle: widget.showTitle
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: colors.foreground,
                        decoration: isResolved
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (widget.continuesAfter)
                    Icon(
                      Icons.chevron_right,
                      size: widget.compact ? 12 : 16,
                      color: colors.foreground,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
