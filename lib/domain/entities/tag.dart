/// Paleta de identificação de uma tag, derivada do `ColorScheme` ativo.
enum TagTone { primary, secondary, tertiary, primarySoft, secondarySoft }

/// Tag compartilhada por eventos e tarefas.
final class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.tone,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final TagTone tone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Tag copyWith({
    String? name,
    TagTone? tone,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) => Tag(
    id: id,
    name: name ?? this.name,
    tone: tone ?? this.tone,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: identical(deletedAt, _unset)
        ? this.deletedAt
        : deletedAt as DateTime?,
  );

  static const Object _unset = Object();

  @override
  String toString() => 'Tag(id: $id, name: $name, tone: ${tone.name})';
}
