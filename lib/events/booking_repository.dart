import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('bookings');

  // 2
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 4
  void addBooking(String uid, String key) async {
    collection.add({
      "userId": uid,
      "eventId": key,
      "active": true,
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

  void completeBooking(String key) async {
    collection.where("eventId", isEqualTo: key).get().then((value) {
      value.docs.forEach((result) {
        collection.doc(result.id).update({"active": false});
      });
    });
  }

  Future<int> checkUser (String uid, String key) async{
    int res=0;
    if (uid==null){
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

  void retrieveUsers(String key) async{
    collection.where("EventId", isEqualTo: key).get();
  }

   Future<QuerySnapshot> retrieveActiveEvents(String uid) async{
    return collection.where("active", isEqualTo: true).where('userId', isEqualTo: uid).get();
  }

  Future<QuerySnapshot> retrievePastEvents(String uid) async{
    return collection.where("active", isEqualTo: false).where('userId', isEqualTo: uid).get();
  }


}
