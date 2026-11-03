import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Cartão compacto de um post-it dentro de uma célula de dia.
class PostItTile extends StatelessWidget {
  const PostItTile({
    super.key,
    required this.postIt,
    required this.compact,
    this.onTap,
    this.isPostponed = false,
  });

  final PostIt postIt;
  final bool compact;
  final VoidCallback? onTap;

  /// TO-DO recorrente adiado manualmente (usa ícone/rótulo, não só cor).
  final bool isPostponed;

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
                        maxLines: compact || isPostponed ? 1 : 2,
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
                      if (isPostponed && !compact)
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
                if (isPostponed)
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
    );
  }
}
