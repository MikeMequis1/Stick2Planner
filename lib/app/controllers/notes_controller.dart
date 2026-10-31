import 'package:flutter/foundation.dart';

// Parâmetros nomeados não podem usar campos privados como initializing formals.
// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

/// Carrega e mantém as notas disponíveis para a UI.
final class NotesController extends ChangeNotifier {
  NotesController({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  final NoteRepository _noteRepository;

  List<Note> _notes = const [];
  bool _isLoading = true;
  String? _error;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
