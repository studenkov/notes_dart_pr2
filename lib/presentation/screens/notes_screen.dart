import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';
import '../widgets/note_bottom_sheet.dart';
import '../widgets/note_card.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        centerTitle: true,
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          if (provider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Заметок пока нет',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 88 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              return NoteCard(note: provider.notes[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showNoteBottomSheet(context, isEditing: true),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новая заметка'),
      ),
    );
  }
}

@Preview(name: 'Notes Preview')
Widget notesScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const NotesScreen(),
    ),
  );
}
