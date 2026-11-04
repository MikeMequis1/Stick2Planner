import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';

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
