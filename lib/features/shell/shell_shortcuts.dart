import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_strings.dart';
import '../../app/controllers/app_navigation_controller.dart';

/// Atalhos globais da casca principal.
///
/// Valem apenas enquanto a janela principal está em foco; rotas empilhadas
/// (editores, Configurações, diálogos) mantêm seus próprios campos e atalhos.
class ShellShortcutScope extends StatelessWidget {
  const ShellShortcutScope({
    super.key,
    required this.child,
    required this.onSection,
    required this.onNewItem,
    required this.onSettings,
    required this.onSyncSettings,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.onToday,
    required this.onNextSection,
    required this.onPreviousSection,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onDecreaseMode,
    required this.onIncreaseMode,
  });

  final Widget child;
  final ValueChanged<AppSection> onSection;
  final VoidCallback onNewItem;
  final VoidCallback onSettings;
  final VoidCallback onSyncSettings;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onToday;
  final VoidCallback onNextSection;
  final VoidCallback onPreviousSection;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onDecreaseMode;
  final VoidCallback onIncreaseMode;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
            onSection(AppSection.agenda),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
            onSection(AppSection.inbox),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
            onSection(AppSection.notes),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
            onSection(AppSection.routines),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            onNewItem,
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            onSettings,
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
          shift: true,
        ): onSyncSettings,
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            onPreviousPeriod,
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            onNextPeriod,
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): onToday,
        const SingleActivator(LogicalKeyboardKey.tab, control: true):
            onNextSection,
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
          shift: true,
        ): onPreviousSection,
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
            onPreviousDay,
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            onNextDay,
        const SingleActivator(LogicalKeyboardKey.equal, control: true):
            onIncreaseMode,
        const SingleActivator(
          LogicalKeyboardKey.equal,
          control: true,
          shift: true,
        ): onIncreaseMode,
        const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true):
            onIncreaseMode,
        const SingleActivator(LogicalKeyboardKey.minus, control: true):
            onDecreaseMode,
        const SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true):
            onDecreaseMode,
        const SingleActivator(LogicalKeyboardKey.f1): () =>
            showKeyboardShortcutsDialog(context),
        const SingleActivator(LogicalKeyboardKey.slash, control: true): () =>
            showKeyboardShortcutsDialog(context),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

Future<void> showKeyboardShortcutsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppStrings.keyboardShortcutsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.keyboardShortcutsHelp,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const _ShortcutRow(
              keys: 'Ctrl + 1…4',
              descriptionKey: _ShortcutDescription.sections,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + N',
              descriptionKey: _ShortcutDescription.newItem,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + ,',
              descriptionKey: _ShortcutDescription.settings,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + Shift + S',
              descriptionKey: _ShortcutDescription.sync,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + ← / →',
              descriptionKey: _ShortcutDescription.period,
            ),
            const _ShortcutRow(
              keys: 'Alt + ← / →',
              descriptionKey: _ShortcutDescription.dayNav,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + Tab / Shift + Ctrl + Tab',
              descriptionKey: _ShortcutDescription.nextSection,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + + / -',
              descriptionKey: _ShortcutDescription.mode,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + T',
              descriptionKey: _ShortcutDescription.today,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + S / Ctrl + Enter',
              descriptionKey: _ShortcutDescription.save,
            ),
            const _ShortcutRow(
              keys: 'Ctrl + B / I / K',
              descriptionKey: _ShortcutDescription.markdown,
            ),
            const _ShortcutRow(
              keys: 'Right-click',
              descriptionKey: _ShortcutDescription.contextMenu,
            ),
            const _ShortcutRow(
              keys: 'Ctrl+click / Shift+click',
              descriptionKey: _ShortcutDescription.lineSelection,
            ),
            const _ShortcutRow(
              keys: 'Delete',
              descriptionKey: _ShortcutDescription.delete,
            ),
            const _ShortcutRow(
              keys: 'Esc',
              descriptionKey: _ShortcutDescription.escape,
            ),
            const _ShortcutRow(
              keys: 'F1 / Ctrl + /',
              descriptionKey: _ShortcutDescription.help,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppStrings.close),
        ),
      ],
    ),
  );
}

enum _ShortcutDescription {
  sections,
  newItem,
  settings,
  sync,
  period,
  nextSection,
  dayNav,
  mode,
  today,
  save,
  markdown,
  contextMenu,
  lineSelection,
  delete,
  escape,
  help,
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.descriptionKey});

  final String keys;
  final _ShortcutDescription descriptionKey;

  String get _description => switch (descriptionKey) {
    _ShortcutDescription.sections => AppStrings.shortcutSections,
    _ShortcutDescription.newItem => AppStrings.shortcutNewItem,
    _ShortcutDescription.settings => AppStrings.shortcutSettings,
    _ShortcutDescription.sync => AppStrings.shortcutSync,
    _ShortcutDescription.period =>
      '${AppStrings.shortcutPreviousPeriod} / ${AppStrings.shortcutNextPeriod}',
    _ShortcutDescription.nextSection => AppStrings.shortcutNextSection,
    _ShortcutDescription.dayNav => AppStrings.shortcutDayNavigation,
    _ShortcutDescription.mode => AppStrings.shortcutMode,
    _ShortcutDescription.today => AppStrings.shortcutToday,
    _ShortcutDescription.save => AppStrings.shortcutSave,
    _ShortcutDescription.markdown => AppStrings.shortcutMarkdown,
    _ShortcutDescription.contextMenu => AppStrings.shortcutContextMenu,
    _ShortcutDescription.lineSelection => AppStrings.shortcutLineSelection,
    _ShortcutDescription.delete => AppStrings.shortcutDelete,
    _ShortcutDescription.escape => AppStrings.close,
    _ShortcutDescription.help => AppStrings.shortcutHelp,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              keys,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(_description, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
