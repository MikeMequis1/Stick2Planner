import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// Parâmetros nomeados não podem usar campos privados como initializing formals.
// ignore_for_file: prefer_initializing_formals

import '../../core/clock.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

/// Entrada de linha usada pelo editor; [id] preserva linhas existentes.
final class NoteLineInput {
  const NoteLineInput({
    this.id,
    required this.text,
    this.isChecked = false,
  });

  final String? id;
  final String text;
  final bool isChecked;
}

enum NoteValidationError { emptyTitle }

final class NoteValidationException implements Exception {
  const NoteValidationException(this.errors);

  final List<NoteValidationError> errors;
}

/// CRUD e estado do caderno privado.
final class NotesController extends ChangeNotifier {
  NotesController({
    required NoteRepository noteRepository,
    Clock clock = const SystemClock(),
  }) : _noteRepository = noteRepository,
       _clock = clock;

  final NoteRepository _noteRepository;
  final Clock _clock;

  List<Note> _notes = const [];
  bool _isLoading = true;
  String? _error;
  Future<void> _mutationQueue = Future<void>.value();

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Note? findById(String id) {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  Future<void> initialize() async {
    try {
      _notes = await _noteRepository.loadAll();
      _error = null;
    } on Object {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _notes = await _noteRepository.loadAll();
      _error = null;
    } on Object {
      _error = 'load_failed';
    }
    notifyListeners();
  }

  Future<Note> createNote({
    required String title,
    required NoteType type,
    String? markdown,
    List<NoteLineInput> lines = const [],
  }) {
    return _exclusive(() async {
      final now = _clock.now().toUtc();
      final id = const Uuid().v4();
      final isText = type == NoteType.text;
      final note = Note(
        id: id,
        title: _validatedTitle(title),
        type: type,
        markdown: isText ? _normalizeMarkdown(markdown, lines) : null,
        lines: isText ? const [] : _buildLines(id, lines),
        createdAt: now,
        updatedAt: now,
      );
      await _noteRepository.save(note);
      await _load();
      return note;
    });
  }

  Future<Note> updateNote(
    Note existing, {
    required String title,
    required NoteType type,
    String? markdown,
    List<NoteLineInput> lines = const [],
  }) {
    return _exclusive(() async {
      final isText = type == NoteType.text;
      final updated = Note(
        id: existing.id,
        title: _validatedTitle(title),
        type: type,
        markdown: isText ? _normalizeMarkdown(markdown, lines) : null,
        lines: isText ? const [] : _buildLines(existing.id, lines),
        createdAt: existing.createdAt,
        updatedAt: _clock.now().toUtc(),
      );
      await _noteRepository.save(updated);
      await _load();
      return updated;
    });
  }

  Future<void> setLineChecked(
    Note note,
    String lineId,
    bool checked,
  ) {
    return _exclusive(() async {
      final updated = Note(
        id: note.id,
        title: note.title,
        type: note.type,
        markdown: note.markdown,
        lines: [
          for (final line in note.lines)
            line.id == lineId
                ? NoteLine(
                    id: line.id,
                    noteId: line.noteId,
                    position: line.position,
                    text: line.text,
                    isChecked: checked,
                  )
                : line,
        ],
        createdAt: note.createdAt,
        updatedAt: _clock.now().toUtc(),
      );
      await _noteRepository.save(updated);
      await _load();
    });
  }

  Future<void> deleteNote(Note note) {
    return _exclusive(() async {
      await _noteRepository.softDelete(
        id: note.id,
        deletedAt: _clock.now().toUtc(),
      );
      await _load();
    });
  }

  Future<void> _load() async {
    _notes = await _noteRepository.loadAll();
    _error = null;
    notifyListeners();
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _mutationQueue.then((_) => action());
    _mutationQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  static String _validatedTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const NoteValidationException([
        NoteValidationError.emptyTitle,
      ]);
    }
    return trimmed;
  }

  static List<NoteLine> _buildLines(
    String noteId,
    List<NoteLineInput> inputs,
  ) {
    final result = <NoteLine>[];
    for (final input in inputs) {
      final text = input.text.trim();
      if (text.isEmpty) continue;
      result.add(
        NoteLine(
          id: input.id ?? const Uuid().v4(),
          noteId: noteId,
          position: result.length,
          text: text,
          isChecked: input.isChecked,
        ),
      );
    }
    return result;
  }

  /// Mantém o Markdown exatamente como escrito (apenas normaliza quebras de
  /// linha). Aceita linhas como fallback para chamadas legadas.
  static String _normalizeMarkdown(
    String? markdown,
    List<NoteLineInput> lines,
  ) {
    final source = markdown ?? lines.map((line) => line.text).join('\n');
    return source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }
}
