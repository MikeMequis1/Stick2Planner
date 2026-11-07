import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/post_it_history.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('conclui eventos com fim no passado na retomada', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final planner = dependencies.planner;

    await planner.savePostIt(
      PostIt(
        id: 'past',
        title: 'Passado',
        type: PostItType.event,
        status: PostItStatus.active,
        startDate: DateOnly(2026, 11, 1),
        endDate: DateOnly(2026, 11, 5),
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      ),
    );
    await planner.savePostIt(
      PostIt(
        id: 'single',
        title: 'Um dia',
        type: PostItType.event,
        status: PostItStatus.active,
        startDate: DateOnly(2026, 11, 1),
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      ),
    );

    await planner.handleAppResumed();

    final past = planner.postItById('past')!;
    final single = planner.postItById('single')!;
    expect(past.status, PostItStatus.done);
    expect(single.status, PostItStatus.active);
    final history = await dependencies.database
        .select(dependencies.database.postItHistoryEntries)
        .get();
    expect(
      history.where(
        (row) =>
            row.postItId == 'past' &&
            row.action == PostItHistoryAction.eventCompleted,
      ),
      hasLength(1),
    );

    await planner.handleAppResumed();
    final again = await dependencies.database
        .select(dependencies.database.postItHistoryEntries)
        .get();
    expect(
      again.where(
        (row) =>
            row.postItId == 'past' &&
            row.action == PostItHistoryAction.eventCompleted,
      ),
      hasLength(1),
    );
  });
}
