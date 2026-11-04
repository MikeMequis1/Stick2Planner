import 'package:flutter/material.dart';

import '../../app/controllers/app_navigation_controller.dart';
import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../inbox/inbox_page.dart';
import '../notes/notes_page.dart';
import '../planner/agenda_page.dart';
import '../planner/widgets/post_it_editor_sheet.dart';
import '../settings/settings_page.dart';

/// Casca de navegação: trilho em tablets largos, barra inferior em telas
/// estreitas. Preserva o estado de cada seção com [IndexedStack].
///
/// Cada página escuta seu próprio controller, então a casca não precisa
/// reconstruir a árvore inteira a cada mudança de dados.
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
  }

  static final _pages = <Widget>[AgendaPage(), InboxPage(), NotesPage()];

  static List<NavigationRailDestination> get _railDestinations => <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: Text(AppStrings.agenda),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inbox_outlined),
      selectedIcon: Icon(Icons.inbox),
      label: Text(AppStrings.inbox),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.note_alt_outlined),
      selectedIcon: Icon(Icons.note_alt),
      label: Text(AppStrings.notes),
    ),
  ];

  static List<NavigationDestination> get _barDestinations => <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: AppStrings.agenda,
    ),
    NavigationDestination(
      icon: Icon(Icons.inbox_outlined),
      selectedIcon: Icon(Icons.inbox),
      label: AppStrings.inbox,
    ),
    NavigationDestination(
      icon: Icon(Icons.note_alt_outlined),
      selectedIcon: Icon(Icons.note_alt),
      label: AppStrings.notes,
    ),
  ];

  void _select(int index) {
    AppScope.of(context).navigation.select(AppSection.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= _wideBreakpoint;
    final isCompact = width < 600;
    final app = AppScope.of(context);
    final planner = app.planner;
    final navigation = app.navigation;

    return ListenableBuilder(
      listenable: navigation,
      builder: (context, _) {
        final index = navigation.section.index;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(AppStrings.appName),
            actions: [
              if (isCompact)
                IconButton(
                  key: Key('add-post-it'),
                  tooltip: AppStrings.newPostIt,
                  onPressed: () => showPostItEditorSheet(
                    context,
                    controller: planner,
                    initialDate: planner.selectedDate,
                  ),
                  icon: Icon(Icons.add),
                ),
              IconButton(
                key: Key('open-settings'),
                tooltip: AppStrings.settings,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => SettingsPage(),
                  ),
                ),
                icon: Icon(Icons.settings_outlined),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Tooltip(
                  message: AppStrings.offlineNotice,
                  child: Icon(Icons.cloud_off_outlined),
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: useRail
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NavigationRail(
                        minWidth: 88,
                        selectedIndex: index,
                        onDestinationSelected: _select,
                        destinations: _railDestinations,
                      ),
                      VerticalDivider(width: 1),
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
                  onDestinationSelected: _select,
                  destinations: _barDestinations,
                ),
          floatingActionButton: index == AppSection.agenda.index && !isCompact
              ? FloatingActionButton.extended(
                  key: Key('add-post-it'),
                  onPressed: () => showPostItEditorSheet(
                    context,
                    controller: planner,
                    initialDate: planner.selectedDate,
                  ),
                  icon: Icon(Icons.add),
                  label: Text(AppStrings.newPostIt),
                )
              : null,
        );
      },
    );
  }
}
