import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => NotesCubit(),
        child: const NotesScreen(),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _currentEditingId;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    final cubit = context.read<NotesCubit>();
    final success = cubit.saveNote(_controller.text);

    if (success) {
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  void _onCancel(BuildContext context) {
    context.read<NotesCubit>().cancelEditing();
    _controller.clear();
    _focusNode.unfocus();
  }

  void _onDelete(BuildContext context, String id) {
    context.read<NotesCubit>().deleteNote(id);
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
        child: BlocConsumer<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state.editingNote != null &&
                state.editingNote!.id != _currentEditingId) {
              _currentEditingId = state.editingNote!.id;
              _controller.text = state.editingNote!.text;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
              _focusNode.requestFocus();
            } else if (state.editingNote == null && _currentEditingId != null) {
              _currentEditingId = null;
              _controller.clear();
            }
          },
          builder: (context, state) {
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
                        decoration: InputDecoration(
                          hintText: 'Введите текст заметки',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (state.isEditing) ...[
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
                                state.isEditing
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
                  child: state.notes.isEmpty
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
                          itemCount: state.notes.length,
                          itemBuilder: (context, index) {
                            final note = state.notes[index];
                            final isEditingNote =
                                state.editingNote?.id == note.id;

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
                                      child: Text(
                                        note.text,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Редактировать',
                                      onPressed: () => context
                                          .read<NotesCubit>()
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
    home: BlocProvider(create: (_) => NotesCubit(), child: const NotesScreen()),
  );
}
