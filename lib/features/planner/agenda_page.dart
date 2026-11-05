import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/app_settings_controller.dart';
import '../../app/controllers/planner_controller.dart';
import '../../core/date_only.dart';
import '../../domain/calendar/calendar_period.dart';
import '../../domain/entities/post_it.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_labels.dart';
import 'widgets/calendar_toolbar.dart';
import 'widgets/day_details_sheet.dart';
import 'widgets/hidden_events_sheet.dart';
import 'widgets/post_it_editor_sheet.dart';
import 'widgets/post_it_drag_data.dart';
import 'widgets/post_it_navigation.dart';

/// Agenda visual por período, com post-its e eventos multi-dia contínuos.
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  int _pageTurnDirection = 1;
  _GridMotion _gridMotion = _GridMotion.page;
  bool _eventDragActive = false;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final planner = app.planner;
    final settings = app.settings;

    return ListenableBuilder(
      listenable: Listenable.merge([planner, app.navigation, settings]),
      builder: (context, _) => _buildContent(context, planner, settings),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PlannerController planner,
    AppSettingsController settings,
  ) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.orientationOf(context);

    if (planner.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final mode = planner.modeFor(orientation);
    final period = CalendarPeriod.compute(
      selectedDate: planner.selectedDate,
      mode: mode,
    );

    final size = MediaQuery.sizeOf(context);
    final compactWidth = size.width < 600;
    final shortHeight = size.height < 520;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        shortHeight ? 8 : 16,
        shortHeight ? 4 : 8,
        shortHeight ? 8 : 16,
        shortHeight ? 12 : (compactWidth ? 12 : 72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarToolbar(
            periodLabel: calendarPeriodLabel(period),
            mode: mode,
            canDecreaseMode: planner.canDecreaseMode(orientation),
            canIncreaseMode: planner.canIncreaseMode(orientation),
            onPreviousPeriod: () =>
                _turnPage(-1, () => planner.previousPeriod(mode)),
            onNextPeriod: () => _turnPage(1, () => planner.nextPeriod(mode)),
            onToday: () => _turnPage(1, planner.goToToday),
            onDecreaseMode: () => _turnPage(
              -1,
              () => planner.cycleMode(-1, orientation),
              morph: true,
            ),
            onIncreaseMode: () => _turnPage(
              1,
              () => planner.cycleMode(1, orientation),
              morph: true,
            ),
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
          SizedBox(height: shortHeight ? 4 : 8),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    key: const Key('calendar-swipe-area'),
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: (details) {
                      final dx = details.velocity.pixelsPerSecond.dx;
                      if (dx.abs() < 220) return;
                      if (dx < 0) {
                        _turnPage(1, () => planner.nextPeriod(mode));
                      } else {
                        _turnPage(-1, () => planner.previousPeriod(mode));
                      }
                    },
                    onVerticalDragEnd: (details) {
                      final dy = details.velocity.pixelsPerSecond.dy;
                      if (dy.abs() < 220) return;
                      final increase = dy < 0;
                      if (increase && !planner.canIncreaseMode(orientation)) {
                        return;
                      }
                      if (!increase && !planner.canDecreaseMode(orientation)) {
                        return;
                      }
                      _turnPage(
                        increase ? 1 : -1,
                        () => planner.cycleMode(increase ? 1 : -1, orientation),
                        morph: true,
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: settings.animationsEnabled
                          ? Duration(
                              milliseconds: _gridMotion == _GridMotion.page
                                  ? 520
                                  : 360,
                            )
                          : Duration.zero,
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      layoutBuilder: (current, previous) => Stack(
                        fit: StackFit.expand,
                        children: [...previous, ?current],
                      ),
                      transitionBuilder: (child, animation) =>
                          _gridMotion == _GridMotion.page
                          ? _pageTurnTransition(
                              child,
                              animation,
                              settings.animationsEnabled,
                            )
                          : _morphTransition(
                              child,
                              animation,
                              settings.animationsEnabled,
                            ),
                      child: RepaintBoundary(
                        key: ValueKey(
                          'calendar-grid-${mode.name}-'
                          '${period.start.toIso8601String()}-'
                          '${period.end.toIso8601String()}',
                        ),
                        child: CalendarGrid(
                          period: period,
                          focusedPostItId: AppScope.of(context)
                              .navigation
                              .focusedPostItId,
                          postIts: planner.postIts,
                          today: planner.today,
                          selectedDate: planner.selectedDate,
                          onDaySelected: planner.selectDate,
                          onPostItTap: (postIt) =>
                              _openDetails(context, planner, postIt),
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
                          onQuickCreateTask: (date) => _openQuickCreate(
                            context,
                            planner,
                            date,
                            PostItType.task,
                          ),
                          onQuickCreateEvent: (date) => _openQuickCreate(
                            context,
                            planner,
                            date,
                            PostItType.event,
                          ),
                          onEventDragActive: (active) {
                            if (!mounted || _eventDragActive == active) return;
                            setState(() => _eventDragActive = active);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (_eventDragActive) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 56,
                    child: _EventWeekDropZone(
                      key: const Key('event-week-prev'),
                      icon: Icons.chevron_left,
                      label: AppStrings.previousPeriod,
                      onAccept: (postIt) =>
                          _moveEventByWeek(context, planner, postIt, -7),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 56,
                    child: _EventWeekDropZone(
                      key: const Key('event-week-next'),
                      icon: Icons.chevron_right,
                      label: AppStrings.nextPeriod,
                      onAccept: (postIt) =>
                          _moveEventByWeek(context, planner, postIt, 7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: shortHeight ? 2 : 8),
          if (settings.showCalendarHints && !shortHeight)
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.calendarHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _undatedChip(theme, planner),
              ],
            )
          else if (!shortHeight)
            Align(
              alignment: Alignment.centerRight,
              child: _undatedChip(theme, planner),
            ),
        ],
      ),
    );
  }

  Future<void> _moveEventByWeek(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
    int days,
  ) async {
    final start = postIt.startDate;
    if (start == null) return;
    final target = start.addDays(days);
    try {
      await planner.movePostIt(postIt, target);
      await planner.selectDate(target);
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.errorMove)));
    }
  }

  Widget _undatedChip(ThemeData theme, PlannerController planner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        '${AppStrings.undated}: ${planner.undatedPostIts.length}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _turnPage(int direction, VoidCallback action, {bool morph = false}) {
    setState(() {
      _pageTurnDirection = direction;
      _gridMotion = morph ? _GridMotion.morph : _GridMotion.page;
    });
    action();
  }

  Widget _morphTransition(
    Widget child,
    Animation<double> animation,
    bool animationsEnabled,
  ) {
    if (!animationsEnabled) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _pageTurnTransition(
    Widget child,
    Animation<double> animation,
    bool animationsEnabled,
  ) {
    if (!animationsEnabled) return child;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = Curves.easeInOutCubic.transform(animation.value);
        final angle = (1 - value) * 0.8 * _pageTurnDirection;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(angle);
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform(
            alignment: _pageTurnDirection >= 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            transform: transform,
            child: child,
          ),
        );
      },
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  void _openQuickCreate(
    BuildContext context,
    PlannerController planner,
    DateOnly date,
    PostItType type,
  ) {
    planner.selectDate(date);
    showPostItEditorSheet(
      context,
      controller: planner,
      initialDate: date,
      initialType: type,
    );
  }

  void _openDetails(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
  ) {
    openPostItDetailsById(context, postItId: postIt.id, goToAgenda: false);
  }
}

enum _GridMotion { page, morph }

class _EventWeekDropZone extends StatelessWidget {
  const _EventWeekDropZone({
    super.key,
    required this.icon,
    required this.label,
    required this.onAccept,
  });

  final IconData icon;
  final String label;
  final ValueChanged<PostIt> onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<PostItDragData>(
      onWillAcceptWithDetails: (details) => details.data.postIt.isEvent,
      onAcceptWithDetails: (details) => onAccept(details.data.postIt),
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;
        return Tooltip(
          message: label,
          child: Material(
            color: theme.colorScheme.primaryContainer.withValues(
              alpha: active ? 0.72 : 0.34,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
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
}
