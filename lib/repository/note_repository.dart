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
    return await local.getNotes();
  }

  Future<List<Note>> syncAndFetch() async {
    try {
      final remoteNotes = await remote.fetchNotes();

      final remoteIds = remoteNotes.map((e) => e.id).toSet();

      final localNotes = await local.getNotes();
      final localIds = localNotes.map((e) => e.id).toSet();

      final localMap = {for (final note in localNotes) note.id: note};

      final queuedActions = queue.getAll();
      final pendingIds = queuedActions
          .map((a) => a.payload['id'] as String)
          .toSet();

      for (final remoteNote in remoteNotes) {
        final localNote = localMap[remoteNote.id];

        if (localNote == null ||
            remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
          await local.saveNote(remoteNote);
        }
      }

      final idsToDelete = localIds.difference(remoteIds).difference(pendingIds);

      for (final id in idsToDelete) {
        await local.deleteNote(id);
      }

      print("🔄 Full sync + fetch complete");

      return await local.getNotes();
    } catch (e) {
      print("⚠️ syncAndFetch failed: $e");
      return await local.getNotes();
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
