import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_strings.dart';
import '../../../core/date_formatting.dart';
import '../../../domain/entities/post_it.dart';
import '../../../domain/entities/tag.dart';
import '../../tags/tag_presentation.dart';

String postItTypeLabel(PostIt postIt) {
  if (postIt.isHighlight) return AppStrings.highlightType;
  return switch (postIt.type) {
    PostItType.task => AppStrings.taskType,
    PostItType.event => AppStrings.eventType,
    PostItType.recurringTodo => AppStrings.recurringType,
  };
}

String postItTypeDescription(PostItType type) => switch (type) {
  PostItType.task => AppStrings.taskTypeHelp,
  PostItType.event => AppStrings.eventTypeHelp,
  PostItType.recurringTodo => AppStrings.recurringHelp,
};

String postItStatusLabel(PostItStatus status) => switch (status) {
  PostItStatus.active => AppStrings.active,
  PostItStatus.done => AppStrings.done,
  PostItStatus.cancelled => AppStrings.cancelled,
};

/// Símbolo literal do tipo; Feito usa apenas o ícone de lápis.
String postItSymbol(PostIt postIt) {
  if (postIt.isHighlight) return '';
  if (postIt.isEvent) return AppStrings.eventSymbol;
  return '';
}

IconData postItTypeIcon(PostItType type) => switch (type) {
  PostItType.task => Icons.check_box_outlined,
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
  ColorScheme scheme, {
  Tag? tag,
}) {
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
  if (postIt.isEvent && tag != null) {
    final tagColors = tagToneColors(tag.tone, scheme);
    return (background: tagColors.background, foreground: tagColors.foreground);
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

/// Primeira tag existente de um evento, na ordem em que foi associada.
///
/// Tarefas mantêm a cor do tipo; apenas eventos usam a cor da tag.
Tag? postItPrimaryTag(BuildContext context, PostIt postIt) {
  if (!postIt.isEvent || postIt.tagIds.isEmpty) return null;
  final tags = AppScope.maybeOf(context)?.tags;
  if (tags == null) return null;
  for (final tagId in postIt.tagIds) {
    final tag = tags.byId(tagId);
    if (tag != null) return tag;
  }
  return null;
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
