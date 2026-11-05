import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/services/device_name.dart';
import '../../app/app_strings.dart';
import '../../app/theme/app_palette.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../data/backup/backup_document.dart';
import '../../data/backup/backup_service.dart';
import 'about_page.dart';
import 'connection_test_page.dart';
import 'qr_scan_page.dart';

/// Preferências básicas e chaves de ativação/desativação de funções.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.focusSync = false});

  /// Rola até a seção de conexão/sincronização ao abrir.
  final bool focusSync;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _syncKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (!widget.focusSync) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _syncKey.currentContext;
      if (!mounted || target == null || !_scroll.hasClients) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.settings)),
          body: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 24),
                Text(
                  AppStrings.settingsAgendaBehavior,
                  style: theme.textTheme.titleSmall,
                ),
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
                Column(
                  key: _syncKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.settingsSync,
                      style: theme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    const _SyncSection(),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  AppStrings.settingsBackup,
                  style: theme.textTheme.titleSmall,
                ),
                SizedBox(height: 8),
                const _BackupSection(),
                SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    key: const Key('settings-about'),
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppStrings.settingsAbout),
                    subtitle: Text(AppStrings.settingsAboutHelp),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AboutPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SyncSection extends StatefulWidget {
  const _SyncSection();

  @override
  State<_SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends State<_SyncSection> {
  bool _busy = false;

  Future<void> _pair() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _PairingDialog(),
    );
    if (code == null || code.isEmpty || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final sync = AppScope.of(context).sync;
    setState(() => _busy = true);
    try {
      final deviceName = await resolveDeviceName();
      await sync.pair(code, deviceName: deviceName);
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.syncPairSuccess)),
      );
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.syncPairFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncNow() async {
    final messenger = ScaffoldMessenger.of(context);
    final sync = AppScope.of(context).sync;
    final report = await sync.syncNow();
    if (!mounted) return;
    if (report == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            sync.configured
                ? AppStrings.syncError
                : AppStrings.syncNotConfigured,
          ),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.syncDone(report.pushed, report.pulled, report.copies),
        ),
      ),
    );
  }

  Future<void> _disconnect() async {
    final messenger = ScaffoldMessenger.of(context);
    final sync = AppScope.of(context).sync;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.syncDisconnect),
        content: Text(AppStrings.syncDisconnectConfirm),
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
    if (confirmed != true) return;
    await sync.disconnect();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppStrings.syncDisconnected)),
    );
  }

  void _openConnection() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ConnectionTestPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sync = AppScope.of(context).sync;
    return ListenableBuilder(
      listenable: sync,
      builder: (context, _) {
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      sync.configured
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sync.configured
                            ? '${AppStrings.syncPaired} · '
                                  '${AppStrings.syncPending(sync.pendingCount)}'
                            : AppStrings.syncNotPaired,
                        key: const Key('settings-sync-status'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  AppStrings.syncLastSyncLabel(sync.lastSyncAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (sync.lastError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.syncError,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Text(
                    sync.lastError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile(
                  key: const Key('settings-sync-enabled'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppStrings.syncEnabled),
                  subtitle: sync.configured
                      ? null
                      : Text(AppStrings.syncPairFirst),
                  value: sync.enabled,
                  onChanged: sync.configured && !_busy
                      ? (value) => sync.setEnabled(value)
                      : null,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Tooltip(
                      message: sync.configured
                          ? AppStrings.syncNow
                          : AppStrings.syncPairFirst,
                      child: FilledButton.icon(
                        key: const Key('settings-sync-now'),
                        onPressed: sync.configured && !sync.busy && !_busy
                            ? _syncNow
                            : null,
                        icon: sync.busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(
                          sync.busy
                              ? AppStrings.syncRunning
                              : AppStrings.syncNow,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      key: const Key('settings-sync-pair'),
                      onPressed: _busy ? null : _pair,
                      icon: const Icon(Icons.link),
                      label: Text(AppStrings.syncPair),
                    ),
                    if (sync.configured)
                      TextButton(
                        key: const Key('settings-sync-disconnect'),
                        onPressed: _busy ? null : _disconnect,
                        child: Text(AppStrings.syncDisconnect),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('settings-sync-connection'),
                    onPressed: _busy ? null : _openConnection,
                    icon: const Icon(Icons.lan_outlined),
                    label: Text(AppStrings.syncConnection),
                  ),
                ),
              ],
            ),
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

class _PairingDialog extends StatefulWidget {
  const _PairingDialog();

  @override
  State<_PairingDialog> createState() => _PairingDialogState();
}

class _PairingDialogState extends State<_PairingDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const QrScanPage()));
    if (scanned != null) _controller.text = scanned;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.syncPairTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.syncPairHelp),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sync-pair-code'),
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: AppStrings.syncPairCodeHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('sync-pair-scan'),
              onPressed: _scan,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(AppStrings.syncScanQr),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        FilledButton(
          key: const Key('sync-pair-confirm'),
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(AppStrings.syncPair),
        ),
      ],
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
