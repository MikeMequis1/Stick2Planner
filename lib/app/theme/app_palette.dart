import 'package:flutter/material.dart';

import '../app_strings.dart';

/// Paletas de cor do aplicativo. O gradiente é aplicado ao fundo da casca.
///
/// As sementes cobrem famílias distintas (verde, azul, quente, violeta, rosa e
/// neutro escuro), sem repetir tonalidades próximas. Textos e ícones continuam
/// vindo do `ColorScheme` derivado, o que mantém o contraste em tema claro e
/// escuro.
enum AppPalette {
  emerald,
  ocean,
  sunset,
  lavender,
  rose,
  graphite;

  String get label => switch (this) {
    AppPalette.emerald => AppStrings.paletteEmerald,
    AppPalette.ocean => AppStrings.paletteOcean,
    AppPalette.sunset => AppStrings.paletteSunset,
    AppPalette.lavender => AppStrings.paletteLavender,
    AppPalette.rose => AppStrings.paletteRose,
    AppPalette.graphite => AppStrings.paletteGraphite,
  };

  Color get seed => switch (this) {
    AppPalette.emerald => const Color(0xFF2F6F5E),
    AppPalette.ocean => const Color(0xFF2F5D8C),
    AppPalette.sunset => const Color(0xFFB45F3C),
    AppPalette.lavender => const Color(0xFF6A5A9E),
    AppPalette.rose => const Color(0xFFA64D6B),
    AppPalette.graphite => const Color(0xFF4A5568),
  };

  List<Color> gradient(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (this) {
      AppPalette.emerald =>
        dark
            ? const [Color(0xFF0D1411), Color(0xFF12231B), Color(0xFF173026)]
            : const [Color(0xFFF4FBF7), Color(0xFFE5F3EC), Color(0xFFD8EAE1)],
      AppPalette.ocean =>
        dark
            ? const [Color(0xFF0A1220), Color(0xFF0F2033), Color(0xFF152B45)]
            : const [Color(0xFFF4F8FF), Color(0xFFE6F0FC), Color(0xFFD8E7FA)],
      AppPalette.sunset =>
        dark
            ? const [Color(0xFF1A0F0B), Color(0xFF2A1710), Color(0xFF3A1F13)]
            : const [Color(0xFFFFF8F2), Color(0xFFFCEADB), Color(0xFFF8DCC8)],
      AppPalette.lavender =>
        dark
            ? const [Color(0xFF120F1C), Color(0xFF1E172E), Color(0xFF2A2042)]
            : const [Color(0xFFFAF7FF), Color(0xFFEFE8FC), Color(0xFFE2D7F7)],
      AppPalette.rose =>
        dark
            ? const [Color(0xFF170C10), Color(0xFF26141C), Color(0xFF361D28)]
            : const [Color(0xFFFFF5F8), Color(0xFFFBE4EB), Color(0xFFF6D3DE)],
      AppPalette.graphite =>
        dark
            ? const [Color(0xFF0C0F13), Color(0xFF161B22), Color(0xFF20262F)]
            : const [Color(0xFFF7F8FA), Color(0xFFE9EDF2), Color(0xFFDCE2E9)],
    };
  }

  LinearGradient linearGradient(Brightness brightness) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradient(brightness),
    );
  }
}
