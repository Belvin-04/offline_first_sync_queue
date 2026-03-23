import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first_sync_queue/models/sync_action.dart';

class SyncQueue {
  final Box box;

  SyncQueue(this.box);

  Future<void> add(SyncAction action) async {
    await box.put(action.id, action.toMap());
  }

  List<SyncAction> getAll() {
    return box.values
        .map((e) => SyncAction.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> remove(String id) async {
    await box.delete(id);
  }
}
