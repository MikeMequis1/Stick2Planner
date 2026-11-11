import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/routines_controller.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../shared/empty_state.dart';
import '../shared/hold_to_delete_button.dart';
import '../shared/reorder_helpers.dart';
import 'routine_editor_page.dart';

/// Rotinas semanais com conclusão independente por data.
///
/// A tela usa a mesma linguagem da Agenda: barra temporal, dias em destaque e
/// cartões coloridos. A data selecionada pode ser trocada por gesto horizontal,
/// sem perder os controles visuais.
class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  DateOnly? _selectedDate;
  int _pageDirection = 1;
  final Set<String> _expandedRoutines = {};

  DateOnly get _date => _selectedDate ?? AppScope.of(context).planner.today;

  void _setDate(DateOnly date, int direction) {
    if (date == _date) return;
    setState(() {
      _pageDirection = direction;
      _selectedDate = date;
    });
  }

  void _shiftDay(int delta) {
    final next = _date.addDays(delta);
    _setDate(next, delta >= 0 ? 1 : -1);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final dx = details.velocity.pixelsPerSecond.dx;
    if (dx.abs() < 220) return;
    _shiftDay(dx < 0 ? 1 : -1);
  }

  Future<void> _openEditor([Routine? routine]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RoutineEditorPage(existing: routine)),
    );
  }

  Future<void> _delete(Routine routine) async {
    final controller = AppScope.of(context).routines;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.routineDeleteTitle),
        content: Text(AppStrings.routineDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await controller.deleteRoutine(routine);
  }

  void _toggleExpanded(Routine routine) {
    setState(() {
      if (!_expandedRoutines.add(routine.id)) {
        _expandedRoutines.remove(routine.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final routines = app.routines;
    final today = app.planner.today;

    return ListenableBuilder(
      listenable: routines,
      builder: (context, _) {
        if (routines.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final date = _selectedDate ?? today;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(context, date, today),
            _buildWeekStrip(context, routines, date, today),
            const SizedBox(height: 4),
            Expanded(
              child: GestureDetector(
                key: const Key('routine-swipe-area'),
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final begin = Offset(0.055 * _pageDirection, 0);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: begin,
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(date.toIso8601String()),
                    child: _buildDayBoard(context, routines, date, today),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, DateOnly date, DateOnly today) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: [
          IconButton(
            key: const Key('routine-previous-day'),
            tooltip: AppStrings.previousPeriod,
            onPressed: () => _shiftDay(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormats.fullDate(date),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  date == today
                      ? AppStrings.today
                      : DateFormats.monthYear(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('routine-next-day'),
            tooltip: AppStrings.nextPeriod,
            onPressed: () => _shiftDay(1),
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(
            key: const Key('routine-today'),
            onPressed: date == today
                ? null
                : () => _setDate(today, date.isAfter(today) ? -1 : 1),
            child: Text(AppStrings.today),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(
    BuildContext context,
    RoutinesController controller,
    DateOnly date,
    DateOnly today,
  ) {
    final start = date.startOfWeek;
    final days = [for (var i = 0; i < 7; i++) start.addDays(i)];
    return SizedBox(
      height: 84,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _WeekDayCell(
                  key: Key('routine-day-${day.toIso8601String()}'),
                  date: day,
                  today: day == today,
                  selected: day == date,
                  total: _dayTotal(controller, day),
                  done: _dayDone(controller, day),
                  onTap: () => _setDate(day, day.isAfter(date) ? 1 : -1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayBoard(
    BuildContext context,
    RoutinesController controller,
    DateOnly date,
    DateOnly today,
  ) {
    final theme = Theme.of(context);
    final dayRoutines = controller.routinesOn(date);
    final total = _dayTotal(controller, date);
    final done = _dayDone(controller, date);

    return ListView(
      key: PageStorageKey<String>('routines-${date.toIso8601String()}'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        Row(
          children: [
            Icon(
              date == today
                  ? Icons.today_outlined
                  : Icons.calendar_today_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.routineDaySummary(done, total),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (date == today)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(AppStrings.today),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.routineSwipeHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        if (dayRoutines.isEmpty)
          EmptyState(
            icon: Icons.event_repeat_outlined,
            title: AppStrings.routineEmptyDay,
            message: AppStrings.routineEmpty,
          )
        else
          for (final routine in dayRoutines)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoutineCard(
                routine: routine,
                date: date,
                controller: controller,
                expanded: _expandedRoutines.contains(routine.id),
                onToggleExpanded: () => _toggleExpanded(routine),
                onEdit: () => _openEditor(routine),
                onDelete: () => _delete(routine),
              ),
            ),
      ],
    );
  }

  int _dayTotal(RoutinesController controller, DateOnly date) => controller
      .routinesOn(date)
      .fold(0, (total, routine) => total + routine.items.length);

  int _dayDone(RoutinesController controller, DateOnly date) => controller
      .routinesOn(date)
      .fold(0, (total, routine) => total + routine.completedOn(date));
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    super.key,
    required this.date,
    required this.today,
    required this.selected,
    required this.total,
    required this.done,
    required this.onTap,
  });

  final DateOnly date;
  final bool today;
  final bool selected;
  final int total;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final complete = total > 0 && done == total;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerLow.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected
              ? scheme.primary
              : (today
                    ? scheme.primary.withValues(alpha: 0.55)
                    : scheme.outlineVariant.withValues(alpha: 0.5)),
          width: selected || today ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.weekdayShort(date.weekday),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? scheme.onPrimaryContainer : null,
                ),
              ),
              const SizedBox(height: 2),
              if (total == 0)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Text(
                  complete ? '✓' : '$done/$total',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: complete
                        ? scheme.primary
                        : (selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant),
                  ),
                ),
              if (today)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.date,
    required this.controller,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  final Routine routine;
  final DateOnly date;
  final RoutinesController controller;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = routine.items.length;
    final done = routine.completedOn(date);
    final progress = total == 0 ? 0.0 : done / total;
    final weekdays = [
      for (var day = 1; day <= 7; day++)
        if (routine.weekdays.contains(day)) AppStrings.weekdayShort(day),
    ].join(', ');
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Material(
      color: scheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: scheme.onSecondaryContainer.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: Key('routine-${routine.id}'),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.onSecondaryContainer.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.event_repeat_outlined,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (weekdays.isNotEmpty) weekdays,
                            if (routine.details != null) routine.details!,
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSecondaryContainer.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: scheme.onSecondaryContainer
                                      .withValues(alpha: 0.18),
                                  color: scheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.routineProgress(done, total),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        key: Key('routine-menu-${routine.id}'),
                        tooltip: AppStrings.actions,
                        iconColor: scheme.onSecondaryContainer,
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(AppStrings.edit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(AppStrings.delete),
                          ),
                        ],
                      ),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: scheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: motion,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        height: 1,
                        color: scheme.onSecondaryContainer.withValues(
                          alpha: 0.18,
                        ),
                      ),
                      if (routine.items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            AppStrings.routineNoItems,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        )
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          proxyDecorator: reorderProxyDecorator,
                          itemCount: routine.items.length,
                          onReorderItem: (oldIndex, newIndex) => controller
                              .reorderItems(routine, oldIndex, newIndex),
                          itemBuilder: (context, index) {
                            final item = routine.items[index];
                            return _RoutineItemRow(
                              key: ValueKey(item.id),
                              item: item,
                              date: date,
                              index: index,
                              controller: controller,
                              routine: routine,
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                        child: Text(
                          AppStrings.dragToReorder,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondaryContainer.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _RoutineItemRow extends StatelessWidget {
  const _RoutineItemRow({
    super.key,
    required this.item,
    required this.date,
    required this.index,
    required this.controller,
    required this.routine,
  });

  final RoutineItem item;
  final DateOnly date;
  final int index;
  final RoutinesController controller;
  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completed = item.isCompletedOn(date);
    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.55),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            key: Key('routine-item-${item.id}-${date.toIso8601String()}'),
            value: completed,
            onChanged: (_) => controller.toggleCompletion(item, date),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: completed
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.details != null)
                    Text(
                      item.details!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ReorderHandle(
            key: Key('routine-item-handle-${item.id}'),
            index: index,
          ),
          HoldToDeleteButton(
            key: Key('routine-item-delete-${item.id}'),
            semanticLabel: AppStrings.holdToDelete,
            onDelete: () => controller.removeItem(routine, item),
          ),
        ],
      ),
    );
  }
}
