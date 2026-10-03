import 'package:notes_dart_pr2/domain/models/note.dart';

class NotesState {
  final List<Note> notes;
  final Note? editingNote;

  const NotesState({this.notes = const [], this.editingNote});

  bool get isEditing => editingNote != null;

  NotesState copyWith({List<Note>? notes, Note? Function()? editingNote}) {
    return NotesState(
      notes: notes ?? this.notes,
      editingNote: editingNote != null ? editingNote() : this.editingNote,
    );
  }
}
