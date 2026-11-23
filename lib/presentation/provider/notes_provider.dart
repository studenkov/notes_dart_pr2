import 'package:flutter/foundation.dart';
import '../../domain/models/note.dart';

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes;
  Note? _editingNote;

  NotesProvider({List<Note>? initialNotes}) : _notes = initialNotes ?? [];

  List<Note> get notes => List.unmodifiable(_notes);
  Note? get editingNote => _editingNote;
  bool get isEditing => _editingNote != null;

  bool saveNote(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return false;

    if (_editingNote != null) {
      final index = _notes.indexWhere((note) => note.id == _editingNote!.id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(text: trimmed);
      }
      _editingNote = null;
    } else {
      final newNote = Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: trimmed,
      );
      _notes.insert(0, newNote);
    }

    notifyListeners();
    return true;
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
}
