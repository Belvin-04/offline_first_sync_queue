import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first_sync_queue/firebase_options.dart';
import 'package:offline_first_sync_queue/note_page.dart';
import 'package:offline_first_sync_queue/providers/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  final notesBox = await Hive.openBox('notes');
  final queueBox = await Hive.openBox('queue');

  runApp(
    ProviderScope(
      overrides: [
        hiveNotesBoxProvider.overrideWithValue(notesBox),
        hiveQueueBoxProvider.overrideWithValue(queueBox),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NotesPage());
  }
}
