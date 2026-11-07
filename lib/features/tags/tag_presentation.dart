import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../domain/entities/tag.dart';

String tagToneLabel(TagTone tone) => switch (tone) {
  TagTone.primary => AppStrings.tagTonePrimary,
  TagTone.secondary => AppStrings.tagToneSecondary,
  TagTone.tertiary => AppStrings.tagToneTertiary,
  TagTone.primarySoft => AppStrings.tagTonePrimarySoft,
  TagTone.secondarySoft => AppStrings.tagToneSecondarySoft,
  TagTone.tertiarySoft => AppStrings.tagToneTertiarySoft,
};

({Color background, Color foreground, Color accent}) tagToneColors(
  TagTone tone,
  ColorScheme scheme,
) {
  final base = switch (tone) {
    TagTone.primary || TagTone.primarySoft => scheme.primary,
    TagTone.secondary || TagTone.secondarySoft => scheme.secondary,
    TagTone.tertiary || TagTone.tertiarySoft => scheme.tertiary,
  };
  final container = switch (tone) {
    TagTone.primary || TagTone.primarySoft => scheme.primaryContainer,
    TagTone.secondary || TagTone.secondarySoft => scheme.secondaryContainer,
    TagTone.tertiary || TagTone.tertiarySoft => scheme.tertiaryContainer,
  };
  final soft =
      tone == TagTone.primarySoft ||
      tone == TagTone.secondarySoft ||
      tone == TagTone.tertiarySoft;
  return (
    background: soft
        ? Color.alphaBlend(container.withValues(alpha: 0.45), scheme.surface)
        : container,
    foreground: soft ? scheme.onSurface : scheme.onSurfaceVariant,
    accent: base,
  );
}

/// Chip compacto de tag, reutilizado em detalhes, filtros e seleção.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.selected,
    this.onTap,
    this.onDeleted,
  });

  final Tag tag;
  final bool? selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final colors = tagToneColors(tag.tone, Theme.of(context).colorScheme);
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(tag.name),
      ],
    );

    if (selected == null && onDeleted == null) {
      return Chip(
        backgroundColor: colors.background,
        label: label,
        labelStyle: TextStyle(color: colors.foreground),
        visualDensity: VisualDensity.compact,
      );
    }

    return FilterChip(
      label: label,
      selected: selected ?? false,
      onSelected: onTap == null ? null : (_) => onTap!(),
      onDeleted: onDeleted,
      backgroundColor: colors.background,
      selectedColor: colors.background,
      labelStyle: TextStyle(color: colors.foreground),
      checkmarkColor: colors.accent,
      deleteIconColor: colors.foreground,
      visualDensity: VisualDensity.compact,
    );
  }
}
