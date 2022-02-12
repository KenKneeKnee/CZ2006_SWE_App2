import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/utils/events.dart';

class EventRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('events');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> addEvent(Event e) {
    return collection.add(e.toJson());
  }

  // 4
  void updateEvent(Event e, String key) async {
    await collection.doc(key).update(e.toJson());
  }

  // 5
  void deleteEvent(Event e, String key) async {
    await collection.doc(key).delete();
  }
}
