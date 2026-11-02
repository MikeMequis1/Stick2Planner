import 'package:flutter_schedule/core/date_only.dart';
import 'package:flutter_schedule/domain/calendar/agenda_view_mode.dart';
import 'package:flutter_schedule/domain/calendar/calendar_period.dart';
import 'package:flutter_schedule/domain/calendar/event_bar_layout.dart';
import 'package:flutter_schedule/domain/entities/post_it.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';

void main() {
  final week = CalendarPeriod.compute(
    selectedDate: DateOnly(2026, 11, 4),
    mode: AgendaViewMode.week,
  ).weeks.first;

  group('layoutEventSegments', () {
    test('evento dentro da semana vira uma barra única', () {
      final event = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
      );

      final layout = layoutEventSegments([event], week);

      expect(layout.segments, hasLength(1));
      final segment = layout.segments.single;
      expect(segment.postIt.id, 'e1');
      expect(segment.startColumn, 2);
      expect(segment.endColumn, 4);
      expect(segment.columnSpan, 3);
      expect(segment.continuesBefore, isFalse);
      expect(segment.continuesAfter, isFalse);
      expect(layout.hiddenCount, 0);
    });

    test('evento que começa antes da semana marca continuação', () {
      final event = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 10, 30),
        endDate: DateOnly(2026, 11, 3),
      );

      final layout = layoutEventSegments([event], week);

      final segment = layout.segments.single;
      expect(segment.startColumn, 0);
      expect(segment.endColumn, 1);
      expect(segment.continuesBefore, isTrue);
      expect(segment.continuesAfter, isFalse);
    });

    test('evento que atravessa a semana inteira continua nas duas pontas', () {
      final event = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 10, 30),
        endDate: DateOnly(2026, 11, 10),
      );

      final segment = layoutEventSegments([event], week).segments.single;

      expect(segment.startColumn, 0);
      expect(segment.endColumn, 6);
      expect(segment.continuesBefore, isTrue);
      expect(segment.continuesAfter, isTrue);
    });

    test('sobreposição usa faixas diferentes', () {
      final first = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
      );
      final second = buildPostIt(
        id: 'e2',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 5),
        endDate: DateOnly(2026, 11, 7),
      );

      final layout = layoutEventSegments([first, second], week);

      expect(layout.segments, hasLength(2));
      expect(layout.segments[0].lane, isNot(layout.segments[1].lane));
    });

    test('respeita limite de faixas e sinaliza excedente', () {
      final first = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 6),
      );
      final second = buildPostIt(
        id: 'e2',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 5),
      );

      final layout = layoutEventSegments(
        [first, second],
        week,
        maxLanes: 1,
      );

      expect(layout.segments, hasLength(1));
      expect(layout.hiddenCount, 1);
    });

    test('ignora tarefas e eventos de um único dia', () {
      final task = buildPostIt(
        id: 't1',
        startDate: DateOnly(2026, 11, 4),
      );
      final singleDayEvent = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 5),
        endDate: DateOnly(2026, 11, 5),
      );

      final layout = layoutEventSegments([task, singleDayEvent], week);

      expect(layout.segments, isEmpty);
    });

    test('ignora evento fora da semana', () {
      final event = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 12, 1),
        endDate: DateOnly(2026, 12, 3),
      );

      expect(layoutEventSegments([event], week).segments, isEmpty);
    });
  });

  group('singleDayItemsOn', () {
    test('inclui tarefas e eventos de um dia, exclui multi-dia', () {
      final task = buildPostIt(
        id: 't1',
        startDate: DateOnly(2026, 11, 4),
      );
      final singleDayEvent = buildPostIt(
        id: 'e1',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 4),
        endDate: DateOnly(2026, 11, 4),
      );
      final multiDayEvent = buildPostIt(
        id: 'e2',
        type: PostItType.event,
        startDate: DateOnly(2026, 11, 2),
        endDate: DateOnly(2026, 11, 6),
      );
      final undated = buildPostIt(id: 't2');

      final items = singleDayItemsOn(
        [task, singleDayEvent, multiDayEvent, undated],
        DateOnly(2026, 11, 4),
      );

      expect(items.map((item) => item.id), ['t1', 'e1']);
    });
  });
}
