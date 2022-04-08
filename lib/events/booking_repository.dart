import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';

class BookingRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('bookings');

  final EventRepository eventRepository = EventRepository();

  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 4
  void addBooking(String uid, String key, bool active) async {
    collection.add({
      "userId": uid,
      "eventId": key,
      "active": active,
    });
    /*
        .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully Joined')))
      }).catchError((onError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(onError)));
      })

     */
  }

  // 5
  void deleteBooking(String uid, String key) async {
    collection
        .where("userId", isEqualTo: uid)
        .where("eventId", isEqualTo: key)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        collection.doc(result.id).delete();
      });
    });
    // await collection.doc(key).delete();
  }

  void completeBooking(String uid,String key) async {
    collection.where("userId", isEqualTo: uid).where("eventId", isEqualTo: key).get().then((value) {
      value.docs.forEach((result) {
        collection.doc(result.id).update({"active": false});
      });
    });
  }

  /// Checks the Bookings DB
  /// Returns -1 if user is not logged in
  /// Returns 0 if user is logged in but has not joined event
  /// Returns 1 if user is logged in and has joined event already
  Future<int> checkUser(String uid, String key) async {
    int res = 0;
    if (uid == null) {
      return -1;
    }
    await collection
        .where("userId", isEqualTo: uid)
        .where("eventId", isEqualTo: key)
        .get()
        .then((value) {
      res = value.docs.length;
    });
    return res;
  }

  void retrieveUsers(String key) async {
    collection.where("eventId", isEqualTo: key).get();
  }

  Future<QuerySnapshot> retrieveActiveEvents(String uid) async {
    return collection
        .where("active", isEqualTo: true)
        .where('userId', isEqualTo: uid)
        .get();
  }

  Future<QuerySnapshot> retrievePastEvents(String uid) async {
    return collection
        .where("active", isEqualTo: false)
        .where('userId', isEqualTo: uid)
        .get();
  }
}
