/// Facility repository class that links to 'facilities' collection on Cloud Firestore

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

  /// adds a facility document to the facilities collection, if one does not already exist
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

  /// adds a review document to the reviews collection nested within each facility document
  Future<DocumentReference> addReviewFor(String placeId, Review review) {
    Map<String, Object> revjson=review.toJson();
    return collection.doc(placeId).collection("reviews").add(revjson);
  }

  // void deleteReviewFor(String placeId, Review review){
  //
  // }

  /// fetch reviews for a facility
  Future<QuerySnapshot> getReviewsFor(String placeId) async{
    CollectionReference facilReviewsRef = collection.doc(placeId).collection("reviews");
    return facilReviewsRef.get();
  }


  /// updates a facility document
  void updateFacil(String placeId, Map<String,Object> facil) async {
    await collection.doc(placeId).update(facil);
  }

  /// deletes a facility document
  void deleteFacil(String placeId) async {
    await collection.doc(placeId).delete();
  }
}
