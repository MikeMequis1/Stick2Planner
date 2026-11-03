import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../domain/entities/post_it.dart';
import 'post_it_presentation.dart';
import 'post_it_tile.dart';

/// Lista os eventos que não couberam nas faixas visíveis da semana.
Future<void> showHiddenEventsSheet(
  BuildContext context, {
  required List<PostIt> events,
  required ValueChanged<PostIt> onPostItSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.hiddenEventsTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.hiddenEventsHelp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 52,
                          child: PostItTile(
                            postIt: event,
                            compact: false,
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              onPostItSelected(event);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text(
                            '${postItDateLabel(event)} · '
                            '${postItTypeLabel(event)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
