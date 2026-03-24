import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first_sync_queue/models/note.dart';

class HiveService {
  final Box notesBox;

  HiveService(this.notesBox);

  Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note.toMap());
  }

  Future<List<Note>> getNotes() async {
    return notesBox.values
        .map((e) => Note.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }
}
