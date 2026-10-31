import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_schedule/main.dart';

void main() {
  testWidgets('abre a tela inicial sem erros', (tester) async {
    await tester.pumpWidget(const PlannerApp());

    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Base do projeto pronta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
