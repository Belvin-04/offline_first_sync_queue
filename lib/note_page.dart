import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_sync_queue/providers/note_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(notesProvider.notifier).syncNow();
            },
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) => ListView.builder(
          itemCount: notes.length,
          itemBuilder: (_, i) {
            final note = notes[i];

            return ListTile(
              title: Text(note.content),
              trailing: IconButton(
                icon: Icon(note.liked ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  ref.read(notesProvider.notifier).toggleLike(note);
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();

          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Add Note"),
              content: TextField(controller: controller),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(notesProvider.notifier).addNote(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
