import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../inbox/inbox_page.dart';
import '../notes/notes_page.dart';
import '../planner/agenda_page.dart';
import '../planner/widgets/post_it_editor_sheet.dart';

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

class _HomeShellState extends State<HomeShell> {
  static const _wideBreakpoint = 720.0;

  int _index = 0;

  static const _pages = <Widget>[
    AgendaPage(),
    InboxPage(),
    NotesPage(),
  ];

  static const _railDestinations = <NavigationRailDestination>[
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

  static const _barDestinations = <NavigationDestination>[
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
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final useRail = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final planner = AppScope.of(context).planner;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: const [
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
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: _railDestinations,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(index: _index, children: _pages),
                  ),
                ],
              )
            : IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: _barDestinations,
            ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              key: const Key('add-post-it'),
              onPressed: () => showPostItEditorSheet(
                context,
                controller: planner,
                initialDate: planner.selectedDate,
              ),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.newPostIt),
            )
          : null,
    );
  }
}
