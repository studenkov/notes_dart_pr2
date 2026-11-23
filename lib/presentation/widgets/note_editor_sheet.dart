import 'package:flutter/material.dart';
import '../../domain/models/note.dart';
import 'note_bottom_sheet.dart';

void showNoteEditorSheet(BuildContext context, {Note? initialNote}) {
  showNoteBottomSheet(context, note: initialNote, isEditing: true);
}
