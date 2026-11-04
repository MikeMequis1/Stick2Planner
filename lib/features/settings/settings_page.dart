import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../app/theme/app_palette.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../data/backup/backup_document.dart';
import '../../data/backup/backup_service.dart';

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
          appBar: AppBar(title: Text(AppStrings.settings)),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                AppStrings.settingsAppearance,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.settingsTheme,
                        style: theme.textTheme.labelLarge,
                      ),
                      SizedBox(height: 8),
                      SegmentedButton<ThemeMode>(
                        key: Key('settings-theme'),
                        showSelectedIcon: false,
                        segments: [
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
                      SizedBox(height: 16),
                      Text(
                        AppStrings.settingsLanguage,
                        style: theme.textTheme.labelLarge,
                      ),
                      SizedBox(height: 8),
                      SegmentedButton<AppLanguage>(
                        key: Key('settings-language'),
                        showSelectedIcon: false,
                        segments: [
                          for (final language in AppLanguage.values)
                            ButtonSegment(
                              value: language,
                              label: Text(language.label),
                            ),
                        ],
                        selected: {settings.language},
                        onSelectionChanged: (selection) =>
                            settings.setLanguage(selection.first),
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.settingsPalette,
                        style: theme.textTheme.labelLarge,
                      ),
                      SizedBox(height: 4),
                      Text(
                        AppStrings.settingsPaletteHelp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 12),
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
                      SizedBox(height: 16),
                      SwitchListTile(
                        key: Key('settings-animations'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppStrings.settingsAnimations),
                        subtitle: Text(AppStrings.settingsAnimationsHelp),
                        value: settings.animationsEnabled,
                        onChanged: settings.setAnimationsEnabled,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(AppStrings.agenda, style: theme.textTheme.titleSmall),
              SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      key: Key('settings-keep-awake'),
                      title: Text(AppStrings.settingsKeepAwake),
                      subtitle: Text(AppStrings.settingsKeepAwakeHelp),
                      value: settings.keepScreenAwake,
                      onChanged: settings.setKeepScreenAwake,
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      key: Key('settings-hints'),
                      title: Text(AppStrings.settingsHints),
                      subtitle: Text(AppStrings.settingsHintsHelp),
                      value: settings.showCalendarHints,
                      onChanged: settings.setShowCalendarHints,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                AppStrings.settingsBackup,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              const _BackupSection(),
              SizedBox(height: 24),
              Text(AppStrings.settingsAbout, style: theme.textTheme.titleSmall),
              SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.cloud_off_outlined),
                  title: Text(AppStrings.offlineNotice),
                  subtitle: Text(AppStrings.settingsLocalData),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackupSection extends StatefulWidget {
  const _BackupSection();

  @override
  State<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<_BackupSection> {
  bool _busy = false;
  List<BackupSnapshot> _snapshots = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSnapshots();
  }

  Future<void> _loadSnapshots() async {
    final service = AppScope.of(context).backup;
    try {
      final snapshots = await service.listSnapshots();
      if (!mounted) return;
      setState(() => _snapshots = snapshots);
    } on Object {
      // Listagem é informativa; falhas não devem quebrar a tela.
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final service = AppScope.of(context).backup;
    final gateway = AppScope.of(context).backupFiles;
    setState(() => _busy = true);
    try {
      final document = await service.buildExport();
      final path = await gateway.saveBackup(
        fileName: document.suggestedFileName,
        contents: document.toJsonString(),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            path == null
                ? AppStrings.backupExportCanceled
                : AppStrings.backupExportSuccess(path),
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(_messageFor(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
      await _loadSnapshots();
    }
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final scope = AppScope.of(context);
    final gateway = scope.backupFiles;
    final service = scope.backup;
    try {
      final picked = await gateway.pickBackup();
      if (!mounted) return;
      if (picked == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(AppStrings.backupImportCanceled)),
        );
        return;
      }

      final document = BackupDocument.parse(picked.contents);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppStrings.backupImportConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.backupImportCounts(
                  document.counts.postIts,
                  document.counts.notes,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.backupImportDate(
                  DateFormats.fullDate(
                    DateOnly.fromDateTime(document.exportedAt.toLocal()),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(AppStrings.backupImportWarning),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              key: const Key('backup-import-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppStrings.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _busy = true);
      final result = await service.importJson(picked.contents);
      if (!mounted) return;
      await scope.planner.refresh();
      await scope.notes.refresh();
      await scope.settings.reload();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.backupImported(result.counts.postIts, result.counts.notes)} '
            '${AppStrings.backupSnapshotCreated(result.snapshot.path)}',
          ),
        ),
      );
      await _loadSnapshots();
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(_messageFor(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(BackupSnapshot snapshot) async {
    final messenger = ScaffoldMessenger.of(context);
    final scope = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.backupRestoreConfirmTitle),
        content: Text(
          AppStrings.backupRestoreConfirmBody(
            DateFormats.fullDate(
              DateOnly.fromDateTime(snapshot.createdAt.toLocal()),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await scope.backup.restoreSnapshot(snapshot);
      if (!mounted) return;
      await scope.planner.refresh();
      await scope.notes.refresh();
      await scope.settings.reload();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.backupImported(
              result.counts.postIts,
              result.counts.notes,
            ),
          ),
        ),
      );
      await _loadSnapshots();
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(_messageFor(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageFor(Object error) {
    if (error is BackupException) {
      return switch (error.code) {
        BackupErrorCode.invalidJson ||
        BackupErrorCode.invalidFormat ||
        BackupErrorCode.invalidData => AppStrings.backupErrorInvalid,
        BackupErrorCode.checksumMismatch => AppStrings.backupErrorChecksum,
        BackupErrorCode.unsupportedFormatVersion =>
          AppStrings.backupErrorVersion,
        BackupErrorCode.unsupportedSchemaVersion =>
          AppStrings.backupErrorSchema,
        BackupErrorCode.ioError => AppStrings.backupErrorGeneric,
      };
    }
    return AppStrings.backupErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.settingsBackupHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('settings-backup-export'),
                  onPressed: _busy ? null : _export,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(AppStrings.backupExport),
                ),
                OutlinedButton.icon(
                  key: const Key('settings-backup-import'),
                  onPressed: _busy ? null : _import,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(AppStrings.backupImport),
                ),
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.backupSnapshots,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  key: const Key('settings-backup-refresh'),
                  tooltip: AppStrings.backupSnapshots,
                  onPressed: _busy ? null : _loadSnapshots,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_snapshots.isEmpty)
              Text(
                AppStrings.backupSnapshotsEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final snapshot in _snapshots.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.history),
                  title: Text(
                    DateFormats.fullDate(
                      DateOnly.fromDateTime(snapshot.createdAt.toLocal()),
                    ),
                  ),
                  subtitle: Text('${(snapshot.sizeBytes / 1024).ceil()} KB'),
                  trailing: IconButton(
                    key: Key(
                      'settings-backup-restore-${snapshot.path.hashCode}',
                    ),
                    tooltip: AppStrings.backupRestoreSnapshot,
                    onPressed: _busy ? null : () => _restore(snapshot),
                    icon: const Icon(Icons.restore),
                  ),
                ),
          ],
        ),
      ),
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
          duration: Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 132,
          height: 76,
          padding: EdgeInsets.all(12),
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
