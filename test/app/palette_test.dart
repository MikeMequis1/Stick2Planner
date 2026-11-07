import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/app/theme/app_palette.dart';
import 'package:stick2planner/app/theme/app_theme.dart';

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance();
  final dark = background.computeLuminance();
  final lighter = light > dark ? light : dark;
  final darker = light > dark ? dark : light;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('paletas oferecem tons variados com rótulos próprios', () {
    expect(AppPalette.values, hasLength(8));
    expect(
      AppPalette.values.map((palette) => palette.seed.toARGB32()).toSet(),
      hasLength(AppPalette.values.length),
    );
    expect(
      AppPalette.values.map((palette) => palette.label).toSet(),
      hasLength(AppPalette.values.length),
    );

    for (final palette in AppPalette.values) {
      for (final brightness in Brightness.values) {
        final gradient = palette.gradient(brightness);
        expect(gradient, hasLength(3));
        expect(
          gradient.toSet(),
          hasLength(gradient.length),
          reason: '${palette.name} $brightness',
        );
        if (brightness == Brightness.light) {
          expect(
            gradient.first.computeLuminance(),
            greaterThan(gradient.last.computeLuminance()),
            reason: '${palette.name} $brightness',
          );
        } else {
          expect(
            gradient.first.computeLuminance(),
            lessThan(gradient.last.computeLuminance()),
            reason: '${palette.name} $brightness',
          );
        }
      }
    }
  });

  test('texto e ícones mantêm contraste nos temas claro e escuro', () {
    for (final palette in AppPalette.values) {
      for (final theme in [AppTheme.light(palette), AppTheme.dark(palette)]) {
        final scheme = theme.colorScheme;
        final reason = '${palette.name} ${theme.brightness}';
        expect(
          _contrast(scheme.onSurface, scheme.surface),
          greaterThan(4.5),
          reason: reason,
        );
        expect(
          _contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
          greaterThan(4.5),
          reason: reason,
        );
        expect(
          _contrast(scheme.onSecondaryContainer, scheme.secondaryContainer),
          greaterThan(4.5),
          reason: reason,
        );
        expect(
          _contrast(scheme.onTertiaryContainer, scheme.tertiaryContainer),
          greaterThan(4.5),
          reason: reason,
        );
      }
    }
  });
}
