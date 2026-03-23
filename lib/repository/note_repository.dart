import 'package:offline_first_sync_queue/data/local/hive_service.dart';
import 'package:offline_first_sync_queue/data/remote/firebase_service.dart';
import 'package:offline_first_sync_queue/models/note.dart';
import 'package:offline_first_sync_queue/models/sync_action.dart';
import 'package:offline_first_sync_queue/sync/sync_queue.dart';

class NoteRepository {
  final HiveService local;
  final FirebaseService remote;
  final SyncQueue queue;

  NoteRepository({
    required this.local,
    required this.remote,
    required this.queue,
  });

  Future<List<Note>> getNotes() async {
    final localNotes = await local.getNotes();

    // background refresh
    _refreshFromServer();

    return localNotes;
  }

  Future<void> _refreshFromServer() async {
    try {
      final remoteNotes = await remote.fetchNotes();

      for (final note in remoteNotes) {
        await local.saveNote(note);
      }

      print("🔄 Refreshed from server");
    } catch (e) {
      print("⚠️ Refresh failed: $e");
    }
  }

  Future<void> addNote(Note note) async {
    await local.saveNote(note);

    final action = SyncAction(
      id: "add-${note.id}",
      type: ActionType.addNote,
      payload: note.toMap(),
    );

    await queue.add(action);
  }

  Future<void> likeNote(Note note) async {
    final updated = note.copyWith(
      liked: !note.liked,
      updatedAt: DateTime.now(),
    );

    await local.saveNote(updated);

    final action = SyncAction(
      id: "like-${note.id}",
      type: ActionType.likeNote,
      payload: updated.toMap(),
    );

    await queue.add(action);
  }
}
