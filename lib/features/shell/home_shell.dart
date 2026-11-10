import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/controllers/app_navigation_controller.dart';
import '../../app/services/sync_coordinator.dart';
import '../inbox/inbox_page.dart';
import '../notes/notes_page.dart';
import '../planner/agenda_page.dart';
import '../planner/widgets/post_it_editor_sheet.dart';
import '../routines/routine_editor_page.dart';
import '../routines/routines_page.dart';
import '../settings/settings_page.dart';

/// Casca de navegação adaptativa.
///
/// Paisagem: trilho único com as seções no topo e Config/Sync no rodapé.
/// Retrato: barra inferior com todas as ações distribuídas igualmente.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  static const _wideBreakpoint = 720.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final scope = AppScope.of(context);
    scope.planner.handleAppResumed().catchError((Object _) {});
    scope.sync.handleAppResumed();
    scope.refreshNotifications();
  }

  static const _pages = <Widget>[
    AgendaPage(),
    InboxPage(),
    NotesPage(),
    RoutinesPage(),
  ];

  void _select(int index) {
    if (index >= AppSection.values.length) return;
    AppScope.of(context).navigation.select(AppSection.values[index]);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
    if (!mounted) return;
    await AppScope.of(context).sync.refreshConfig();
  }

  Future<void> _openSyncSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsPage(focusSync: true),
      ),
    );
    if (!mounted) return;
    await AppScope.of(context).sync.refreshConfig();
  }

  void _openNewPostIt() {
    final planner = AppScope.of(context).planner;
    showPostItEditorSheet(
      context,
      controller: planner,
      initialDate: planner.selectedDate,
    );
  }

  Future<void> _openNewRoutine() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const RoutineEditorPage()));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final useRail = width >= _wideBreakpoint;
    final isCompact = width < 600;
    final isShort = height < 500;
    final app = AppScope.of(context);
    final navigation = app.navigation;
    final sync = app.sync;

    return ListenableBuilder(
      listenable: Listenable.merge([navigation, sync]),
      builder: (context, _) {
        final index = navigation.section.index;
        final destinations = _railDestinations();
        final visual = _syncVisual(sync);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: useRail
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NavigationRail(
                        minWidth: 84,
                        selectedIndex: index,
                        onDestinationSelected: _select,
                        labelType: height < 600
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        trailingAtBottom: true,
                        destinations: destinations,
                        trailing: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: const Key('open-sync-settings'),
                                tooltip: visual.tooltip,
                                onPressed: _openSyncSettings,
                                icon: Icon(visual.icon, color: visual.color),
                              ),
                              IconButton(
                                key: const Key('open-settings'),
                                tooltip: AppStrings.settings,
                                onPressed: _openSettings,
                                icon: const Icon(Icons.settings_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: IndexedStack(index: index, children: _pages),
                      ),
                    ],
                  )
                : IndexedStack(index: index, children: _pages),
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: index,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (value) {
                    if (value == 4) {
                      _openSettings();
                    } else if (value == 5) {
                      _openSyncSettings();
                    } else {
                      _select(value);
                    }
                  },
                  destinations: [
                    for (var i = 0; i < AppSection.values.length; i++)
                      NavigationDestination(
                        key: Key('nav-${AppSection.values[i].name}'),
                        icon: Icon(_sectionIcon(AppSection.values[i])),
                        selectedIcon: Icon(
                          _sectionIcon(AppSection.values[i], selected: true),
                        ),
                        label: _sectionLabel(AppSection.values[i]),
                      ),
                    NavigationDestination(
                      key: const Key('open-settings'),
                      icon: const Icon(Icons.settings_outlined),
                      label: AppStrings.configShort,
                    ),
                    NavigationDestination(
                      key: const Key('open-sync-settings'),
                      icon: Icon(visual.icon, color: visual.color),
                      label: AppStrings.syncShort,
                    ),
                  ],
                ),
          floatingActionButton: switch (navigation.section) {
            AppSection.agenda || AppSection.inbox =>
              isShort || isCompact
                  ? FloatingActionButton.small(
                      key: const Key('add-post-it'),
                      tooltip: AppStrings.newPostIt,
                      onPressed: _openNewPostIt,
                      child: const Icon(Icons.add),
                    )
                  : FloatingActionButton.extended(
                      key: const Key('add-post-it'),
                      onPressed: _openNewPostIt,
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.newPostIt),
                    ),
            AppSection.routines => FloatingActionButton.extended(
              key: const Key('add-routine'),
              onPressed: _openNewRoutine,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.routineNew),
            ),
            AppSection.notes => null,
          },
        );
      },
    );
  }

  static String _sectionLabel(AppSection section) => switch (section) {
    AppSection.agenda => AppStrings.agenda,
    AppSection.inbox => AppStrings.inbox,
    AppSection.notes => AppStrings.notes,
    AppSection.routines => AppStrings.routines,
  };

  static IconData _sectionIcon(AppSection section, {bool selected = false}) =>
      switch (section) {
        AppSection.agenda =>
          selected ? Icons.calendar_month : Icons.calendar_month_outlined,
        AppSection.inbox => selected ? Icons.inbox : Icons.inbox_outlined,
        AppSection.notes => selected ? Icons.note_alt : Icons.note_alt_outlined,
        AppSection.routines =>
          selected ? Icons.event_repeat : Icons.event_repeat_outlined,
      };

  static List<NavigationRailDestination> _railDestinations() => [
    for (final section in AppSection.values)
      NavigationRailDestination(
        icon: Icon(_sectionIcon(section)),
        selectedIcon: Icon(_sectionIcon(section, selected: true)),
        label: Text(_sectionLabel(section)),
      ),
  ];
}

({IconData icon, String tooltip, Color? color}) _syncVisual(
  SyncCoordinator sync,
) {
  if (!sync.configured) {
    return (
      icon: Icons.cloud_off_outlined,
      tooltip: AppStrings.syncNotPaired,
      color: null,
    );
  }
  if (sync.pendingPreflight != null) {
    return (
      icon: Icons.cloud_sync_outlined,
      tooltip: AppStrings.syncPendingReview,
      color: null,
    );
  }
  if (sync.busy) {
    return (
      icon: Icons.cloud_sync_outlined,
      tooltip: AppStrings.syncRunning,
      color: null,
    );
  }
  if (sync.lastError != null) {
    return (
      icon: Icons.cloud_off_outlined,
      tooltip: AppStrings.syncError,
      color: null,
    );
  }
  if (sync.pendingCount > 0) {
    return (
      icon: Icons.cloud_upload_outlined,
      tooltip: AppStrings.syncPending(sync.pendingCount),
      color: null,
    );
  }
  return (
    icon: Icons.cloud_done_outlined,
    tooltip: AppStrings.syncLastSyncLabel(sync.lastSyncAt),
    color: null,
  );
}
