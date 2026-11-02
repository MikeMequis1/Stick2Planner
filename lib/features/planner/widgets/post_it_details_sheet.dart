import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';

/// Folha somente leitura com os dados completos de um post-it.
///
/// A edição chega na Etapa 3; aqui o objetivo é consultar o conteúdo,
/// inclusive eventos multi-dia e trechos de nota.
Future<void> showPostItDetailsSheet(
  BuildContext context,
  PostIt postIt,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final symbol = postItSymbol(postIt);

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      postItIcon(postIt),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        postIt.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        symbol.isEmpty
                            ? postItTypeLabel(postIt)
                            : '$symbol ${postItTypeLabel(postIt)}',
                      ),
                    ),
                    Chip(
                      label: Text(
                        postItStatusLabel(postIt.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: postItDateLabel(postIt),
                ),
                if (postIt.details != null &&
                    postIt.details!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.detailsSection,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    postIt.details!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noDetails,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (postIt.noteExcerpt != null &&
                    postIt.noteExcerpt!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noteExcerptTitle,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      postIt.noteExcerpt!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                if (postIt.noteId != null) ...[
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.note_alt_outlined,
                    text: '${AppStrings.linkedNoteTitle}: ${postIt.noteId}',
                  ),
                ],
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text(AppStrings.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
