import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/app_settings_controller.dart';
import '../../app/controllers/planner_controller.dart';
import '../../core/date_only.dart';
import '../../core/platform_support.dart';
import '../../domain/calendar/agenda_view_mode.dart';
import '../../domain/calendar/calendar_period.dart';
import '../../domain/calendar/event_recurrence.dart';
import '../../domain/entities/post_it.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_labels.dart';
import 'widgets/calendar_toolbar.dart';
import 'widgets/day_details_sheet.dart';
import 'widgets/hidden_events_sheet.dart';
import 'widgets/month_year_picker.dart';
import 'widgets/post_it_editor_sheet.dart';
import 'widgets/post_it_drag_data.dart';
import 'widgets/post_it_navigation.dart';

/// Agenda visual por período, com post-its e eventos multi-dia contínuos.
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage>
    with SingleTickerProviderStateMixin {
  int _pageTurnDirection = 1;
  _GridMotion _gridMotion = _GridMotion.page;
  bool _eventDragActive = false;

  late final AnimationController _settleController;
  late final ValueNotifier<double> _dragOffset;
  Animation<double>? _settleAnimation;
  bool _draggingCarousel = false;
  double _dragDx = 0;
  double _carouselWidth = 0;
  int _settleDirection = 0;
  CalendarPeriod? _previousPeriod;
  CalendarPeriod? _nextPeriod;
  List<PostIt> _previousPostIts = const [];
  List<PostIt> _nextPostIts = const [];

  /// Início da janela de 4 dias. Mantém a grade estável ao selecionar um dia
  /// dentro dela em vez de recomeçar na data tocada.
  DateOnly? _fourDayStart;
  AgendaViewMode? _anchoredMode;

  @override
  void initState() {
    super.initState();
    _settleController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 260),
          )
          ..addListener(_onSettleTick)
          ..addStatusListener(_onSettleStatus);
    _dragOffset = ValueNotifier<double>(0);
  }

  @override
  void dispose() {
    _settleController.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  void _onSettleTick() {
    final animation = _settleAnimation;
    if (animation == null || !mounted) return;
    _dragDx = animation.value;
    _dragOffset.value = animation.value;
  }

  void _onSettleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final direction = _settleDirection;
    final planner = AppScope.of(context).planner;
    final mode = planner.modeFor(MediaQuery.orientationOf(context));
    setState(() {
      _draggingCarousel = false;
      _dragDx = 0;
      _dragOffset.value = 0;
      _settleDirection = 0;
      _previousPeriod = null;
      _nextPeriod = null;
      _previousPostIts = const [];
      _nextPostIts = const [];
      if (direction != 0) _gridMotion = _GridMotion.instant;
    });
    if (direction != 0) {
      _commitCarousel(planner, mode, direction);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _gridMotion != _GridMotion.instant) return;
        setState(() => _gridMotion = _GridMotion.page);
      });
    }
  }

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
    final period = _periodFor(planner, mode);
    final visiblePostIts = expandEventOccurrences(
      planner.postIts,
      from: period.start,
      to: period.end,
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
            onPreviousPeriod: () => _changePeriod(planner, mode, -1),
            onNextPeriod: () => _changePeriod(planner, mode, 1),
            onPeriodLabelTap: () => _pickMonthYear(planner),
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
                    onHorizontalDragStart: (details) =>
                        _beginCarouselDrag(planner, mode, period),
                    onHorizontalDragUpdate: _updateCarouselDrag,
                    onHorizontalDragEnd: (details) =>
                        _endCarouselDrag(planner, mode, details),
                    onHorizontalDragCancel: _cancelCarouselDrag,
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _carouselWidth = constraints.maxWidth;
                        final width = constraints.maxWidth;
                        final previous = _previousPeriod == null
                            ? null
                            : IgnorePointer(
                                child: RepaintBoundary(
                                  child: _buildGrid(
                                    context,
                                    planner,
                                    _previousPeriod!,
                                    _previousPostIts,
                                  ),
                                ),
                              );
                        final next = _nextPeriod == null
                            ? null
                            : IgnorePointer(
                                child: RepaintBoundary(
                                  child: _buildGrid(
                                    context,
                                    planner,
                                    _nextPeriod!,
                                    _nextPostIts,
                                  ),
                                ),
                              );
                        final current = AnimatedSwitcher(
                          duration:
                              settings.animationsEnabled &&
                                  !MediaQuery.disableAnimationsOf(context)
                              ? Duration(
                                  milliseconds: _gridMotion == _GridMotion.page
                                      ? 420
                                      : 360,
                                )
                              : Duration.zero,
                          switchInCurve: Curves.easeInOutCubic,
                          switchOutCurve: Curves.easeInOutCubic,
                          layoutBuilder: (current, previous) => Stack(
                            fit: StackFit.expand,
                            children: [...previous, ?current],
                          ),
                          transitionBuilder: (child, animation) {
                            if (_gridMotion == _GridMotion.instant) {
                              return child;
                            }
                            return _gridMotion == _GridMotion.page
                                ? _carouselTransition(child, animation)
                                : _morphTransition(
                                    child,
                                    animation,
                                    settings.animationsEnabled,
                                  );
                          },
                          child: RepaintBoundary(
                            key: ValueKey(
                              'calendar-grid-${mode.name}-'
                              '${period.start.toIso8601String()}-'
                              '${period.end.toIso8601String()}',
                            ),
                            child: KeyedSubtree(
                              key: const ValueKey('carousel-current-grid'),
                              child: _buildGrid(
                                context,
                                planner,
                                period,
                                visiblePostIts,
                              ),
                            ),
                          ),
                        );
                        return ValueListenableBuilder<double>(
                          valueListenable: _dragOffset,
                          builder: (context, offset, _) => Stack(
                            fit: StackFit.expand,
                            children: [
                              if (previous != null && offset > 0)
                                Positioned.fill(
                                  key: const ValueKey('carousel-previous'),
                                  child: Transform.translate(
                                    offset: Offset(offset - width, 0),
                                    child: previous,
                                  ),
                                ),
                              Positioned.fill(
                                key: const ValueKey('carousel-current'),
                                child: Transform.translate(
                                  key: const ValueKey(
                                    'carousel-current-transform',
                                  ),
                                  offset: Offset(offset, 0),
                                  child: current,
                                ),
                              ),
                              if (next != null && offset < 0)
                                Positioned.fill(
                                  key: const ValueKey('carousel-next'),
                                  child: Transform.translate(
                                    offset: Offset(offset + width, 0),
                                    child: next,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
                    isDesktopTargetPlatform
                        ? AppStrings.calendarHintDesktop
                        : AppStrings.calendarHint,
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

  void _selectDay(
    BuildContext context,
    PlannerController planner,
    DateOnly date,
  ) {
    planner.selectDate(date);
    final items = planner.postItsOn(date);
    if (items.isEmpty) return;
    showDayDetailsSheet(
      context,
      date: date,
      postIts: items,
      onPostItSelected: (postIt) => _openDetails(context, planner, postIt),
    );
  }

  Future<void> _handleMove(
    BuildContext context,
    PlannerController planner,
    PostIt postIt,
    DateOnly target,
  ) async {
    final occurrenceStart = postIt.startDate;
    if (postIt.isRecurringEvent &&
        occurrenceStart != null &&
        !target.isSameDay(occurrenceStart)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          key: const Key('split-series-dialog'),
          title: Text(AppStrings.splitSeriesTitle),
          content: Text(AppStrings.splitSeriesBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              key: const Key('split-series-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppStrings.splitSeriesConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      try {
        final segment = await planner.splitRecurringEvent(postIt, target);
        if (segment == null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.splitSeriesInvalidTarget)),
          );
        }
      } on Object {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppStrings.errorMove)));
      }
      return;
    }
    await _runGuarded(
      context,
      () => planner.movePostIt(postIt, target),
      AppStrings.errorMove,
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

  /// Calcula a janela visível, ancorando os 4 dias fora da data selecionada.
  ///
  /// Ao alternar para 4 dias (ou mudar a orientação), a janela começa na data
  /// selecionada. Selecionar outro dia já visível não desloca a grade.
  CalendarPeriod _periodFor(PlannerController planner, AgendaViewMode mode) {
    if (_anchoredMode != mode) {
      _anchoredMode = mode;
      _fourDayStart = null;
    }

    if (mode != AgendaViewMode.fourDays) {
      return CalendarPeriod.compute(
        selectedDate: planner.selectedDate,
        mode: mode,
      );
    }

    final selected = planner.selectedDate;
    var start = _fourDayStart ?? selected;
    if (selected.isBefore(start) || selected.isAfter(start.addDays(3))) {
      start = selected;
    }
    _fourDayStart = start;
    return CalendarPeriod.fourDays(selectedDate: selected, start: start);
  }

  Widget _buildGrid(
    BuildContext context,
    PlannerController planner,
    CalendarPeriod period,
    List<PostIt> postIts,
  ) {
    return CalendarGrid(
      period: period,
      focusedPostItId: AppScope.of(context).navigation.focusedPostItId,
      postIts: postIts,
      today: planner.today,
      selectedDate: period.selectedDate,
      onDaySelected: (date) => _selectDay(context, planner, date),
      onPostItTap: (postIt) => _openDetails(context, planner, postIt),
      onShowDay: (date) => showDayDetailsSheet(
        context,
        date: date,
        postIts: planner.postItsOn(date),
        onPostItSelected: (postIt) => _openDetails(context, planner, postIt),
      ),
      onMovePostIt: (postIt, date) =>
          _handleMove(context, planner, postIt, date),
      onReorderTo: (postIt, date, index) => _runGuarded(
        context,
        () => planner.movePostIt(postIt, date, targetIndex: index),
        AppStrings.errorMove,
      ),
      onResizeEvent: (postIt, start, end) => _runGuarded(
        context,
        () => planner.resizeEvent(postIt, startDate: start, endDate: end),
        AppStrings.errorResize,
      ),
      onShowHiddenEvents: (events) => showHiddenEventsSheet(
        context,
        events: events,
        onPostItSelected: (postIt) => _openDetails(context, planner, postIt),
      ),
      onQuickCreateTask: (date) =>
          _openQuickCreate(context, planner, date, PostItType.task),
      onQuickCreateEvent: (date) =>
          _openQuickCreate(context, planner, date, PostItType.event),
      onEventDragActive: (active) {
        if (!mounted || _eventDragActive == active) return;
        setState(() => _eventDragActive = active);
      },
    );
  }

  void _beginCarouselDrag(
    PlannerController planner,
    AgendaViewMode mode,
    CalendarPeriod period,
  ) {
    _settleController.stop();
    _settleAnimation = null;
    _draggingCarousel = true;
    _dragDx = 0;
    _dragOffset.value = 0;
    _settleDirection = 0;
    final previous = _neighborPeriod(planner, mode, period, -1);
    final next = _neighborPeriod(planner, mode, period, 1);
    setState(() {
      _previousPeriod = previous;
      _nextPeriod = next;
      _previousPostIts = expandEventOccurrences(
        planner.postIts,
        from: previous.start,
        to: previous.end,
      );
      _nextPostIts = expandEventOccurrences(
        planner.postIts,
        from: next.start,
        to: next.end,
      );
    });
  }

  CalendarPeriod _neighborPeriod(
    PlannerController planner,
    AgendaViewMode mode,
    CalendarPeriod period,
    int direction,
  ) {
    if (mode == AgendaViewMode.fourDays) {
      final start = (_fourDayStart ?? period.start).addDays(4 * direction);
      final selected = planner.selectedDate.addDays(4 * direction);
      return CalendarPeriod.fourDays(selectedDate: selected, start: start);
    }
    final selected = shiftSelectedDate(planner.selectedDate, mode, direction);
    return CalendarPeriod.compute(selectedDate: selected, mode: mode);
  }

  void _updateCarouselDrag(DragUpdateDetails details) {
    if (!_draggingCarousel) return;
    final width = _carouselWidth > 0
        ? _carouselWidth
        : MediaQuery.sizeOf(context).width;
    _dragDx = (_dragDx + details.delta.dx).clamp(-width, width).toDouble();
    _dragOffset.value = _dragDx;
  }

  void _endCarouselDrag(
    PlannerController planner,
    AgendaViewMode mode,
    DragEndDetails details,
  ) {
    if (!_draggingCarousel) return;
    _settleCarousel(
      planner,
      mode,
      velocity: details.velocity.pixelsPerSecond.dx,
    );
  }

  void _cancelCarouselDrag() {
    if (!_draggingCarousel) return;
    _settleCarousel(
      AppScope.of(context).planner,
      AppScope.of(context).planner.modeFor(MediaQuery.orientationOf(context)),
      velocity: 0,
      forceCancel: true,
    );
  }

  void _settleCarousel(
    PlannerController planner,
    AgendaViewMode mode, {
    required double velocity,
    bool forceCancel = false,
  }) {
    final width = _carouselWidth > 0
        ? _carouselWidth
        : MediaQuery.sizeOf(context).width;
    final drag = _dragDx;
    var direction = drag > 0
        ? -1
        : drag < 0
        ? 1
        : 0;
    if (direction == 0 && velocity.abs() > 500) {
      direction = velocity < 0 ? 1 : -1;
    }
    final shouldCommit =
        !forceCancel &&
        (drag.abs() >= width * 0.2 || velocity.abs() > 550) &&
        direction != 0;
    final target = shouldCommit ? (direction > 0 ? -width : width) : 0.0;
    _draggingCarousel = false;
    _settleDirection = shouldCommit ? direction : 0;

    final animate =
        AppScope.of(context).settings.animationsEnabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (!animate) {
      _dragDx = target;
      _dragOffset.value = target;
      _onSettleStatus(AnimationStatus.completed);
      return;
    }
    _settleAnimation = Tween<double>(begin: drag, end: target).animate(
      CurvedAnimation(parent: _settleController, curve: Curves.easeOutCubic),
    );
    _settleController.forward(from: 0);
  }

  void _commitCarousel(
    PlannerController planner,
    AgendaViewMode mode,
    int direction,
  ) {
    if (mode == AgendaViewMode.fourDays) {
      final start = _fourDayStart ?? planner.selectedDate;
      _fourDayStart = start.addDays(4 * direction);
      planner.selectDate(planner.selectedDate.addDays(4 * direction));
      return;
    }
    if (direction > 0) {
      planner.nextPeriod(mode);
    } else {
      planner.previousPeriod(mode);
    }
  }

  Future<void> _pickMonthYear(PlannerController planner) async {
    final selected = planner.selectedDate;
    final picked = await showMonthYearPicker(context, initial: selected);
    if (picked == null || !mounted) return;
    final day = selected.day.clamp(
      1,
      DateOnly.daysInMonth(picked.year, picked.month),
    );
    final target = DateOnly(picked.year, picked.month, day);
    final direction = target.isBefore(selected) ? -1 : 1;
    _turnPage(direction, () => planner.selectDate(target));
  }

  /// Folheia um período inteiro, deslocando a janela de 4 dias se necessário.
  void _changePeriod(
    PlannerController planner,
    AgendaViewMode mode,
    int direction,
  ) {
    if (mode == AgendaViewMode.fourDays) {
      _shiftFourDays(planner, direction);
      return;
    }
    _turnPage(
      direction,
      () => direction > 0
          ? planner.nextPeriod(mode)
          : planner.previousPeriod(mode),
    );
  }

  void _shiftFourDays(PlannerController planner, int direction) {
    final start = _fourDayStart ?? planner.selectedDate;
    setState(() {
      _pageTurnDirection = direction;
      _gridMotion = _GridMotion.page;
      _fourDayStart = start.addDays(4 * direction);
    });
    planner.selectDate(planner.selectedDate.addDays(4 * direction));
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

  Widget _carouselTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = animation.status == AnimationStatus.reverse;
    final direction = outgoing ? -_pageTurnDirection : _pageTurnDirection;
    final slide = Tween<Offset>(
      begin: Offset(0.22 * direction, 0),
      end: Offset.zero,
    ).animate(curved);
    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
          child: child,
        ),
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
    openPostItDetailsById(
      context,
      postItId: postIt.id,
      goToAgenda: false,
      occurrence: postIt,
    );
  }
}

enum _GridMotion { page, morph, instant }

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
