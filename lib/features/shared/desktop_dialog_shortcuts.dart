import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/platform_support.dart';

/// Atalhos padrão para diálogos no desktop.
///
/// `Esc` cancela e `Ctrl+Enter` confirma. Em mobile o conteúdo fica intacto.
class DesktopDialogShortcuts extends StatelessWidget {
  const DesktopDialogShortcuts({
    super.key,
    required this.child,
    this.onConfirm,
    this.onCancel,
  });

  final Widget child;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    if (!isDesktopTargetPlatform) return child;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape):
            onCancel ?? () => Navigator.of(context).maybePop(),
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            onConfirm ?? () {},
      },
      child: child,
    );
  }
}
