import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/note.dart';

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

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState());

  bool saveNote(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return false;

    if (state.editingNote != null) {
      final updatedNotes = state.notes.map((note) {
        return note.id == state.editingNote!.id
            ? note.copyWith(text: trimmed)
            : note;
      }).toList();

      emit(state.copyWith(notes: updatedNotes, editingNote: () => null));
    } else {
      final newNote = Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: trimmed,
      );
      emit(state.copyWith(notes: [newNote, ...state.notes]));
    }

    return true;
  }

  void startEditing(Note note) {
    emit(state.copyWith(editingNote: () => note));
  }

  void cancelEditing() {
    emit(state.copyWith(editingNote: () => null));
  }

  void deleteNote(String id) {
    final updatedNotes = state.notes.where((note) => note.id != id).toList();
    emit(
      state.copyWith(
        notes: updatedNotes,
        editingNote: state.editingNote?.id == id ? () => null : null,
      ),
    );
  }
}
