import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/note.dart';
import '../provider/notes_provider.dart';

void showNoteBottomSheet(
  BuildContext context, {
  Note? note,
  bool isEditing = false,
}) {
  final provider = context.read<NotesProvider>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (modalContext) => ChangeNotifierProvider.value(
      value: provider,
      child: NoteBottomSheet(note: note, startInEdit: isEditing),
    ),
  );
}

class NoteBottomSheet extends StatefulWidget {
  final Note? note;
  final bool startInEdit;

  const NoteBottomSheet({
    super.key,
    this.note,
    this.startInEdit = false,
  });

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  late bool _isEditing;
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  bool get _isCreating => widget.note == null;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEdit || _isCreating;
    _controller = TextEditingController(text: widget.note?.text ?? '');
    if (_isEditing) {
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _focusNode.requestFocus();
  }

  void _onSave() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<NotesProvider>();
    if (_isCreating) {
      provider.addNote(text);
    } else {
      provider.updateNote(widget.note!.id, text);
    }
    Navigator.pop(context);
  }

  void _onCancel() {
    if (!_isCreating && widget.note != null && !widget.startInEdit) {
      setState(() {
        _isEditing = false;
        _controller.text = widget.note!.text;
      });
      _focusNode.unfocus();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final String title = _isEditing
        ? (_isCreating ? 'Новая заметка' : 'Редактирование заметки')
        : 'Просмотр заметки';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: bottomInset + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.note?.isImportant == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Важная',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: !_isEditing,
            showCursor: _isEditing,
            enableInteractiveSelection: true,
            minLines: 4,
            maxLines: 6,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Введите текст заметки...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isEditing ? _onCancel : () => Navigator.pop(context),
                child: Text(_isEditing ? 'Отмена' : 'Закрыть'),
              ),
              const SizedBox(width: 8),
              if (_isEditing)
                FilledButton.icon(
                  onPressed: _onSave,
                  icon: Icon(
                    _isCreating ? Icons.add_rounded : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(_isCreating ? 'Создать' : 'Сохранить'),
                )
              else
                FilledButton.icon(
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Редактировать'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
