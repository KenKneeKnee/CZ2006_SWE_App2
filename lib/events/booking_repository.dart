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
    await collection
        .where("userId", isEqualTo: uid)
        .where("eventId", isEqualTo: key)
        .get()
        .then((value) {
          res = value.docs.length;
      });
    return res;
  }
/*
  void retrieveUsers(String key) async{
    collection.where("EventId", isEqualTo: key).get().then((value){
      value.docs.forEach((element) {
        print(element.data()["userid"]);
      });

    });
  }

  void retrieveActiveEvents(String key) async{
    collection.where("active", isEqualTo: true).get().then((value){
      value.docs.forEach((result) {
        print(result.data()["key"]);
      });
    });
  }

  void retrievePastEvents(String key) async{
    collection.where("active", isEqualTo: false).get().then((value){
      value.docs.forEach((result) {
       print(result.data()["key"]);
      });
    });
  }

 */
}
