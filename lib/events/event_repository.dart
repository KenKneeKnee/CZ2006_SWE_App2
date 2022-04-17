import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/sportevent.dart';

/// Class that manages the SportEvents in the Firebase.
/// Provides the following functionlities:
/// 1. Returns a stream of the event collection.
/// 2. Adds a newly created SportEvent to the collection.
/// 3. Updates an existing SportEvent in the collection.
/// 4. Deletes an existing SportEvent from the collection.
class EventRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('events');

  /// 1. Returns a stream of the event collection for StreamBuilder.
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  /// 2. Adds a newly created SportEvent to the collection.
  /// Uses a SportEvent object as a parameter.
  Future<DocumentReference> addEvent(SportEvent e) {
    return collection.add(e.toJson());
  }

  /// 3. Updates an existing SportEvent in the collection.
  /// Uses the updated SportEvent object and the event ID of the existing
  /// SportEvent as parameters.
  void updateEvent(SportEvent e, String key) async {
    await collection.doc(key).update(e.toJson());
  }

  /// 4. Deletes an existing SportEvent from the collection.
  /// Uses the event ID as a parameter.
  void deleteEvent(SportEvent e, String key) async {
    await collection.doc(key).delete();
  }


}
