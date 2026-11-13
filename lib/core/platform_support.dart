import 'dart:io';

import 'package:flutter/foundation.dart';

/// Recursos que dependem de implementações nativas por plataforma.
///
/// O aplicativo continua offline-first em desktop; apenas integrações
/// opcionais (notificações, sync em segundo plano e leitor de QR) ficam
/// restritas às plataformas que possuem plugin nativo.
bool get isDesktopRuntime =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

/// `mobile_scanner` oferece câmera em Android, iOS, macOS e web.
bool get supportsQrScanning =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

/// Notificações locais são agendadas pelo canal Android já existente.
bool get supportsAndroidNotifications => !kIsWeb && Platform.isAndroid;

/// WorkManager periódico é exclusivo do Android neste projeto.
bool get supportsBackgroundSync => !kIsWeb && Platform.isAndroid;

/// Indica ponteiro/atalhos de desktop sem depender de `dart:io`.
///
/// Em testes de widget `defaultTargetPlatform` permanece Android, preservando
/// os gestos móveis existentes.
bool get isDesktopTargetPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS);
