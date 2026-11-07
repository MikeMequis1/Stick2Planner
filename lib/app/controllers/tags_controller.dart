// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

/// CRUD e estado das tags compartilhadas por eventos e tarefas.
final class TagsController extends ChangeNotifier {
  TagsController({
    required TagRepository repository,
    required Clock clock,
    Uuid? uuid,
  }) : _repository = repository,
       _clock = clock,
       _uuid = uuid ?? const Uuid();

  final TagRepository _repository;
  final Clock _clock;
  final Uuid _uuid;

  List<Tag> _tags = const [];
  bool _loading = true;
  String? _error;

  /// Chamado após excluir uma tag para limpar associações nos post-its.
  Future<void> Function(String tagId)? onDeleted;

  List<Tag> get tags => List.unmodifiable(_tags);
  bool get isLoading => _loading;
  String? get error => _error;

  Tag? byId(String id) {
    for (final tag in _tags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  Map<String, Tag> get byIdMap => {for (final tag in _tags) tag.id: tag};

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    try {
      _tags = await _repository.loadAll();
      _error = null;
    } on Object {
      _error = 'load_failed';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Tag> create({required String name, required TagTone tone}) async {
    final normalized = _validatedName(name);
    _ensureUnique(normalized);
    final now = _clock.now().toUtc();
    final tag = Tag(
      id: _uuid.v4(),
      name: normalized,
      tone: tone,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(tag);
    await refresh();
    return tag;
  }

  Future<void> update(
    Tag tag, {
    required String name,
    required TagTone tone,
  }) async {
    final normalized = _validatedName(name);
    _ensureUnique(normalized, ignoreId: tag.id);
    await _repository.save(
      tag.copyWith(
        name: normalized,
        tone: tone,
        updatedAt: _clock.now().toUtc(),
      ),
    );
    await refresh();
  }

  Future<void> delete(Tag tag) async {
    await _repository.softDelete(id: tag.id, deletedAt: _clock.now().toUtc());
    await onDeleted?.call(tag.id);
    await refresh();
  }

  String _validatedName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      throw const FormatException('tag_empty_name');
    }
    if (name.length > 40) {
      throw const FormatException('tag_name_too_long');
    }
    return name;
  }

  void _ensureUnique(String name, {String? ignoreId}) {
    final key = name.toLowerCase();
    for (final tag in _tags) {
      if (tag.id == ignoreId) continue;
      if (tag.name.toLowerCase() == key) {
        throw const FormatException('tag_duplicate_name');
      }
    }
  }
}
