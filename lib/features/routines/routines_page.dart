import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/routines_controller.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../domain/entities/routine.dart';
import '../shared/empty_state.dart';
import 'routine_editor_page.dart';

/// Rotinas semanais com conclusão independente por data.
class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  late DateOnly _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedDate = AppScope.of(context).planner.today;
  }

  void _shiftWeek(int delta) {
    setState(() => _selectedDate = _selectedDate.addDays(7 * delta));
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

  @override
  Widget build(BuildContext context) {
    final routines = AppScope.of(context).routines;
    return ListenableBuilder(
      listenable: routines,
      builder: (context, _) {
        if (routines.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final start = _selectedDate.startOfWeek;
        final days = [for (var i = 0; i < 7; i++) start.addDays(i)];
        final selectedRoutines = routines.routinesOn(_selectedDate);
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: AppStrings.previousPeriod,
                    onPressed: () => _shiftWeek(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      DateFormats.dateRangeShort(days.first, days.last),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.nextPeriod,
                    onPressed: () => _shiftWeek(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _selectedDate = AppScope.of(context).planner.today,
                    ),
                    child: Text(AppStrings.today),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = days[index];
                  return ChoiceChip(
                    key: Key('routine-day-${date.toIso8601String()}'),
                    label: Text(
                      '${AppStrings.weekdayShort(date.weekday)} ${date.day}',
                    ),
                    selected: date == _selectedDate,
                    onSelected: (_) => setState(() => _selectedDate = date),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selectedRoutines.isEmpty
                  ? EmptyState(
                      icon: Icons.event_repeat_outlined,
                      title: AppStrings.routineEmptyDay,
                      message: AppStrings.routineEmpty,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: selectedRoutines.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _RoutineCard(
                        routine: selectedRoutines[index],
                        date: _selectedDate,
                        controller: routines,
                        onEdit: () => _openEditor(selectedRoutines[index]),
                        onDelete: () => _delete(selectedRoutines[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.date,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  final Routine routine;
  final DateOnly date;
  final RoutinesController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = routine.items.length;
    final done = routine.completedOn(date);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: Key('routine-${routine.id}'),
        leading: const Icon(Icons.event_repeat_outlined),
        title: Text(
          routine.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          [
            if (routine.details != null) routine.details!,
            AppStrings.routineProgress(done, total),
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          key: Key('routine-menu-${routine.id}'),
          tooltip: AppStrings.actions,
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
            PopupMenuItem(value: 'delete', child: Text(AppStrings.delete)),
          ],
        ),
        children: [
          for (final item in routine.items)
            CheckboxListTile(
              key: Key('routine-item-${item.id}-${date.toIso8601String()}'),
              value: item.isCompletedOn(date),
              onChanged: (_) => controller.toggleCompletion(item, date),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                item.title,
                style: item.isCompletedOn(date)
                    ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              subtitle: item.details == null ? null : Text(item.details!),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
