import 'package:flutter/material.dart';
import 'package:flutter_schedule/app/app.dart';
import 'package:flutter_schedule/app/planner_view_mode.dart';
import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/data/repositories/drift_post_it_repository.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_schedule/features/planner/widgets/day_cell.dart';
import 'package:flutter_schedule/features/planner/widgets/post_it_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/entities.dart';
import '../helpers/test_dependencies.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('carrega e navega com 200 post-its', (tester) async {
    tester.view.physicalSize = const Size(1164, 776);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dependencies = testDependencies(
      now: DateTime(2026, 11, 3, 9),
    );
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final items = <PostIt>[];
    for (var index = 0; index < 120; index++) {
      items.add(
        buildPostIt(
          id: 'task-$index',
          title: 'Tarefa $index',
          startDate: DateOnly(2026, 11, 1 + (index % 30)),
          sortOrder: index,
          createdAt: DateTime.utc(2026, 10, 1).add(
            Duration(minutes: index),
          ),
        ),
      );
    }
    for (var index = 0; index < 40; index++) {
      final date = DateOnly(2026, 11, 1 + (index % 30));
      items.add(
        buildPostIt(
          id: 'event-$index',
          title: 'Evento $index',
          type: PostItType.event,
          startDate: date,
          endDate: date,
          createdAt: DateTime.utc(2026, 10, 2).add(
            Duration(minutes: index),
          ),
        ),
      );
    }
    for (var index = 0; index < 40; index++) {
      final start = DateOnly(2026, 11, 1 + (index % 25));
      items.add(
        buildPostIt(
          id: 'multi-$index',
          title: 'Evento longo $index',
          type: PostItType.event,
          startDate: start,
          endDate: start.addDays(2),
          createdAt: DateTime.utc(2026, 10, 3).add(
            Duration(minutes: index),
          ),
        ),
      );
    }

    final repository = DriftPostItRepository(dependencies.database);
    await repository.saveBatch(items);
    await dependencies.planner.refresh();

    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(PlannerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    stopwatch.stop();
    debugPrint(
      'Carga 200 post-its: primeira renderização em '
      '${stopwatch.elapsedMilliseconds} ms',
    );

    expect(dependencies.planner.postIts, hasLength(200));
    expect(find.byType(DayCell), findsNWidgets(7));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('calendar-next')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-mode-increase')));
    await tester.pumpAndSettle();

    expect(dependencies.planner.landscapeMode, AgendaViewMode.month);
    expect(find.byType(DayCell), findsNWidgets(42));
    expect(find.byType(PostItTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
