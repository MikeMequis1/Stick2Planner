import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/theme/app_palette.dart';

/// Preferências básicas e chaves de ativação/desativação de funções.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.settings)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                AppStrings.settingsAppearance,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.settingsTheme,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ThemeMode>(
                        key: const Key('settings-theme'),
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(AppStrings.settingsThemeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(AppStrings.settingsThemeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(AppStrings.settingsThemeDark),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) =>
                            settings.setThemeMode(selection.first),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.settingsPalette,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.settingsPaletteHelp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final palette in AppPalette.values)
                            _PaletteOption(
                              palette: palette,
                              selected: settings.palette == palette,
                              onTap: () => settings.setPalette(palette),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        key: const Key('settings-animations'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text(AppStrings.settingsAnimations),
                        subtitle: const Text(AppStrings.settingsAnimationsHelp),
                        value: settings.animationsEnabled,
                        onChanged: settings.setAnimationsEnabled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.agenda, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      key: const Key('settings-keep-awake'),
                      title: const Text(AppStrings.settingsKeepAwake),
                      subtitle: const Text(AppStrings.settingsKeepAwakeHelp),
                      value: settings.keepScreenAwake,
                      onChanged: settings.setKeepScreenAwake,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      key: const Key('settings-hints'),
                      title: const Text(AppStrings.settingsHints),
                      subtitle: const Text(AppStrings.settingsHintsHelp),
                      value: settings.showCalendarHints,
                      onChanged: settings.setShowCalendarHints,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.settingsAbout, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: const Text(AppStrings.offlineNotice),
                  subtitle: const Text(AppStrings.settingsLocalData),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final foreground = brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('settings-palette-${palette.name}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 132,
          height: 76,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: palette.linearGradient(brightness),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  palette.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
