import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/data/sync/routine_merge.dart';

Map<String, Object?> routine({
  String title = 'Estudar',
  List<String> completed = const [],
  List<Map<String, Object?>>? sections,
  String updatedAt = '2026-11-04T12:00:00.000Z',
}) => {
  'id': 'r1',
  'name': 'Rotina',
  'mode': 'complete',
  'weekdays': [3],
  'items': <Object?>[],
  'sections':
      sections ??
      [
        {
          'id': 's1',
          'title': 'Manhã',
          'position': 0,
          'startMinutes': 480,
          'endMinutes': 600,
          'intervals': [
            {
              'id': 'i1',
              'startMinutes': 480,
              'endMinutes': 600,
              'position': 0,
              'title': title,
              'details': null,
              'completedDates': completed,
            },
          ],
        },
      ],
  'createdAt': '2026-11-04T12:00:00.000Z',
  'updatedAt': updatedAt,
};

void main() {
  test('mescla alterações em intervalos diferentes', () {
    final base = routine();
    final local = routine(
      sections: [
        {
          'id': 's1',
          'title': 'Manhã',
          'position': 0,
          'startMinutes': 480,
          'endMinutes': 600,
          'intervals': [
            {
              'id': 'i1',
              'startMinutes': 480,
              'endMinutes': 600,
              'position': 0,
              'title': 'Estudar',
              'details': 'Capítulo 1',
              'completedDates': ['2026-11-04'],
            },
          ],
        },
      ],
      updatedAt: '2026-11-04T12:01:00.000Z',
    );
    final server = routine(
      sections: [
        {
          'id': 's1',
          'title': 'Manhã B',
          'position': 0,
          'startMinutes': 480,
          'endMinutes': 600,
          'intervals': [
            {
              'id': 'i1',
              'startMinutes': 480,
              'endMinutes': 600,
              'position': 0,
              'title': 'Estudar',
              'details': null,
              'completedDates': [],
            },
          ],
        },
        {
          'id': 's2',
          'title': 'Tarde',
          'position': 1,
          'startMinutes': 780,
          'endMinutes': 900,
          'intervals': [
            {
              'id': 'i2',
              'startMinutes': 780,
              'endMinutes': 900,
              'position': 0,
              'title': 'Trabalhar',
              'details': null,
              'completedDates': [],
            },
          ],
        },
      ],
      updatedAt: '2026-11-04T12:02:00.000Z',
    );

    final merged = mergeRoutinePayloads(
      base: base,
      local: local,
      server: server,
    );

    expect(merged, isNotNull);
    final sections = merged!['sections'] as List;
    expect(sections, hasLength(2));
    expect((sections.first as Map)['title'], 'Manhã B');
    final interval = (sections.first as Map)['intervals'] as List;
    expect((interval.single as Map)['details'], 'Capítulo 1');
    expect((interval.single as Map)['completedDates'], ['2026-11-04']);
    expect(
      ((sections.last as Map)['intervals'] as List).single['title'],
      'Trabalhar',
    );
    expect(merged['updatedAt'], '2026-11-04T12:02:00.000Z');
  });

  test('mescla conclusões por data sem perder o outro lado', () {
    final base = routine(completed: ['2026-11-01']);
    final local = routine(
      completed: ['2026-11-01', '2026-11-02'],
      updatedAt: '2026-11-04T12:01:00.000Z',
    );
    final server = routine(
      completed: ['2026-11-03'],
      updatedAt: '2026-11-04T12:02:00.000Z',
    );

    final merged = mergeRoutinePayloads(
      base: base,
      local: local,
      server: server,
    );

    final interval =
        ((merged!['sections'] as List).single as Map)['intervals'] as List;
    expect((interval.single as Map)['completedDates'], [
      '2026-11-02',
      '2026-11-03',
    ]);
  });

  test('recusa conflito no mesmo campo', () {
    final base = routine();
    final local = routine(
      title: 'Estudar A',
      updatedAt: '2026-11-04T12:01:00.000Z',
    );
    final server = routine(
      title: 'Estudar B',
      updatedAt: '2026-11-04T12:02:00.000Z',
    );

    expect(
      mergeRoutinePayloads(base: base, local: local, server: server),
      isNull,
    );
  });

  test('recusa remoção de card contra edição no mesmo card', () {
    final base = routine();
    final local = routine(
      sections: const [],
      updatedAt: '2026-11-04T12:01:00.000Z',
    );
    final server = routine(
      title: 'Estudar B',
      updatedAt: '2026-11-04T12:02:00.000Z',
    );

    expect(
      mergeRoutinePayloads(base: base, local: local, server: server),
      isNull,
    );
  });
}
