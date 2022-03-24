import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/reviews/facil_repository.dart';

import 'Review.dart';


class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
  final String placeId="2";
}

class _ReviewPageState extends State<ReviewPage> {
  final FacilRepository facils = FacilRepository();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: Scaffold(
          body: FutureBuilder<QuerySnapshot>(
            future: facils.getReviewsFor(widget.placeId),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
            {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              else {
                final revs = snapshot.data;
                List<Widget> reviewlist=[];
                for (DocumentSnapshot doc in revs!.docs) {
                  Review retrieved = ReviewFromJson(doc.data() as Map<String,dynamic>);
                  reviewlist.add(ReviewWidget(review: retrieved));
                }
                return ListView(
                  children: reviewlist,
                );
              }
            },

        ),
    ),
    );
  }
}

class ReviewWidget extends StatelessWidget {
  ReviewWidget(
      {Key? key,
        required this.review,})
      : super(key: key);

  final Review review;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(5.0),
      child: ListView(
        children: [
          Text(review.title),
          Text(review.rating.toString()),
          Text(review.desc),
          //Text(review.user),
        ],
      ),
    );
  }
}
