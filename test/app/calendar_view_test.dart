import 'package:flutter/material.dart';
import 'package:stick2planner/app/app.dart';
import 'package:stick2planner/app/app_strings.dart';
import 'package:stick2planner/app/bootstrap.dart';
import 'package:stick2planner/app/planner_view_mode.dart';
import 'package:stick2planner/core/date_formatting.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/features/planner/widgets/calendar_grid.dart';
import 'package:stick2planner/features/planner/widgets/day_cell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<AppDependencies> pumpPlanner(
    WidgetTester tester, {
    required Size size,
    List<PostIt> postIts = const [],
    AgendaViewMode? landscapeMode,
    AgendaViewMode? portraitMode,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(now: DateTime(2026, 11, 4, 12));
    await dependencies.initialize();
    if (landscapeMode != null) {
      await dependencies.planner.setMode(landscapeMode, Orientation.landscape);
    }
    if (portraitMode != null) {
      await dependencies.planner.setMode(portraitMode, Orientation.portrait);
    }
    for (final postIt in postIts) {
      await dependencies.planner.savePostIt(postIt);
    }
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    return dependencies;
  }

  testWidgets('evento multi-dia é uma barra única, não um cartão por dia', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Viagem',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
        buildPostIt(
          id: 't1',
          title: 'Compras',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    expect(find.byType(DayCell), findsNWidgets(7));
    expect(find.text('2 – 8 nov 2026'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('event-bar-e1-2026-11-02')),
      findsOneWidget,
    );
    expect(find.text('Viagem'), findsOneWidget);
    expect(find.byKey(const ValueKey('post-it-e1')), findsNothing);
    expect(find.byKey(const ValueKey('post-it-t1')), findsOneWidget);
  });

  testWidgets('evento entre semanas não repete o título', (tester) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      landscapeMode: AgendaViewMode.twoWeeks,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Viagem',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 5),
          endDate: DateOnly(2026, 11, 12),
        ),
      ],
    );

    expect(
      find.byKey(const ValueKey('event-bar-e1-2026-11-02')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('event-bar-e1-2026-11-09')),
      findsOneWidget,
    );
    expect(find.text('Viagem'), findsOneWidget);
    expect(find.text('continua'), findsOneWidget);
    expect(find.byKey(const ValueKey('post-it-e1')), findsNothing);
  });

  testWidgets('alças de resize têm pelo menos 24dp lógicos', (tester) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Evento',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    for (final key in const [
      Key('event-resize-start-e1'),
      Key('event-resize-end-e1'),
    ]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.width, greaterThanOrEqualTo(24));
      expect(size.height, greaterThanOrEqualTo(24));
    }
  });

  testWidgets('indicador de eventos ocultos abre a lista e preserva IDs', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      landscapeMode: AgendaViewMode.month,
      postIts: [
        buildPostIt(
          id: 'visible',
          title: 'Evento visível',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 2),
          endDate: DateOnly(2026, 11, 4),
        ),
        buildPostIt(
          id: 'hidden-1',
          title: 'Evento oculto A',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 3),
          endDate: DateOnly(2026, 11, 5),
        ),
        buildPostIt(
          id: 'hidden-2',
          title: 'Evento oculto B',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 3),
          endDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    final indicator = find.byKey(const Key('hidden-events-2026-11-02'));
    expect(indicator, findsOneWidget);

    await tester.tap(indicator);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.hiddenEventsTitle), findsOneWidget);
    expect(find.text('Evento oculto A'), findsOneWidget);
    expect(find.text('Evento oculto B'), findsOneWidget);
    expect(find.text('Evento visível'), findsOneWidget);
  });

  testWidgets('mês compacto combina barra de evento e overflow', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      landscapeMode: AgendaViewMode.month,
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Semana intensa',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 2),
          endDate: DateOnly(2026, 11, 8),
        ),
        for (var index = 1; index <= 5; index++)
          buildPostIt(
            id: 't$index',
            title: 'Tarefa $index',
            startDate: DateOnly(2026, 11, 4),
            sortOrder: index,
          ),
      ],
    );

    expect(
      find.byKey(const ValueKey('event-bar-e1-2026-11-02')),
      findsOneWidget,
    );
    expect(find.textContaining('mais'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controles ajustam dias visíveis e navegam sem alterar dados', (
    tester,
  ) async {
    final dependencies = await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Compras',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    expect(find.byType(DayCell), findsNWidgets(7));
    expect(find.text('Semana'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.landscapeMode, AgendaViewMode.twoWeeks);
    expect(find.text('2 semanas'), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(14));

    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();

    expect(find.text('Mês'), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(42));
    expect(dependencies.planner.landscapeMode, AgendaViewMode.month);

    final countBefore = dependencies.planner.postIts.length;
    await tester.tap(find.byKey(const Key('calendar-next')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.selectedDate, DateOnly(2026, 12, 4));
    expect(find.text('Dezembro 2026'), findsOneWidget);
    expect(dependencies.planner.postIts.length, countBefore);
    expect(dependencies.planner.postIts.single.id, 't1');
  });

  testWidgets('mês compacto mostra overflow e abre o dia completo', (
    tester,
  ) async {
    final tasks = [
      for (var index = 1; index <= 6; index++)
        buildPostIt(
          id: 't$index',
          title: 'Tarefa $index',
          startDate: DateOnly(2026, 11, 4),
          sortOrder: index,
        ),
    ];
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: tasks,
      landscapeMode: AgendaViewMode.month,
    );

    expect(find.byType(DayCell), findsNWidgets(42));
    expect(find.textContaining('mais'), findsWidgets);

    await tester.tap(find.byKey(const Key('day-overflow-2026-11-04')));
    await tester.pumpAndSettle();

    expect(find.text('Quarta-feira, 4 de novembro de 2026'), findsOneWidget);
    expect(find.text('Tarefa 6'), findsOneWidget);
    expect(find.text('Tarefa 1'), findsWidgets);
  });

  testWidgets('tocar em um dia atualiza a data selecionada', (tester) async {
    final dependencies = await pumpPlanner(tester, size: const Size(1280, 800));

    await tester.tap(find.byKey(const Key('day-2026-11-05')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 5));
    expect(find.text('2 – 8 nov 2026'), findsOneWidget);
  });

  testWidgets('dois toques criam tarefa e três criam evento', (tester) async {
    await pumpPlanner(tester, size: const Size(1280, 800));
    final day = find.byKey(const Key('day-2026-11-05'));

    await tester.tap(day);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(day);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsWidgets);
    ChoiceChip typeChip(String label) => tester.widget<ChoiceChip>(
      find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
    );
    expect(typeChip(AppStrings.taskType).selected, isTrue);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    await tester.tap(day);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(day);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(day);
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsWidgets);
    expect(typeChip(AppStrings.eventType).selected, isTrue);
  });

  testWidgets('segurar um dia mostra prévia e soltar fecha', (tester) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Revisar prévia',
          startDate: DateOnly(2026, 11, 5),
        ),
      ],
    );

    final day = find.byKey(const Key('day-2026-11-05'));
    final gesture = await tester.startGesture(tester.getCenter(day));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('day-preview')), findsOneWidget);
    expect(
      find.text(DateFormats.fullDate(DateOnly(2026, 11, 5))),
      findsOneWidget,
    );
    expect(find.text('Revisar prévia'), findsWidgets);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('day-preview')), findsNothing);
  });

  testWidgets('prévia acompanha o dedo sobre outros dias visíveis', (
    tester,
  ) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 't1',
          title: 'Revisar prévia',
          startDate: DateOnly(2026, 11, 5),
        ),
        buildPostIt(
          id: 't2',
          title: 'Dia seguinte',
          startDate: DateOnly(2026, 11, 6),
        ),
      ],
    );

    final origin = find.byKey(const Key('day-2026-11-05'));
    final target = find.byKey(const Key('day-2026-11-06'));
    final gesture = await tester.startGesture(tester.getCenter(origin));
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text(DateFormats.fullDate(DateOnly(2026, 11, 5))),
      findsOneWidget,
    );

    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.byKey(const Key('day-preview')), findsOneWidget);
    expect(
      find.text(DateFormats.fullDate(DateOnly(2026, 11, 6))),
      findsOneWidget,
    );
    expect(find.text('Dia seguinte'), findsWidgets);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('day-preview')), findsNothing);
  });

  testWidgets('deslizar horizontalmente folheia o período', (tester) async {
    final dependencies = await pumpPlanner(tester, size: const Size(1280, 800));

    expect(find.text('2 – 8 nov 2026'), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(-500, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 11));
    expect(find.text('9 – 15 nov 2026'), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(500, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.text('2 – 8 nov 2026'), findsOneWidget);
  });

  testWidgets('deslizar verticalmente altera a quantidade de dias', (
    tester,
  ) async {
    final dependencies = await pumpPlanner(tester, size: const Size(1280, 800));

    expect(find.byType(DayCell), findsNWidgets(7));

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(0, -450),
      1200,
    );
    await tester.pumpAndSettle();

    expect(dependencies.planner.landscapeMode, AgendaViewMode.twoWeeks);
    expect(find.byType(DayCell), findsNWidgets(14));

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(0, 450),
      1200,
    );
    await tester.pumpAndSettle();

    expect(dependencies.planner.landscapeMode, AgendaViewMode.week);
    expect(find.byType(DayCell), findsNWidgets(7));
  });

  testWidgets('swipe mantém a animação de transição da grade', (tester) async {
    await pumpPlanner(tester, size: const Size(1280, 800));

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(-500, 0),
      1200,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CalendarGrid), findsNWidgets(2));
    await tester.pumpAndSettle();

    await tester.fling(
      find.byKey(const Key('calendar-swipe-area')),
      const Offset(0, -450),
      1200,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CalendarGrid), findsNWidgets(2));
    await tester.pumpAndSettle();
  });

  testWidgets('retrato inicia em dia e cresce até semana', (tester) async {
    await pumpPlanner(tester, size: const Size(800, 1280));

    expect(find.text('Dia'), findsOneWidget);
    expect(find.byType(DayCell), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();
    expect(find.text('4 dias'), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(4));

    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();
    expect(find.text('Semana'), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(7));

    await tester.tap(find.byKey(const Key('calendar-mode-decrease')));
    await tester.pumpAndSettle();
    expect(find.byType(DayCell), findsNWidgets(4));
  });

  testWidgets('quatro dias mantêm a janela ao trocar o dia focado', (
    tester,
  ) async {
    final dependencies = await pumpPlanner(
      tester,
      size: const Size(800, 1280),
      portraitMode: AgendaViewMode.fourDays,
    );

    expect(find.byType(DayCell), findsNWidgets(4));
    expect(find.text('4 – 7 nov 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-2026-11-05')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CalendarGrid), findsOneWidget);
    await tester.pumpAndSettle();

    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 5));
    expect(find.text('4 – 7 nov 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-next')));
    await tester.pumpAndSettle();
    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 9));
    expect(find.text('8 – 11 nov 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-today')));
    await tester.pumpAndSettle();
    expect(dependencies.planner.selectedDate, DateOnly(2026, 11, 4));
    expect(find.text('4 – 7 nov 2026'), findsOneWidget);
  });

  testWidgets('mudar orientação preserva seleção e dados', (tester) async {
    final dependencies = await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 'e1',
          title: 'Viagem',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 6),
        ),
        buildPostIt(
          id: 't1',
          title: 'Compras',
          startDate: DateOnly(2026, 11, 4),
        ),
      ],
    );

    final idsBefore = dependencies.planner.postIts
        .map((postIt) => postIt.id)
        .toList();
    final selectedBefore = dependencies.planner.selectedDate;

    tester.view.physicalSize = const Size(800, 1280);
    await tester.pumpAndSettle();

    expect(find.text('Dia'), findsOneWidget);
    expect(find.byType(DayCell), findsOneWidget);
    expect(dependencies.planner.selectedDate, selectedBefore);
    expect(
      dependencies.planner.postIts.map((postIt) => postIt.id).toList(),
      idsBefore,
    );

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();

    expect(find.byType(DayCell), findsNWidgets(7));
    expect(dependencies.planner.postIts, hasLength(2));
  });

  testWidgets('celular em paisagem compacta a barra sem estourar', (
    tester,
  ) async {
    await pumpPlanner(tester, size: const Size(780, 360));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('calendar-swipe-area')), findsOneWidget);
    expect(find.byKey(const Key('add-post-it')), findsOneWidget);
  });

  testWidgets('dias anteriores recebem indicação visual', (tester) async {
    await pumpPlanner(tester, size: const Size(1280, 800));

    expect(find.byKey(const Key('day-past-2026-11-02')), findsOneWidget);
    expect(find.byKey(const Key('day-past-2026-11-03')), findsOneWidget);
    expect(find.byKey(const Key('day-past-2026-11-04')), findsNothing);
    expect(find.byKey(const Key('day-past-2026-11-05')), findsNothing);
  });

  testWidgets('horário do evento aparece na barra', (tester) async {
    await pumpPlanner(
      tester,
      size: const Size(1280, 800),
      postIts: [
        buildPostIt(
          id: 'timed',
          title: 'Reunião',
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 4),
          endDate: DateOnly(2026, 11, 5),
          timeMinutes: 9 * 60 + 30,
        ),
      ],
    );

    expect(find.text('09:30'), findsWidgets);
  });

  testWidgets('celular em retrato não estoura', (tester) async {
    await pumpPlanner(tester, size: const Size(360, 780));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('calendar-swipe-area')), findsOneWidget);
  });
}
