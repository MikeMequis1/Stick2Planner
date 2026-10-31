/// Formato da nota.
enum NoteType { text, checklist }

/// Nota privada composta por linhas ordenadas.
final class Note {
  const Note({
    required this.id,
    required this.title,
    required this.type,
    required this.lines,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final NoteType type;
  final List<NoteLine> lines;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  String get plainText => lines.map((line) => line.text).join('\n');
}

/// Linha de nota ou item de checklist.
final class NoteLine {
  const NoteLine({
    required this.id,
    required this.noteId,
    required this.position,
    required this.text,
    this.isChecked = false,
  });

  final String id;
  final String noteId;
  final int position;
  final String text;
  final bool isChecked;
}
