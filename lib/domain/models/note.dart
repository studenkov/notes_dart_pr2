class Note {
  final String id;
  final String text;
  final bool isImportant;

  const Note({
    required this.id,
    required this.text,
    this.isImportant = false,
  });

  Note copyWith({
    String? id,
    String? text,
    bool? isImportant,
  }) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
