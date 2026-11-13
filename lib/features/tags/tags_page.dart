import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/tags_controller.dart';
import '../../domain/entities/tag.dart';
import '../shared/desktop_context_menu.dart';
import '../shared/desktop_dialog_shortcuts.dart';
import 'tag_presentation.dart';

enum _TagContextAction { edit, delete }

/// Gerenciamento compartilhado de tags de eventos e tarefas.
class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = AppScope.of(context).tags;
    return ListenableBuilder(
      listenable: tags,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.tagsTitle)),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('tags-add'),
            onPressed: () => _openEditor(context, tags),
            icon: const Icon(Icons.add),
            label: Text(AppStrings.tagNew),
          ),
          body: tags.isLoading
              ? const Center(child: CircularProgressIndicator())
              : tags.tags.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppStrings.tagsEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: tags.tags.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tag = tags.tags[index];
                    final colors = tagToneColors(
                      tag.tone,
                      Theme.of(context).colorScheme,
                    );
                    return DesktopContextMenuRegion(
                      onOpen: (position) =>
                          _showContextMenu(context, tags, tag, position),
                      child: ListTile(
                        key: Key('tag-${tag.id}'),
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(tag.name),
                        subtitle: Text(tagToneLabel(tag.tone)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: Key('tag-edit-${tag.id}'),
                              tooltip: AppStrings.tagEdit,
                              onPressed: () => _openEditor(context, tags, tag),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              key: Key('tag-delete-${tag.id}'),
                              tooltip: AppStrings.delete,
                              onPressed: () => _delete(context, tags, tag),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _showContextMenu(
    BuildContext context,
    TagsController tags,
    Tag tag,
    Offset globalPosition,
  ) async {
    final action = await showDesktopContextMenu<_TagContextAction>(
      context,
      globalPosition: globalPosition,
      items: [
        PopupMenuItem(
          value: _TagContextAction.edit,
          child: Text(AppStrings.tagEdit),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _TagContextAction.delete,
          child: Text(AppStrings.delete),
        ),
      ],
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _TagContextAction.edit:
        await _openEditor(context, tags, tag);
      case _TagContextAction.delete:
        await _delete(context, tags, tag);
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    TagsController tags, [
    Tag? tag,
  ]) async {
    final result = await showDialog<TagDraft>(
      context: context,
      builder: (_) => _TagDialog(tag: tag),
    );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (tag == null) {
        await tags.create(name: result.name, tone: result.tone);
      } else {
        await tags.update(tag, name: result.name, tone: result.tone);
      }
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.tagSaved)));
    } on FormatException catch (error) {
      final message = switch (error.message) {
        'tag_empty_name' => AppStrings.tagNameEmpty,
        'tag_name_too_long' => AppStrings.tagNameLong,
        'tag_duplicate_name' => AppStrings.tagNameDuplicate,
        _ => AppStrings.errorSave,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    }
  }

  Future<void> _delete(
    BuildContext context,
    TagsController tags,
    Tag tag,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.tagDeleteTitle),
        content: Text(AppStrings.tagDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('tag-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await tags.delete(tag);
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.tagDeleted)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    }
  }
}

final class TagDraft {
  const TagDraft({required this.name, required this.tone});
  final String name;
  final TagTone tone;
}

class _TagDialog extends StatefulWidget {
  const _TagDialog({this.tag});

  final Tag? tag;

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.tag?.name ?? '',
  );
  late TagTone _tone = widget.tag?.tone ?? TagTone.primary;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _toneSwatch({
    required TagTone tone,
    required ColorScheme scheme,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final accent = tagToneColors(tone, scheme).accent;
    final checkColor = accent.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: tagToneLabel(tone),
      child: Tooltip(
        message: tagToneLabel(tone),
        child: InkWell(
          key: Key('tag-tone-${tone.name}'),
          borderRadius: BorderRadius.circular(999),
          focusColor: accent.withValues(alpha: 0.25),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.onSurface : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? Icon(Icons.check, size: 18, color: checkColor)
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    void save() =>
        Navigator.of(context).pop(TagDraft(name: _name.text, tone: _tone));
    return DesktopDialogShortcuts(
      onConfirm: save,
      onCancel: () => Navigator.of(context).pop(),
      child: AlertDialog(
        title: Text(
          widget.tag == null ? AppStrings.tagNew : AppStrings.tagEdit,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('tag-name'),
                controller: _name,
                autofocus: true,
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: AppStrings.tagName,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.tagColor,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final tone in TagTone.values)
                    _toneSwatch(
                      tone: tone,
                      scheme: scheme,
                      selected: _tone == tone,
                      onTap: () => setState(() => _tone = tone),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            key: const Key('tag-save'),
            onPressed: save,
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
