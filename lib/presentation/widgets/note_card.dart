import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/note.dart';
import '../provider/notes_provider.dart';
import 'note_bottom_sheet.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<NotesProvider>();

    return Dismissible(
      key: ValueKey(note.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.star_outline_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'Обычный статус',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Удалить',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final wasReset = provider.resetImportant(note.id);
          final message = wasReset
              ? 'Статус важности снят'
              : 'Заметка уже имеет обычный статус';

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return true;
        }
        return false;
      },
      onDismissed: (_) {
        provider.deleteNote(note.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Заметка удалена'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: note.isImportant ? 2 : 0,
        color: note.isImportant
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: note.isImportant
                ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showNoteBottomSheet(context, note: note, isEditing: false),
          onDoubleTap: () => provider.toggleImportant(note.id),
          onLongPress: () => showNoteBottomSheet(context, note: note, isEditing: true),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (note.isImportant) ...[
                  Icon(
                    Icons.star_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    note.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: note.isImportant
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: note.isImportant
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
