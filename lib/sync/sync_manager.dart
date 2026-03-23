import 'package:offline_first_sync_queue/data/remote/firebase_service.dart';
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
      try {
        await _execute(action);

        await queue.remove(action.id);
        successCount++;

        print("✅ Synced: ${action.id}");
      } catch (e) {
        failureCount++;

        print("❌ Failed: ${action.id}");

        if (action.retryCount < 1) {
          await Future.delayed(const Duration(seconds: 2));

          final updated = action.copyWith(retryCount: action.retryCount + 1);

          await queue.add(updated);
        }
      }
    }

    print("Queue size: ${queue.getAll().length}");
    print("Success: $successCount | Fail: $failureCount");
  }

  Future<void> _execute(SyncAction action) async {
    switch (action.type) {
      case ActionType.addNote:
        await api.addNote(action.payload);
        break;
      case ActionType.likeNote:
        await api.likeNote(action.payload);
        break;
    }
  }
}
