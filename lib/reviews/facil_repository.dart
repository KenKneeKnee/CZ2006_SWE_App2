import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Review.dart';


final uid = FirebaseAuth.instance.currentUser?.email as String;

class FacilRepository {
  final CollectionReference collection =
  FirebaseFirestore.instance.collection('facilities');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  // 3
  void addFacil(String placeId) async{
    Map<String,Object> facil= {};
    facil["facility"]=placeId;
    DocumentReference facilDocRef = collection.doc(placeId);
    DocumentSnapshot doc = await facilDocRef.get();
    if (!doc.exists) {
      collection.doc(placeId).set(facil);
    } else {
      print("facility record already exists");
    }
  }

  Future<DocumentReference> addReviewFor(String placeId, Review review) {
    Map<String, Object> revjson=review.toJson();
    return collection.doc(placeId).collection("reviews").add(revjson);
  }

  // void deleteReviewFor(String placeId, Review review){
  //
  // }

  Future<QuerySnapshot> getReviewsFor(String placeId) async{
    CollectionReference facilReviewsRef = collection.doc(placeId).collection("reviews");
    return facilReviewsRef.get();
  }


  // 4
  void updateFacil(String placeId, Map<String,Object> facil) async {
    await collection.doc(placeId).update(facil);
  }

  // 5
  void deleteFacil(String placeId) async {
    await collection.doc(placeId).delete();
  }
}
