import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/features/shared/hold_to_delete_button.dart';

void main() {
  testWidgets('exclui só depois de completar o anel', (tester) async {
    var deletions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoldToDeleteButton(
              key: const Key('hold-delete'),
              onDelete: () => deletions++,
            ),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byKey(const Key('hold-delete')));

    final cancelled = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));
    expect(deletions, 0);
    await cancelled.up();
    await tester.pumpAndSettle();
    expect(deletions, 0);

    final completed = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800));
    expect(deletions, 1);
    await completed.up();
    await tester.pumpAndSettle();
    expect(deletions, 1);
  });

  testWidgets('mostra o progresso circular durante a pressão', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoldToDeleteButton(
              key: const Key('hold-delete'),
              onDelete: () {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('hold-delete'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 200));

    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, greaterThan(0));
    expect(progress.value, lessThan(1));

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
