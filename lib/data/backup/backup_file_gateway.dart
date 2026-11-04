import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Conteúdo de um arquivo escolhido pelo usuário.
final class BackupFile {
  const BackupFile({required this.name, required this.contents});

  final String name;
  final String contents;
}

/// Abstração de arquivos para permitir testes sem plugin nativo.
abstract interface class BackupFileGateway {
  /// Abre o seletor de destino; devolve o caminho salvo ou `null` se cancelado.
  Future<String?> saveBackup({
    required String fileName,
    required String contents,
  });

  /// Abre o seletor de origem; devolve o arquivo ou `null` se cancelado.
  Future<BackupFile?> pickBackup();
}

final class FilePickerBackupGateway implements BackupFileGateway {
  const FilePickerBackupGateway({this.maxBytes = 64 * 1024 * 1024});

  final int maxBytes;

  @override
  Future<String?> saveBackup({
    required String fileName,
    required String contents,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(contents));
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
      dialogTitle: fileName,
    );
    return uri?.toString();
  }

  @override
  Future<BackupFile?> pickBackup() async {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      throw StateError('Arquivo de backup muito grande.');
    }
    return BackupFile(name: file.name, contents: utf8.decode(bytes));
  }
}
