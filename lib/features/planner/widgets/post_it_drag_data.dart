import '../../../domain/entities/post_it.dart';

/// Dados carregados durante o arraste de um post-it.
final class PostItDragData {
  const PostItDragData(this.postIt);

  final PostIt postIt;
}
