import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/usecases/validate_post_it.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/entities.dart';

void main() {
  const validate = ValidatePostIt();

  group('ValidatePostIt', () {
    test('aceita tarefa simples sem data', () {
      expect(validate.validate(buildPostIt()), isEmpty);
    });

    test('recusa título vazio ou longo demais', () {
      expect(
        validate.validate(buildPostIt(title: '   ')),
        contains(PostItValidationError.emptyTitle),
      );
      expect(
        validate.validate(buildPostIt(title: 'a' * 121)),
        contains(PostItValidationError.titleTooLong),
      );
    });

    test('evento exige data', () {
      final errors = validate.validate(
        buildPostIt(type: PostItType.event, title: 'Evento'),
      );

      expect(errors, contains(PostItValidationError.eventRequiresDate));
    });

    test('evento recusa fim anterior ao início', () {
      final errors = validate.validate(
        buildPostIt(
          type: PostItType.event,
          startDate: DateOnly(2026, 11, 5),
          endDate: DateOnly(2026, 11, 3),
        ),
      );

      expect(errors, contains(PostItValidationError.eventEndBeforeStart));
    });

    test('evento aceita intervalo válido de vários dias', () {
      expect(
        validate.validate(
          buildPostIt(
            type: PostItType.event,
            startDate: DateOnly(2026, 11, 2),
            endDate: DateOnly(2026, 11, 6),
          ),
        ),
        isEmpty,
      );
    });

    test('tarefa e recorrente não aceitam intervalo', () {
      expect(
        validate.validate(
          buildPostIt(
            startDate: DateOnly(2026, 11, 2),
            endDate: DateOnly(2026, 11, 3),
          ),
        ),
        contains(PostItValidationError.taskHasInterval),
      );
      expect(
        validate.validate(
          buildPostIt(
            type: PostItType.recurringTodo,
            startDate: DateOnly(2026, 11, 2),
            endDate: DateOnly(2026, 11, 3),
          ),
        ),
        contains(PostItValidationError.recurringHasInterval),
      );
    });

    test('recorrente aceita ausência de data', () {
      expect(
        validate.validate(buildPostIt(type: PostItType.recurringTodo)),
        isEmpty,
      );
    });

    test('marcante precisa ser evento', () {
      expect(
        validate.validate(buildPostIt(isHighlight: true)),
        contains(PostItValidationError.highlightRequiresEvent),
      );
    });

    test('lança exceção com os motivos', () {
      expect(
        () => validate(buildPostIt(type: PostItType.event)),
        throwsA(isA<PostItValidationException>()),
      );
    });
  });
}
