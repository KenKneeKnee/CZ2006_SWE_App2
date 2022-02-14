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
        "userid": uid,
        "eventID": key,
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
    collection.where("UserId", isEqualTo: uid).where("EventId", isEqualTo: key).get().then((value){
      value.docs.forEach((result) {
        collection.doc(result.id).delete();
      });
    });
    // await collection.doc(key).delete();
  }
}
