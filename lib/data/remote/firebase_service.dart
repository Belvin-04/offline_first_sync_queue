import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offline_first_sync_queue/models/note.dart';

class FirebaseService {
  final FirebaseFirestore firestore;

  FirebaseService(this.firestore);

  Future<void> addNote(Map<String, dynamic> data) async {
    await firestore.collection('notes').doc(data['id']).set(data);
  }

  Future<void> likeNote(Map<String, dynamic> data) async {
    await firestore.collection('notes').doc(data['id']).update({
      'liked': data['liked'],
      'updatedAt': data['updatedAt'],
    });
  }

  Future<List<Note>> fetchNotes() async {
    final snapshot = await firestore.collection('notes').get();

    return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
  }
}
