import '../../../app/app_strings.dart';
import '../../../domain/usecases/validate_post_it.dart';

/// Traduz erros do domínio para mensagens exibíveis.
String postItValidationMessage(PostItValidationError error) {
  return switch (error) {
    PostItValidationError.emptyTitle => AppStrings.errorTitleEmpty,
    PostItValidationError.titleTooLong => AppStrings.errorTitleLong,
    PostItValidationError.eventRequiresDate => AppStrings.errorEventDate,
    PostItValidationError.eventEndBeforeStart => AppStrings.errorEndBeforeStart,
    PostItValidationError.endDateRequiresStart =>
      AppStrings.errorEndWithoutStart,
    PostItValidationError.taskHasInterval => AppStrings.errorIntervalOnTask,
    PostItValidationError.recurringHasInterval =>
      AppStrings.errorIntervalOnTask,
    PostItValidationError.highlightRequiresEvent =>
      AppStrings.errorHighlightEvent,
    PostItValidationError.recurrenceRequiresEvent =>
      AppStrings.errorRecurrenceEvent,
    PostItValidationError.invalidRecurrenceInterval =>
      AppStrings.errorRecurrenceInterval,
  };
}
