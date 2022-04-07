import 'package:cloud_firestore/cloud_firestore.dart';


class ClusterRepository {
  final CollectionReference collection = FirebaseFirestore.instance.collection('cluster_labels');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<QuerySnapshot> retrieveSameLabel(String eventId) async{
    late int label;

    await collection.where("eventId", isEqualTo: eventId).get().then((value) {
      value.docs.forEach((doc) {
        label = doc["label"];
      });
    });

    return collection
        .where("label", isEqualTo: label)
        .where('eventId', isNotEqualTo: eventId)
        .get();
  }
}
