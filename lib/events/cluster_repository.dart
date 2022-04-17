import 'package:cloud_firestore/cloud_firestore.dart';

/// Class that manages the clustering labels of all Active Events in the Firebase.
/// Provides the following functionalities
/// 1. Returns a stream of the label collection
/// 2. Retrieves a subcollection of documents that have the same label

class ClusterRepository {
  final CollectionReference collection = FirebaseFirestore.instance.collection('cluster_labels');

  /// Returns a stream of the label collection for StreamBuilder
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  /// Returns a subcollection of events that are of the same label as the event
  /// passed in as a parameter.
  /// Events returned are Active Events.
  /// EventId passed as parameter must be the ID of an Active Event.
  Future<QuerySnapshot> retrieveSameLabel(String eventId) async{

    int label = -999;

    QuerySnapshot maa = await collection.where("eventId", isEqualTo: eventId).get();
    for (DocumentSnapshot docss in maa.docs) {
      label=docss['label'];
    }
    // maa.data.docs.forEach((doc) {
    //     label = doc["label"];
    //   })
    // })

    //   if (label != -999) {
    return collection
        .where("label", isEqualTo: label)
        .where('eventId', isNotEqualTo: eventId)
        .get();
    //   } else {
    //     return ;
    //
    //
    // });
  }


}
