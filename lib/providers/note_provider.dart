import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first_sync_queue/data/local/hive_service.dart';
import 'package:offline_first_sync_queue/data/remote/firebase_service.dart';
import 'package:offline_first_sync_queue/models/note.dart';
import 'package:offline_first_sync_queue/repository/note_repository.dart';
import 'package:offline_first_sync_queue/sync/sync_manager.dart';
import 'package:offline_first_sync_queue/sync/sync_queue.dart';
import 'package:uuid/uuid.dart';

final hiveNotesBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final hiveQueueBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError();
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService(ref.read(hiveNotesBoxProvider));
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(FirebaseFirestore.instance);
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(ref.read(hiveQueueBoxProvider));
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(
    queue: ref.read(syncQueueProvider),
    api: ref.read(firebaseServiceProvider),
  );
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(
    local: ref.read(hiveServiceProvider),
    remote: ref.read(firebaseServiceProvider),
    queue: ref.read(syncQueueProvider),
  );
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NoteRepository repo;
  late final SyncManager syncManager;

  @override
  Future<List<Note>> build() async {
    repo = ref.read(noteRepositoryProvider);
    syncManager = ref.read(syncManagerProvider);

    return repo.getNotes();
  }

  Future<void> addNote(String text) async {
    final note = Note(
      id: const Uuid().v4(),
      content: text,
      liked: false,
      updatedAt: DateTime.now(),
    );

    await repo.addNote(note);

    state = AsyncData([...state.value ?? [], note]);
  }

  Future<void> toggleLike(Note note) async {
    await repo.likeNote(note);

    final updated = note.copyWith(liked: !note.liked);

    state = AsyncData([
      for (final n in state.value ?? [])
        if (n.id == note.id) updated else n,
    ]);
  }

  Future<void> syncNow() async {
    await syncManager.processQueue();

    // reload after sync
    final fresh = await repo.getNotes();
    state = AsyncData(fresh);
  }
}
