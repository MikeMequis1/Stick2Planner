import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Tema Material 3 do Stick2Planner.
///
/// Cores derivam da paleta escolhida e nunca são o único indicador de estado:
/// cartões sempre combinam ícone/símbolo e rótulo. O fundo usa um gradiente
/// sutil definido por [AppPalette].
abstract final class AppTheme {
  static ThemeData light([AppPalette palette = AppPalette.emerald]) =>
      _base(Brightness.light, palette);

  static ThemeData dark([AppPalette palette = AppPalette.emerald]) =>
      _base(Brightness.dark, palette);

  static ThemeData _base(Brightness brightness, AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        labelType: NavigationRailLabelType.all,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
