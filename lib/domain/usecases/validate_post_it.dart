import '../entities/post_it.dart';

/// Motivos de recusa de um post-it. A UI traduz cada motivo.
enum PostItValidationError {
  emptyTitle,
  titleTooLong,
  eventRequiresDate,
  eventEndBeforeStart,
  endDateRequiresStart,
  taskHasInterval,
  recurringHasInterval,
  highlightRequiresEvent,
  recurrenceRequiresEvent,
  recurrenceEndRequiresRecurrence,
  recurrenceEndBeforeStart,
  highlightCannotSpanDays,
  highlightCannotRecur,
  highlightCannotHaveTags,
  highlightCannotBeResolved,
  invalidRecurrenceInterval,
}

final class PostItValidationException implements Exception {
  const PostItValidationException(this.errors);

  final List<PostItValidationError> errors;

  @override
  String toString() =>
      'PostIt inválido: ${errors.map((error) => error.name).join(', ')}';
}

/// Regras de validação compartilhadas por criação, edição e persistência.
final class ValidatePostIt {
  const ValidatePostIt();

  static const int maxTitleLength = 120;

  List<PostItValidationError> validate(PostIt postIt) {
    final errors = <PostItValidationError>[];
    final start = postIt.startDate;
    final end = postIt.endDate;

    if (postIt.title.trim().isEmpty) {
      errors.add(PostItValidationError.emptyTitle);
    }
    if (postIt.title.trim().length > maxTitleLength) {
      errors.add(PostItValidationError.titleTooLong);
    }
    if (end != null && start == null) {
      errors.add(PostItValidationError.endDateRequiresStart);
    }
    if (postIt.hasRecurrence && postIt.type == PostItType.recurringTodo) {
      errors.add(PostItValidationError.recurrenceRequiresEvent);
    }
    if (postIt.hasRecurrence && postIt.recurrenceInterval < 1) {
      errors.add(PostItValidationError.invalidRecurrenceInterval);
    }
    final recurrenceEnd = postIt.recurrenceEndDate;
    if (recurrenceEnd != null) {
      if (!postIt.hasRecurrence) {
        errors.add(PostItValidationError.recurrenceEndRequiresRecurrence);
      }
      if (start != null && recurrenceEnd.isBefore(start)) {
        errors.add(PostItValidationError.recurrenceEndBeforeStart);
      }
    }

    if (postIt.isEvent) {
      if (start == null) {
        errors.add(PostItValidationError.eventRequiresDate);
      } else if (end != null && end.isBefore(start)) {
        errors.add(PostItValidationError.eventEndBeforeStart);
      }
    } else {
      if (postIt.isHighlight) {
        errors.add(PostItValidationError.highlightRequiresEvent);
      }
      if (end != null) {
        errors.add(
          postIt.isRecurring
              ? PostItValidationError.recurringHasInterval
              : PostItValidationError.taskHasInterval,
        );
      }
    }

    if (postIt.isHighlight) {
      if (end != null) {
        errors.add(PostItValidationError.highlightCannotSpanDays);
      }
      if (postIt.hasRecurrence) {
        errors.add(PostItValidationError.highlightCannotRecur);
      }
      if (postIt.tagIds.isNotEmpty) {
        errors.add(PostItValidationError.highlightCannotHaveTags);
      }
      if (postIt.status != PostItStatus.active) {
        errors.add(PostItValidationError.highlightCannotBeResolved);
      }
    }

    return errors;
  }

  void call(PostIt postIt) {
    final errors = validate(postIt);
    if (errors.isNotEmpty) throw PostItValidationException(errors);
  }
}
