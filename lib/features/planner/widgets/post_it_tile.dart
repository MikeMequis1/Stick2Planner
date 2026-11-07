import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Cartão compacto de um post-it dentro de uma célula de dia.
class PostItTile extends StatefulWidget {
  const PostItTile({
    super.key,
    required this.postIt,
    required this.compact,
    this.onTap,
    this.isPostponed = false,
    this.isFocused = false,
  });

  final PostIt postIt;
  final bool compact;
  final VoidCallback? onTap;

  /// TO-DO recorrente adiado manualmente (usa ícone/rótulo, não só cor).
  final bool isPostponed;

  /// Destaque temporário ao chegar pela navegação de outro módulo.
  final bool isFocused;

  @override
  State<PostItTile> createState() => _PostItTileState();
}

class _PostItTileState extends State<PostItTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postIt = widget.postIt;
    final compact = widget.compact;
    final colors = postItColors(postIt, theme.colorScheme);
    final isResolved = postIt.status != PostItStatus.active;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 140);

    return Semantics(
      button: widget.onTap != null,
      label: postItSemanticLabel(postIt),
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : (widget.isFocused ? 1.05 : 1),
        duration: motion,
        curve: Curves.easeOutCubic,
        child: Material(
          color: colors.background,
          elevation: widget.isFocused ? 6 : 0,
          shadowColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: widget.isFocused
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 8,
                vertical: compact ? 2 : 6,
              ),
              child: Row(
                children: [
                  Icon(
                    postItIcon(postIt),
                    size: compact ? 12 : 16,
                    color: colors.foreground,
                  ),
                  SizedBox(width: compact ? 4 : 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postIt.title,
                          maxLines: compact || widget.isPostponed ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 10 : 12.5,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: colors.foreground,
                            decoration: isResolved
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (postIt.timeMinutes != null)
                          Text(
                            DateFormats.clockTime(postIt.timeMinutes!),
                            style: TextStyle(
                              fontSize: compact ? 8 : 9.5,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: colors.foreground,
                            ),
                          ),
                        if (widget.isPostponed && !compact)
                          Text(
                            AppStrings.postponed.toLowerCase(),
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: colors.foreground,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isPostponed)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Tooltip(
                        message: AppStrings.postponed,
                        child: Icon(
                          Icons.schedule,
                          size: compact ? 12 : 16,
                          color: colors.foreground,
                        ),
                      ),
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
