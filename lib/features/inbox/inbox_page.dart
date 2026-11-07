import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/planner_controller.dart';
import '../../core/date_formatting.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/tag.dart';
import '../planner/widgets/post_it_navigation.dart';
import '../planner/widgets/post_it_presentation.dart';
import '../planner/widgets/post_it_tile.dart';
import '../shared/empty_state.dart';
import '../tags/tag_presentation.dart';
import '../tags/tags_page.dart';

enum _InboxFilter { all, active, done, cancelled, undated }

enum _InboxSort { date, updated, title }

enum _InboxMenuAction { openInAgenda, done, reopen, cancel }

/// Repositório central de post-its, incluindo os sem data.
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _searchController = TextEditingController();

  _InboxFilter _filter = _InboxFilter.all;
  _InboxSort _sort = _InboxSort.date;
  String _query = '';
  final Set<String> _selectedTagIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostIt> _visiblePostIts(
    PlannerController planner,
    Set<String> selectedTagIds,
  ) {
    final query = _query.trim().toLowerCase();
    final items = planner.postIts.where((postIt) {
      final matchesFilter = switch (_filter) {
        _InboxFilter.all => true,
        _InboxFilter.active => postIt.status == PostItStatus.active,
        _InboxFilter.done => postIt.status == PostItStatus.done,
        _InboxFilter.cancelled => postIt.status == PostItStatus.cancelled,
        _InboxFilter.undated => postIt.startDate == null,
      };
      if (!matchesFilter) return false;
      if (selectedTagIds.isNotEmpty &&
          !postIt.tagIds.any(selectedTagIds.contains)) {
        return false;
      }
      if (query.isEmpty) return true;
      return postIt.title.toLowerCase().contains(query) ||
          (postIt.details?.toLowerCase().contains(query) ?? false) ||
          (postIt.noteExcerpt?.toLowerCase().contains(query) ?? false);
    }).toList();

    items.sort((a, b) {
      switch (_sort) {
        case _InboxSort.date:
          final aDate = a.startDate;
          final bDate = b.startDate;
          if (aDate == null && bDate == null) {
            return a.sortOrder.compareTo(b.sortOrder);
          }
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          final byDate = aDate.compareTo(bDate);
          if (byDate != 0) return byDate;
          return a.sortOrder.compareTo(b.sortOrder);
        case _InboxSort.updated:
          return b.updatedAt.compareTo(a.updatedAt);
        case _InboxSort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });
    return items;
  }

  Future<void> _setStatus(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
    PostItStatus status,
  ) async {
    try {
      await planner.setPostItStatus(postIt, status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.statusUpdatedMessage)));
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    }
  }

  void _openDetails(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
  ) {
    openPostItDetailsById(context, postItId: postIt.id, goToAgenda: false);
  }

  Future<void> _openTags() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TagsPage()));
    if (!mounted) return;
    setState(() {
      final available = AppScope.of(context).tags.byIdMap.keys.toSet();
      _selectedTagIds.removeWhere((id) => !available.contains(id));
    });
  }

  Future<void> _openTagSelector(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
  ) async {
    final available = AppScope.of(context).tags.tags;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tagCreateFirst),
          action: SnackBarAction(
            label: AppStrings.tagNew,
            onPressed: _openTags,
          ),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) =>
          _TagSelectorSheet(postIt: postIt, tags: available),
    );
    if (selected == null || !context.mounted) return;
    try {
      await planner.setPostItTags(postIt, selected);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.tagSaved)));
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.errorSave)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final planner = AppScope.of(context).planner;
    final tags = AppScope.of(context).tags;

    return ListenableBuilder(
      listenable: Listenable.merge([planner, tags]),
      builder: (context, _) {
        if (planner.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final availableTagIds = tags.byIdMap.keys.toSet();
        final selectedTagIds = _selectedTagIds.intersection(availableTagIds);
        final items = _visiblePostIts(planner, selectedTagIds);
        final shortHeight = MediaQuery.sizeOf(context).height < 520;
        final hasQuery = _query.trim().isNotEmpty;
        final hasTagFilter = selectedTagIds.isNotEmpty;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, shortHeight ? 4 : 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.tagFilter,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('inbox-manage-tags'),
                    onPressed: _openTags,
                    icon: Icon(
                      tags.tags.isEmpty ? Icons.add : Icons.sell_outlined,
                      size: 18,
                    ),
                    label: Text(
                      tags.tags.isEmpty
                          ? AppStrings.tagNew
                          : AppStrings.tagManage,
                    ),
                  ),
                ],
              ),
              if (tags.tags.isEmpty)
                Text(
                  AppStrings.tagFilterEmpty,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final tag in tags.tags) ...[
                        TagChip(
                          key: Key('inbox-tag-filter-${tag.id}'),
                          tag: tag,
                          selected: selectedTagIds.contains(tag.id),
                          onTap: () => setState(() {
                            if (!_selectedTagIds.remove(tag.id)) {
                              _selectedTagIds.add(tag.id);
                            }
                          }),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (hasTagFilter)
                        ActionChip(
                          key: const Key('inbox-tag-clear'),
                          avatar: const Icon(Icons.clear, size: 16),
                          label: Text(AppStrings.tagFilterClear),
                          onPressed: () => setState(_selectedTagIds.clear),
                        ),
                    ],
                  ),
                ),
              SizedBox(height: shortHeight ? 6 : 10),
              TextField(
                key: Key('inbox-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: Icon(Icons.clear),
                        ),
                  labelText: AppStrings.searchHint,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              SizedBox(height: shortHeight ? 6 : 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in _InboxFilter.values) ...[
                      _filterChip(filter, switch (filter) {
                        _InboxFilter.all => AppStrings.allFilter,
                        _InboxFilter.active => AppStrings.active,
                        _InboxFilter.done => AppStrings.done,
                        _InboxFilter.cancelled => AppStrings.cancelled,
                        _InboxFilter.undated => AppStrings.undated,
                      }),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              SizedBox(height: shortHeight ? 2 : 4),
              Row(
                children: [
                  Text(
                    '${items.length} ${AppStrings.itemsCount}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Spacer(),
                  DropdownButton<_InboxSort>(
                    value: _sort,
                    underline: SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: _InboxSort.date,
                        child: Text(AppStrings.sortDate),
                      ),
                      DropdownMenuItem(
                        value: _InboxSort.updated,
                        child: Text(AppStrings.sortUpdated),
                      ),
                      DropdownMenuItem(
                        value: _InboxSort.title,
                        child: Text(AppStrings.sortTitle),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _sort = value);
                    },
                  ),
                ],
              ),
              Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                        icon: hasQuery
                            ? Icons.search_off
                            : hasTagFilter
                            ? Icons.sell_outlined
                            : Icons.inbox_outlined,
                        title: hasQuery
                            ? AppStrings.noResults
                            : hasTagFilter
                            ? AppStrings.tagFilterNoMatches
                            : AppStrings.emptyInbox,
                        message: hasQuery
                            ? AppStrings.noResultsBody
                            : hasTagFilter
                            ? AppStrings.tagFilterNoMatchesBody
                            : AppStrings.inboxPlaceholderBody,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final postIt = items[index];
                          return _InboxRow(
                            postIt: postIt,
                            planner: planner,
                            onTap: () => _openDetails(context, planner, postIt),
                            onLongPress: () =>
                                _openTagSelector(context, planner, postIt),
                            onStatus: (status) =>
                                _setStatus(context, planner, postIt, status),
                            onOpenAgenda: () => openPostItDetailsById(
                              context,
                              postItId: postIt.id,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(_InboxFilter filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.postIt,
    required this.planner,
    required this.onTap,
    required this.onLongPress,
    required this.onStatus,
    required this.onOpenAgenda,
  });

  final PostIt postIt;
  final PlannerController planner;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<PostItStatus> onStatus;
  final VoidCallback onOpenAgenda;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPostponed = planner.isPostponed(postIt);
    final tagsById = AppScope.of(context).tags.byIdMap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: PostItTile(
                  key: Key('inbox-postit-${postIt.id}'),
                  postIt: postIt,
                  compact: false,
                  isPostponed: isPostponed,
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              ),
            ),
            PopupMenuButton<_InboxMenuAction>(
              key: Key('inbox-menu-${postIt.id}'),
              tooltip: AppStrings.statusMenu,
              onSelected: (action) {
                switch (action) {
                  case _InboxMenuAction.openInAgenda:
                    onOpenAgenda();
                  case _InboxMenuAction.done:
                    onStatus(PostItStatus.done);
                  case _InboxMenuAction.reopen:
                    onStatus(PostItStatus.active);
                  case _InboxMenuAction.cancel:
                    onStatus(PostItStatus.cancelled);
                }
              },
              itemBuilder: (context) => [
                if (postIt.startDate != null)
                  PopupMenuItem(
                    value: _InboxMenuAction.openInAgenda,
                    child: Text(AppStrings.openInAgenda),
                  ),
                if (postIt.status == PostItStatus.active)
                  PopupMenuItem(
                    value: _InboxMenuAction.done,
                    child: Text(AppStrings.statusDoneAction),
                  )
                else
                  PopupMenuItem(
                    value: _InboxMenuAction.reopen,
                    child: Text(AppStrings.statusReopenAction),
                  ),
                if (postIt.status != PostItStatus.cancelled)
                  PopupMenuItem(
                    value: _InboxMenuAction.cancel,
                    child: Text(AppStrings.statusCancelAction),
                  ),
              ],
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, top: 2),
          child: Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                postItDateLabel(postIt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '· ${postItTypeLabel(postIt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (postIt.isRecurring && postIt.status == PostItStatus.active)
                Text(
                  isPostponed && postIt.startDate != null
                      ? '· ${AppStrings.postponedUntil} '
                            '${DateFormats.shortDate(postIt.startDate!)}'
                      : '· ${AppStrings.advancesDaily}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        if (postIt.tagIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final tagId in postIt.tagIds)
                  if (tagsById[tagId] != null) TagChip(tag: tagsById[tagId]!),
              ],
            ),
          ),
      ],
    );
  }
}

class _TagSelectorSheet extends StatefulWidget {
  const _TagSelectorSheet({required this.postIt, required this.tags});

  final PostIt postIt;
  final List<Tag> tags;

  @override
  State<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<_TagSelectorSheet> {
  late final Set<String> _selected = {
    for (final tag in widget.tags)
      if (widget.postIt.tagIds.contains(tag.id)) tag.id,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.tagSelectTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.postIt.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.tagSelectHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  key: const Key('inbox-tag-selector'),
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in widget.tags)
                      TagChip(
                        key: Key('inbox-tag-select-${tag.id}'),
                        tag: tag,
                        selected: _selected.contains(tag.id),
                        onTap: () => setState(() {
                          if (!_selected.remove(tag.id)) {
                            _selected.add(tag.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('inbox-tag-save'),
                  onPressed: () => Navigator.of(context).pop([
                    for (final tag in widget.tags)
                      if (_selected.contains(tag.id)) tag.id,
                  ]),
                  child: Text(AppStrings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
