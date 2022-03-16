// assume no image first

import 'package:firebase_auth/firebase_auth.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;

class Review {
  // assume no image
  final String title;
  final int rating;
  final String desc;
  final String user = uid;

  Review(this.title, this.rating, this.desc);

  Map<String, Object> toJson() {
    return {
      'title': title,
      'rating': rating,
      'desc': desc,
      'user': user,
    };
  }
}


