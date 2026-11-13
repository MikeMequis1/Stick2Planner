import 'package:flutter/material.dart';

import '../../core/platform_support.dart';

/// Largura máxima de folhas modais em telas largas.
///
/// No celular a folha continua com o comportamento padrão; no desktop ela fica
/// centralizada e legível em vez de esticar pela janela inteira.
const double adaptiveSheetMaxWidth = 720;

BoxConstraints? adaptiveSheetConstraints(BuildContext context) {
  if (!isDesktopTargetPlatform) return null;
  final width = MediaQuery.sizeOf(context).width;
  return BoxConstraints(
    maxWidth: width < adaptiveSheetMaxWidth ? width : adaptiveSheetMaxWidth,
  );
}
