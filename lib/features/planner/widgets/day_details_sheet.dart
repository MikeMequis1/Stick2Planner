import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/post_it.dart';
import '../../shared/adaptive_modal.dart';
import '../../shared/desktop_dialog_shortcuts.dart';
import '../../shared/empty_state.dart';
import 'post_it_tile.dart';

/// Lista completa de um dia, incluindo itens que não couberam na célula.
Future<void> showDayDetailsSheet(
  BuildContext context, {
  required DateOnly date,
  required List<PostIt> postIts,
  required ValueChanged<PostIt> onPostItSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: adaptiveSheetConstraints(context),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final height = MediaQuery.sizeOf(sheetContext).height * 0.6;

      return DesktopDialogShortcuts(
        onCancel: () => Navigator.of(sheetContext).pop(),
        child: SafeArea(
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormats.fullDate(date),
                        style: theme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${postIts.length} ${AppStrings.postItsOnDay.toLowerCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: postIts.isEmpty
                      ? EmptyState(
                          icon: Icons.event_available_outlined,
                          title: AppStrings.emptyDay,
                          message: AppStrings.calendarHint,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(16),
                          itemCount: postIts.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final postIt = postIts[index];
                            return SizedBox(
                              height: 52,
                              child: PostItTile(
                                postIt: postIt,
                                compact: false,
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  onPostItSelected(postIt);
                                },
                              ),
                            );
                          },
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
