import 'package:offline_first_sync_queue/data/remote/firebase_service.dart';
import 'package:offline_first_sync_queue/models/note.dart';
import 'package:offline_first_sync_queue/models/sync_action.dart';
import 'package:offline_first_sync_queue/sync/sync_queue.dart';

class SyncManager {
  final SyncQueue queue;
  final FirebaseService api;

  int successCount = 0;
  int failureCount = 0;

  SyncManager({required this.queue, required this.api});

  Future<void> processQueue() async {
    final actions = queue.getAll();

    for (final action in actions) {
      await _processWithRetry(action);
    }

    print("Queue size: ${queue.getAll().length}");
    print("Success: $successCount | Fail: $failureCount");
  }

  Future<void> _processWithRetry(SyncAction action) async {
    try {
      await _execute(action);

      await queue.remove(action.id);
      successCount++;

      print("✅ Synced: ${action.id}");
    } catch (e) {
      failureCount++;
      print("❌ Failed: ${action.id} (retry: ${action.retryCount})");
      print("Queue size: ${queue.getAll().length}");

      if (action.retryCount < 1) {
        final updated = action.copyWith(retryCount: action.retryCount + 1);

        await queue.add(updated);

        print("⏳ Retrying in 2s: ${action.id}");

        await Future.delayed(const Duration(seconds: 2));

        try {
          await _execute(updated);

          await queue.remove(updated.id);

          failureCount--;
          successCount++;

          print("✅ Retry success: ${updated.id}");
        } catch (e) {
          print("❌ Retry failed permanently: ${updated.id}");
        }
      }
    }
  }

  Future<void> _execute(SyncAction action) async {
    switch (action.type) {
      case ActionType.addNote:
        final incoming = Note.fromMap(action.payload);

        final remoteNote = await api.getNoteById(incoming.id); // may be null

        if (remoteNote == null ||
            incoming.updatedAt.isAfter(remoteNote.updatedAt)) {
          
          await api.addNote(incoming.toMap());
        } else {
          print("⏭ Skipped (remote newer): ${action.id}");
        }
        break;
      case ActionType.likeNote:
        final incoming = Note.fromMap(action.payload);

        final remoteNote = await api.getNoteById(incoming.id);

        if (remoteNote == null ||
            incoming.updatedAt.isAfter(remoteNote.updatedAt)) {
          await api.likeNote(incoming.toMap());
        } else {
          print("⏭ Skipped (remote newer): ${action.id}");
        }
        break;
    }
  }
}
