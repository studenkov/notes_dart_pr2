import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _currentEditingId;
  NotesProvider? _notesProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<NotesProvider>();
    if (_notesProvider != provider) {
      _notesProvider?.removeListener(_onNotesChanged);
      _notesProvider = provider;
      _notesProvider?.addListener(_onNotesChanged);
    }
  }

  @override
  void dispose() {
    _notesProvider?.removeListener(_onNotesChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    if (!mounted) return;
    final editingNote = _notesProvider?.editingNote;
    if (editingNote != null && editingNote.id != _currentEditingId) {
      _currentEditingId = editingNote.id;
      _controller.text = editingNote.text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _focusNode.requestFocus();
    } else if (editingNote == null && _currentEditingId != null) {
      _currentEditingId = null;
      _controller.clear();
    }
  }

  void _onSave(BuildContext context) {
    final provider = context.read<NotesProvider>();
    final success = provider.saveNote(_controller.text);

    if (success) {
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _onCancel(BuildContext context) {
    context.read<NotesProvider>().cancelEditing();
    _controller.clear();
    _focusNode.unfocus();
  }

  void _onDelete(BuildContext context, String id) {
    context.read<NotesProvider>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      body: SafeArea(
        top: false,
        bottom: false,
        left: true,
        right: true,
        child: Consumer<NotesProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 3,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Введите текст заметки',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (provider.isEditing) ...[
                            OutlinedButton(
                              onPressed: () => _onCancel(context),
                              child: const Text('Отмена'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _onSave(context),
                              label: Text(
                                provider.isEditing
                                    ? 'Сохранить изменения'
                                    : 'Сохранить',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: provider.notes.isEmpty
                      ? Center(
                          child: Text(
                            'Заметок пока нет',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 16 + MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: provider.notes.length,
                          itemBuilder: (context, index) {
                            final note = provider.notes[index];
                            final isEditingNote =
                                provider.editingNote?.id == note.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: isEditingNote
                                    ? BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                    : BorderSide(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          note.text,
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Редактировать',
                                      onPressed: () => context
                                          .read<NotesProvider>()
                                          .startEditing(note),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: theme.colorScheme.error,
                                      ),
                                      tooltip: 'Удалить',
                                      onPressed: () =>
                                          _onDelete(context, note.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
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
