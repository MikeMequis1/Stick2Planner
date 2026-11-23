import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../core/date_only.dart';
import '../../../domain/entities/post_it.dart';
import '../../../domain/usecases/find_post_it_time_conflicts.dart';
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
      final conflicts = const FindPostItTimeConflicts().forDay(postIts, date);
      final conflictIds = {
        for (final conflict in conflicts)
          for (final postIt in conflict.postIts) postIt.id,
      };

      return DesktopDialogShortcuts(
        onCancel: () => Navigator.of(sheetContext).pop(),
        child: SafeArea(
          child: SizedBox(
            key: const Key('day-details-sheet'),
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
                if (conflicts.isNotEmpty)
                  _TimeConflictBanner(conflicts: conflicts),
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
                            final hasConflict = conflictIds.contains(postIt.id);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 60,
                                  child: PostItTile(
                                    postIt: postIt,
                                    compact: false,
                                    onTap: () {
                                      Navigator.of(sheetContext).pop();
                                      onPostItSelected(postIt);
                                    },
                                  ),
                                ),
                                if (hasConflict)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      top: 4,
                                    ),
                                    child: Row(
                                      key: Key('time-conflict-${postIt.id}'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 15,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppStrings.timeConflictBadge,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                        ),
                                      ],
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
        ),
      );
    },
  );
}

class _TimeConflictBanner extends StatelessWidget {
  const _TimeConflictBanner({required this.conflicts});

  final List<PostItTimeConflict> conflicts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        key: const Key('day-time-conflict-banner'),
        margin: EdgeInsets.zero,
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.timeConflictTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final conflict in conflicts)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${DateFormats.clockTime(conflict.timeMinutes)} — '
                    '${conflict.postIts.map((postIt) => postIt.title).join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
