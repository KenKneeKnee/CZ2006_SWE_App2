import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/facil_repository.dart';
import 'package:my_app/reviews/storage_repository.dart';
import 'Review.dart';

final Storage storage = Storage();
class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
  final String placeId="1";
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
                    String imageid = doc.id;
                    Review retrieved = ReviewFromJson(doc.data() as Map<String,dynamic>);
                    reviewlist.add(ReviewWidget(review: retrieved, imageid: imageid,));
                  }
                  return ListView(
                        children: reviewlist,
                      );
                }
              },
            ),
          floatingActionButton: FloatingActionButton(onPressed: () {
            final title = TextEditingController();
            final rating = TextEditingController();
            final desc = TextEditingController();
            final user = TextEditingController();
            XFile? imageFile;

            showDialog(context: context, builder: (BuildContext context){
              return Dialog(
                child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                            controller: title,
                            decoration: const InputDecoration(
                                hintText: 'Enter title')
                        ),
                        TextFormField(
                            controller: rating,
                            decoration: const InputDecoration(
                                hintText: 'Enter rating')
                        ),
                        TextFormField(
                            controller: desc,
                            decoration: const InputDecoration(
                                hintText: 'Enter desc')
                        ),
                        TextFormField(
                            controller: user,
                            decoration: const InputDecoration(
                                hintText: 'Enter name')
                        ),
                        ElevatedButton(onPressed: () async{
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          imageFile=pickedFile!;

                        }, child: Text("upload photo")),
                        ElevatedButton(onPressed: () {
                          postReview(title.text, int.parse(rating.text), desc.text, user.text, imageFile);
                          Navigator.pop(context);
                        }, child: Text("post!!!"))
                      ],
                    )
                )
              );

            });
          }, child: Text("Post")),
          ),
    );
  }

  void postReview(String title, int rating, String desc, String user, XFile? imageFile) async{
    Review r = Review(title, rating, desc, user);
    /// hardcoded place id here
    DocumentReference docref = await facils.addReviewFor(widget.placeId, r);
    if (imageFile!=null) {
      await storage.uploadFile(imageFile.path, docref.id); // image is uploaded with same doc id as review
    }
  }

}

class ReviewWidget extends StatelessWidget {
  ReviewWidget(
      {Key? key,
        required this.review,
        required this.imageid,})
      : super(key: key);

  final Review review;
  final String imageid;

  @override
  Widget build(BuildContext context) {
    return Container(
          child: FutureBuilder(
          future: storage.downloadURL(imageid),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  height: 100,
                  padding: EdgeInsets.all(5.0),
                  child:ListView(
                    children: [
                      Text(review.title),
                      Text(review.rating.toString()),
                      Text(review.desc),
                      //Text(review.user),
                    ],
                ),
              );
            }
            else {
              return Container(
                  height: 100,
                  padding: EdgeInsets.all(5.0),
                  child: ListView(
                    children: [
                      Text(review.title),
                      Text(review.rating.toString()),
                      Text(review.desc),
                      //Text(review.user),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            alignment: Alignment.center,
                            image: NetworkImage(snapshot.data!))
                        ),
                      )
                    ]
                  )
              );
            }
          }
        )
      );
  }
}
