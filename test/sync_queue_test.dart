import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first_sync_queue/models/sync_action.dart';
import 'package:offline_first_sync_queue/sync/sync_queue.dart';


void main() {
  late Box box;
  late SyncQueue queue;

  setUp(() async {
    Hive.init('./test_hive');

    box = await Hive.openBox('test_queue');
    queue = SyncQueue(box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  test('Queue should not create duplicates for same id', () async {
    final action1 = SyncAction(
      id: 'add-123',
      type: ActionType.addNote,
      payload: {'id': '123', 'content': 'Hello'},
    );

    final action2 = SyncAction(
      id: 'add-123', // SAME ID
      type: ActionType.addNote,
      payload: {'id': '123', 'content': 'Updated'},
    );

    await queue.add(action1);
    await queue.add(action2); // should overwrite

    final actions = queue.getAll();

    expect(actions.length, 1);
    expect(actions.first.payload['content'], 'Updated');
  });
}