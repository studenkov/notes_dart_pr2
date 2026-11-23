import 'package:flutter/material.dart';
import '../../domain/models/note.dart';
import 'note_bottom_sheet.dart';

void showNoteViewSheet(BuildContext context, Note note) {
  showNoteBottomSheet(context, note: note, isEditing: false);
}
