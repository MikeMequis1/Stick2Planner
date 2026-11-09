import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/data/sync/sync_models.dart';

void main() {
  test('conflito usa a entidade externa e o estado do servidor', () {
    final response = SyncResponse.fromJson({
      'acks': [],
      'conflicts': [
        {
          'entity': 'tag',
          'entityId': 'tag-1',
          'server': {
            'rev': 3,
            'updatedAt': 1000,
            'deleted': false,
            'payload': '{"id":"tag-1","name":"Casa","tone":"primary","deletedAt":null}',
          },
        },
      ],
      'changes': [],
      'cursor': 3,
      'more': false,
    });

    final conflict = response.conflicts.single;
    expect(conflict.entity, 'tag');
    expect(conflict.entityId, 'tag-1');
    expect(conflict.server.entity, 'tag');
    expect(conflict.server.entityId, 'tag-1');
    expect(conflict.server.rev, 3);
    expect(conflict.server.updatedAt, DateTime.utc(1970, 1, 1, 0, 0, 1));
    expect(conflict.server.payload['name'], 'Casa');
  });
}
