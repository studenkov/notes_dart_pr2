import 'package:flutter/foundation.dart';
import '../../domain/models/note.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes;
  Note? _editingNote;

  NotesProvider({List<Note>? initialNotes}) : _notes = initialNotes ?? [];

  List<Note> get notes => List.unmodifiable(_notes);
  Note? get editingNote => _editingNote;
  bool get isEditing => _editingNote != null;

  bool addNote(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return false;

    final newNote = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: trimmed,
    );
    _notes.insert(0, newNote);
    notifyListeners();
    return true;
  }

  bool updateNote(String id, String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return false;

    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) return false;

    _notes[index] = _notes[index].copyWith(text: trimmed);
    if (_editingNote?.id == id) {
      _editingNote = null;
    }
    notifyListeners();
    return true;
  }

  bool saveNote(String rawText) {
    if (_editingNote != null) {
      return updateNote(_editingNote!.id, rawText);
    }
    return addNote(rawText);
  }

  void startEditing(Note note) {
    _editingNote = note;
    notifyListeners();
  }

  void cancelEditing() {
    _editingNote = null;
    notifyListeners();
  }

  void deleteNote(String id) {
    final hadEditing = _editingNote?.id == id;
    _notes.removeWhere((note) => note.id == id);
    if (hadEditing) {
      _editingNote = null;
    }
    notifyListeners();
  }

  void toggleImportant(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isImportant: !_notes[index].isImportant,
      );
      notifyListeners();
    }
  }

  bool resetImportant(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1 && _notes[index].isImportant) {
      _notes[index] = _notes[index].copyWith(isImportant: false);
      notifyListeners();
      return true;
    }
    return false;
  }
}
