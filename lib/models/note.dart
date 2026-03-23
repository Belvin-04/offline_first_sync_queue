class Note {
  final String id;
  final String content;
  final bool liked;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.content,
    required this.liked,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? content,
    bool? liked,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      liked: liked ?? this.liked,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'liked': liked,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      liked: map['liked'],
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
