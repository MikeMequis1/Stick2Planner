import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/planner_controller.dart';
import '../../core/date_formatting.dart';
import '../../domain/entities/post_it.dart';
import '../planner/widgets/post_it_details_sheet.dart';
import '../planner/widgets/post_it_editor_sheet.dart';
import '../planner/widgets/post_it_presentation.dart';
import '../planner/widgets/post_it_tile.dart';
import '../shared/empty_state.dart';

enum _InboxFilter { all, active, done, cancelled, undated }

enum _InboxSort { date, updated, title }

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PostIt> _visiblePostIts(PlannerController planner) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.statusUpdatedMessage)),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errorSave)),
      );
    }
  }

  void _openDetails(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
  ) {
    showPostItDetailsSheet(
      context,
      postIt: postIt,
      planner: planner,
      onEdit: (current) => showPostItEditorSheet(
        context,
        controller: planner,
        initialDate: current.startDate ?? planner.selectedDate,
        existing: current,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = AppScope.of(context).planner;

    return ListenableBuilder(
      listenable: planner,
      builder: (context, _) {
        if (planner.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = _visiblePostIts(planner);
        final compactWidth = MediaQuery.sizeOf(context).width < 600;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, compactWidth ? 12 : 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('inbox-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  labelText: AppStrings.searchHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _filterChip(_InboxFilter.all, AppStrings.allFilter),
                  _filterChip(_InboxFilter.active, AppStrings.active),
                  _filterChip(_InboxFilter.done, AppStrings.done),
                  _filterChip(_InboxFilter.cancelled, AppStrings.cancelled),
                  _filterChip(_InboxFilter.undated, AppStrings.undated),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${items.length} ${AppStrings.itemsCount}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const Spacer(),
                  DropdownButton<_InboxSort>(
                    value: _sort,
                    underline: const SizedBox.shrink(),
                    items: const [
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
              const Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                        icon: Icons.inbox_outlined,
                        title: _query.isNotEmpty
                            ? AppStrings.noResults
                            : AppStrings.emptyInbox,
                        message: AppStrings.inboxPlaceholderBody,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final postIt = items[index];
                          return _InboxRow(
                            postIt: postIt,
                            planner: planner,
                            onTap: () => _openDetails(
                              context,
                              planner,
                              postIt,
                            ),
                            onStatus: (status) => _setStatus(
                              context,
                              planner,
                              postIt,
                              status,
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
    required this.onStatus,
  });

  final PostIt postIt;
  final PlannerController planner;
  final VoidCallback onTap;
  final ValueChanged<PostItStatus> onStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPostponed = planner.isPostponed(postIt);

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
                ),
              ),
            ),
            PopupMenuButton<PostItStatus>(
              key: Key('inbox-menu-${postIt.id}'),
              tooltip: AppStrings.statusMenu,
              onSelected: onStatus,
              itemBuilder: (context) => [
                if (postIt.status == PostItStatus.active)
                  const PopupMenuItem(
                    value: PostItStatus.done,
                    child: Text(AppStrings.statusDoneAction),
                  )
                else
                  const PopupMenuItem(
                    value: PostItStatus.active,
                    child: Text(AppStrings.statusReopenAction),
                  ),
                if (postIt.status != PostItStatus.cancelled)
                  const PopupMenuItem(
                    value: PostItStatus.cancelled,
                    child: Text(AppStrings.statusCancelAction),
                  ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 2),
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
              if (postIt.isRecurring &&
                  postIt.status == PostItStatus.active)
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
      ],
    );
  }
}
