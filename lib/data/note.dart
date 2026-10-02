class Note {
  final String id;
  final String text;

  const Note({required this.id, required this.text});

  Note copyWith({String? id, String? text}) {
    return Note(id: id ?? this.id, text: text ?? this.text);
  }
}
