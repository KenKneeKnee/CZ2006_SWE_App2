import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';

/// Class that manages the SportEvent bookings of users in the Firebase.
/// Provides the following functionalities:
/// 1. Returns a stream of the booking collection
/// 2. Add a booking to the collection
/// 3. Remove a booking from the collection
/// 4. Update the status of the booking upon completion of a SportEvent
/// 5. Determine the status of current user for a SportEvent
/// 6. Find all users that have joined a particular SportEvent
/// 7. Returns bookings for a user for all Active Events
/// 8. Returns bookings for a user for all Completed Events

class BookingRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('bookings');

  final EventRepository eventRepository = EventRepository();

  /// 1. Returns a stream of the booking collection for StreamBuilder
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  /// 2. Add a booking to the collection.
  /// Takes in user ID, event ID, and event status as parameters.
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

  /// 3. Remove a booking from the collection.
  /// Takes in user ID and event ID as parameters.
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

  /// 4. Update the status of the booking upon completion of a SportEvent
  /// Takes in user ID and event ID as parameters.
  /// Sets the status from true to false.
  void completeBooking(String uid,String key) async {
    collection.where("userId", isEqualTo: uid).where("eventId", isEqualTo: key).get().then((value) {
      value.docs.forEach((result) {
        collection.doc(result.id).update({"active": false});
      });
    });
  }

  /// 5. Determine the status of current user for a SportEvent
  /// Takes in user ID and event ID as parameters.
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

  /// 6. Find all users that have joined a particular SportEvent.
  /// Takes in event ID as a parameter.
  void retrieveUsers(String key) async {
    collection.where("eventId", isEqualTo: key).get();
  }

  /// 7. Returns bookings for a user for all Active Events.
  /// Takes in user ID as a parameter.
  Future<QuerySnapshot> retrieveActiveEvents(String uid) async {
    return collection
        .where("active", isEqualTo: true)
        .where('userId', isEqualTo: uid)
        .get();
  }

  /// 8. Returns bookings for a user for all Completed Events.
  /// Takes in user ID as a parameter.
  Future<QuerySnapshot> retrievePastEvents(String uid) async {
    return collection
        .where("active", isEqualTo: false)
        .where('userId', isEqualTo: uid)
        .get();
  }
}
