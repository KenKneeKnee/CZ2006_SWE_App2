import 'package:cloud_firestore/cloud_firestore.dart';


class ClusterRepository {
  final CollectionReference collection = FirebaseFirestore.instance.collection('cluster_labels');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

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

