import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/sportevent.dart';

class EventRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('events');
  // 2

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  Future<DocumentReference> addEvent(SportEvent e) {
    return collection.add(e.toJson());
  }

  // 4
  void updateEvent(SportEvent e, String key) async {
    await collection.doc(key).update(e.toJson());
  }

  // 5
  void deleteEvent(SportEvent e, String key) async {
    await collection.doc(key).delete();
  }

  void completeEvent(String key) async {
    collection.where("eventId", isEqualTo: key).get().then((value) {
      value.docs.forEach((result) {
        collection.doc(result.id).update({"active": false});
      });
    });
  }

}
