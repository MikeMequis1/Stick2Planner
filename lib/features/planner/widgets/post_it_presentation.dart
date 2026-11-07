import 'package:flutter/material.dart';

import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../domain/entities/post_it.dart';

String postItTypeLabel(PostIt postIt) {
  if (postIt.isHighlight) return AppStrings.highlightType;
  return switch (postIt.type) {
    PostItType.task => AppStrings.taskType,
    PostItType.event => AppStrings.eventType,
    PostItType.recurringTodo => AppStrings.recurringType,
  };
}

String postItStatusLabel(PostItStatus status) => switch (status) {
  PostItStatus.active => AppStrings.active,
  PostItStatus.done => AppStrings.done,
  PostItStatus.cancelled => AppStrings.cancelled,
};

/// Símbolo literal do tipo; Done/feito usa apenas o ícone de lápis.
String postItSymbol(PostIt postIt) {
  if (postIt.isHighlight) return '';
  if (postIt.isEvent) return AppStrings.eventSymbol;
  return '';
}

IconData postItTypeIcon(PostItType type) => switch (type) {
  PostItType.task => Icons.check_box_outline_blank,
  PostItType.event => Icons.event_outlined,
  PostItType.recurringTodo => Icons.repeat,
};

IconData postItIcon(PostIt postIt) {
  if (postIt.status == PostItStatus.done) return Icons.check_circle_outline;
  if (postIt.status == PostItStatus.cancelled) return Icons.cancel_outlined;
  if (postIt.isHighlight) return Icons.edit_outlined;
  return postItTypeIcon(postIt.type);
}

({Color background, Color foreground}) postItColors(
  PostIt postIt,
  ColorScheme scheme,
) {
  if (postIt.status != PostItStatus.active) {
    return (
      background: scheme.surfaceContainerHighest,
      foreground: scheme.onSurfaceVariant,
    );
  }
  if (postIt.isHighlight) {
    return (
      background: scheme.tertiaryContainer,
      foreground: scheme.onTertiaryContainer,
    );
  }
  return switch (postIt.type) {
    PostItType.task => (
      background: scheme.surfaceContainerHigh,
      foreground: scheme.onSurface,
    ),
    PostItType.event => (
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
    ),
    PostItType.recurringTodo => (
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
    ),
  };
}

String postItSemanticLabel(PostIt postIt) {
  final parts = [postIt.title, postItTypeLabel(postIt)];
  if (postIt.status != PostItStatus.active) {
    parts.add(postItStatusLabel(postIt.status));
  }
  final date = postIt.startDate;
  if (date != null) {
    parts.add(postItDateLabel(postIt));
  }
  if (postIt.timeMinutes != null) {
    parts.add(DateFormats.clockTime(postIt.timeMinutes!));
  }
  return parts.join(', ');
}

String postItDateLabel(PostIt postIt) {
  final start = postIt.startDate;
  if (start == null) return AppStrings.undated;
  final end = postIt.effectiveEndDate;
  if (end == null || end.isSameDay(start)) {
    return DateFormats.shortDate(start);
  }
  return '${DateFormats.shortDate(start)} – ${DateFormats.shortDate(end)}';
}
