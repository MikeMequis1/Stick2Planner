import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_strings.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../domain/entities/post_it.dart';
import '../../shared/desktop_context_menu.dart';
import 'post_it_editor_sheet.dart';
import 'post_it_navigation.dart';

enum PostItContextAction { open, edit, complete, reopen, cancel, delete }

/// Menu de contexto de um post-it/evento no desktop.
Future<void> showPostItContextMenuAt(
  BuildContext context,
  PostIt postIt, {
  required Offset globalPosition,
}) async {
  final planner = AppScope.of(context).planner;
  final current = planner.postItById(postIt.id) ?? postIt;
  final action = await showDesktopContextMenu<PostItContextAction>(
    context,
    globalPosition: globalPosition,
    items: _postItMenuItems(current),
  );
  if (action == null || !context.mounted) return;
  await _handlePostItAction(context, planner, current, action);
}

List<PopupMenuEntry<PostItContextAction>> _postItMenuItems(PostIt postIt) {
  return [
    PopupMenuItem(
      value: PostItContextAction.open,
      key: const Key('postit-menu-open'),
      child: _MenuLabel(
        icon: Icons.visibility_outlined,
        label: AppStrings.showPostItDetails,
      ),
    ),
    PopupMenuItem(
      value: PostItContextAction.edit,
      key: const Key('postit-menu-edit'),
      child: _MenuLabel(icon: Icons.edit_outlined, label: AppStrings.edit),
    ),
    const PopupMenuDivider(),
    if (postIt.status == PostItStatus.active)
      PopupMenuItem(
        value: PostItContextAction.complete,
        key: const Key('postit-menu-complete'),
        child: _MenuLabel(
          icon: Icons.check_circle_outline,
          label: AppStrings.statusDoneAction,
        ),
      )
    else
      PopupMenuItem(
        value: PostItContextAction.reopen,
        key: const Key('postit-menu-reopen'),
        child: _MenuLabel(
          icon: Icons.undo,
          label: AppStrings.statusReopenAction,
        ),
      ),
    if (postIt.status != PostItStatus.cancelled)
      PopupMenuItem(
        value: PostItContextAction.cancel,
        key: const Key('postit-menu-cancel'),
        child: _MenuLabel(
          icon: Icons.cancel_outlined,
          label: AppStrings.statusCancelAction,
        ),
      ),
    const PopupMenuDivider(),
    PopupMenuItem(
      value: PostItContextAction.delete,
      key: const Key('postit-menu-delete'),
      child: _MenuLabel(icon: Icons.delete_outline, label: AppStrings.delete),
    ),
  ];
}

Future<void> _handlePostItAction(
  BuildContext context,
  PlannerController planner,
  PostIt postIt,
  PostItContextAction action,
) async {
  switch (action) {
    case PostItContextAction.open:
      openPostItDetailsById(context, postItId: postIt.id, goToAgenda: false);
    case PostItContextAction.edit:
      await showPostItEditorSheet(
        context,
        controller: planner,
        initialDate: postIt.startDate ?? planner.selectedDate,
        existing: postIt,
      );
    case PostItContextAction.complete:
      await _setStatus(context, planner, postIt, PostItStatus.done);
    case PostItContextAction.reopen:
      await _setStatus(context, planner, postIt, PostItStatus.active);
    case PostItContextAction.cancel:
      await _setStatus(context, planner, postIt, PostItStatus.cancelled);
    case PostItContextAction.delete:
      await _delete(context, planner, postIt);
  }
}

Future<void> _setStatus(
  BuildContext context,
  PlannerController planner,
  PostIt postIt,
  PostItStatus status,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await planner.setPostItStatus(postIt, status);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppStrings.statusUpdatedMessage)),
    );
  } on Object {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
  }
}

Future<void> _delete(
  BuildContext context,
  PlannerController planner,
  PostIt postIt,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppStrings.deleting),
      content: Text(AppStrings.deleteExplanation),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const Key('context-delete-confirm'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(AppStrings.confirmDelete),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await planner.deletePostIt(postIt);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(AppStrings.deletedMessage),
        action: SnackBarAction(
          label: AppStrings.undo,
          onPressed: () async {
            try {
              await planner.restorePostIt(postIt);
            } on Object {
              // Best-effort, como no fluxo da folha de detalhes.
            }
          },
        ),
      ),
    );
  } on Object {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorDelete)));
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    );
  }
}
