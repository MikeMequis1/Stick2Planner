/// Ações registradas no histórico de um post-it.
enum PostItHistoryAction {
  created,
  updated,
  moved,
  resized,
  reordered,
  statusChanged,
  deleted,
  rolloverAdvanced,
  manualPostponed,
  noteLinked,
  restored,
}

/// Registro imutável de auditoria de um post-it.
///
/// Preserva histórico sem duplicar o post-it em si.
final class PostItHistoryEntry {
  const PostItHistoryEntry({
    required this.id,
    required this.postItId,
    required this.action,
    required this.createdAt,
    this.fromValue,
    this.toValue,
  });

  final String id;
  final String postItId;
  final PostItHistoryAction action;
  final String? fromValue;
  final String? toValue;
  final DateTime createdAt;
}
