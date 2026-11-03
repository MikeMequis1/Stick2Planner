import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/planner_controller.dart';
import '../../domain/calendar/calendar_period.dart';
import '../../domain/entities/post_it.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_labels.dart';
import 'widgets/calendar_toolbar.dart';
import 'widgets/day_details_sheet.dart';
import 'widgets/hidden_events_sheet.dart';
import 'widgets/post_it_details_sheet.dart';
import 'widgets/post_it_editor_sheet.dart';

/// Agenda visual por período, com post-its e eventos multi-dia contínuos.
class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = AppScope.of(context).planner;

    return ListenableBuilder(
      listenable: planner,
      builder: (context, _) => _buildContent(context, planner),
    );
  }

  Widget _buildContent(BuildContext context, PlannerController planner) {    final theme = Theme.of(context);
    final orientation = MediaQuery.orientationOf(context);

    if (planner.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final mode = planner.modeFor(orientation);
    final period = CalendarPeriod.compute(
      selectedDate: planner.selectedDate,
      mode: mode,
    );

    final compactWidth = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, compactWidth ? 12 : 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarToolbar(
            periodLabel: calendarPeriodLabel(period),
            mode: mode,
            canDecreaseMode: planner.canDecreaseMode(orientation),
            canIncreaseMode: planner.canIncreaseMode(orientation),
            onPreviousPeriod: () => planner.previousPeriod(mode),
            onNextPeriod: () => planner.nextPeriod(mode),
            onToday: planner.goToToday,
            onDecreaseMode: () => planner.cycleMode(-1, orientation),
            onIncreaseMode: () => planner.cycleMode(1, orientation),
          ),
          if (planner.error != null) ...[
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  AppStrings.loadError,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: CalendarGrid(
              period: period,
              postIts: planner.postIts,
              today: planner.today,
              selectedDate: planner.selectedDate,
              onDaySelected: planner.selectDate,
              onPostItTap: (postIt) => _openDetails(context, planner, postIt),
              onShowDay: (date) => showDayDetailsSheet(
                context,
                date: date,
                postIts: planner.postItsOn(date),
                onPostItSelected: (postIt) =>
                    _openDetails(context, planner, postIt),
              ),
              onMovePostIt: (postIt, date) => _runGuarded(
                context,
                () => planner.movePostIt(postIt, date),
                AppStrings.errorMove,
              ),
              onReorderTo: (postIt, date, index) => _runGuarded(
                context,
                () => planner.movePostIt(
                  postIt,
                  date,
                  targetIndex: index,
                ),
                AppStrings.errorMove,
              ),
              onResizeEvent: (postIt, start, end) => _runGuarded(
                context,
                () => planner.resizeEvent(
                  postIt,
                  startDate: start,
                  endDate: end,
                ),
                AppStrings.errorResize,
              ),
              onShowHiddenEvents: (events) => showHiddenEventsSheet(
                context,
                events: events,
                onPostItSelected: (postIt) =>
                    _openDetails(context, planner, postIt),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.calendarHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.undated}: ${planner.undatedPostIts.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _runGuarded(
    BuildContext context,
    Future<void> Function() operation,
    String errorMessage,
  ) async {
    try {
      await operation();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
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
}
