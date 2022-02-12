import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/utils/events.dart';

class EventRepository {
  // 1
  final CollectionReference collection = FirebaseFirestore.instance.collection('events');
  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }
  // 3
  Future<DocumentReference> addEvent(Event e) {
    return collection.add(e.toJson());
  }
  // 4
  void updateEvent(Event e) async {
    await collection.doc(e.id).update(e.toJson());
  }
  // 5
  void deleteEvent(Event e) async {
    await collection.doc(e.id).delete();
  }
}
