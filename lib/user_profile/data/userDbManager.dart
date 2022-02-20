import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user.dart';

class UserDbManager {
  // 1
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future updateUser(UserData u, String key) async {
    print('${u.about} ${u.username}');
    await collection.doc(key).update(u.toJson());
    print('aa');
  }

  VisitUserProfile() {
    String? userid = FirebaseAuth.instance.currentUser?.email;
    return collection.doc(userid);
  }

  VisitOtherProfile(another_id) {
    return collection.doc(another_id);
  }
}
