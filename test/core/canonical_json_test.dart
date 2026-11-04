import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/canonical_json.dart';

void main() {
  group('canonicalJsonEncode', () {
    test('ordena chaves e remove espaços', () {
      expect(
        canonicalJsonEncode({
          'b': 1,
          'a': [true, null, 'x'],
        }),
        '{"a":[true,null,"x"],"b":1}',
      );
    });

    test('preserva UTF-8 literal e escapa o mínimo', () {
      expect(
        canonicalJsonEncode({'z': 'ação "x"\n', 'a': 2}),
        '{"a":2,"z":"ação \\"x\\"\\n"}',
      );
    });

    test('aceita double integral e recusa fracionário', () {
      expect(canonicalJsonEncode(2.0), '2');
      expect(() => canonicalJsonEncode(1.5), throwsArgumentError);
      expect(() => canonicalJsonEncode(double.nan), throwsArgumentError);
    });

    test('recusa tipos fora do JSON', () {
      expect(() => canonicalJsonEncode(Object()), throwsArgumentError);
      expect(() => canonicalJsonEncode({1: 'x'}), throwsArgumentError);
    });

    test('hash estável para o mesmo estado', () {
      expect(
        canonicalSha256({'a': 1}),
        '015abd7f5cc57a2dd94b7590f04ad8084273905ee33ec5cebeae62276a97f862',
      );
    });
  });
}
