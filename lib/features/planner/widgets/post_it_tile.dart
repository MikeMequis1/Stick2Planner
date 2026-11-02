import 'package:flutter/material.dart';

import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Cartão compacto de um post-it dentro de uma célula de dia.
class PostItTile extends StatelessWidget {
  const PostItTile({
    super.key,
    required this.postIt,
    required this.compact,
    this.onTap,
  });

  final PostIt postIt;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = postItColors(postIt, theme.colorScheme);
    final isResolved = postIt.status != PostItStatus.active;

    return Semantics(
      button: onTap != null,
      label: postItSemanticLabel(postIt),
      excludeSemantics: true,
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 8,
              vertical: compact ? 1 : 6,
            ),
            child: Row(
              children: [
                Icon(
                  postItIcon(postIt),
                  size: compact ? 12 : 16,
                  color: colors.foreground,
                ),
                SizedBox(width: compact ? 3 : 6),
                Expanded(
                  child: Text(
                    postIt.title,
                    maxLines: compact ? 1 : 2,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
