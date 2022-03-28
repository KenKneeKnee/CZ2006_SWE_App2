import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/reviews/create_review.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/facil_repository.dart';
import 'package:my_app/reviews/ratingchart.dart';
import 'package:my_app/reviews/storage_repository.dart';
import '../map/map_data.dart';
import '../user_profile/data/user.dart';
import '../widgets/bouncing_button.dart';
import 'Review.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;
final Storage storage = Storage();
final UserDbManager userDb = UserDbManager();

class ReviewPage extends StatefulWidget {
  ReviewPage({Key? key, required this.placeId, required this.sportsFacility})
      : super(key: key);
  final String placeId;
  final SportsFacility sportsFacility;
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FacilRepository facils = FacilRepository();
  String rating = "Rate this facility";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Review Page",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: Future.wait([
          facils.getReviewsFor(widget.placeId),
          userDb.collection.doc(uid).get()
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final revs = snapshot.data![0];
            final UserData user = UserData.fromSnapshot(snapshot.data![1]);
            List<Widget> reviewlist = [];
            if (revs!.docs.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fitWidth)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No reviews yet!",
                        style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 30,
                    ),
                    postButton("Post one?")
                  ],
                ),
              );
            }
            Map ratings = {
              1: 0,
              2: 0,
              3: 0,
              4: 0,
              5: 0,
            }; // rating:count
            for (DocumentSnapshot doc in revs.docs) {
              String imageid = doc.id;
              Review retrieved =
                  ReviewFromJson(doc.data() as Map<String, dynamic>);
              if (ratings[retrieved.rating] != null) {
                ratings[retrieved.rating] += 1;
              } else {
                ratings[retrieved.rating] = 1;
              }
              reviewlist.add(ReviewWidget(
                  review: retrieved, imageid: imageid, user: user));
            }
            return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 375,
                      child: RatingChart(
                        total: reviewlist.length,
                        stardata: ratings,
                        sportsFacility: widget.sportsFacility,
                      ),
                    ),
                    postButton("Write Review!"),
                    SizedBox(
                      height: 30,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: reviewlist.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 1,
                                color: Colors.grey,
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                child: GestureDetector(
                                  onTap: () {
                                    print("${index} was tapped");
                                  },
                                  child: reviewlist[index],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void postReview(String title, int rating, String desc, String user,
      XFile? imageFile) async {
    Review r = Review(title, rating, desc, user);
    DocumentReference docref = await facils.addReviewFor(widget.placeId, r);
    if (imageFile != null) {
      await storage.uploadFile(imageFile.path,
          docref.id); // image is uploaded with same doc id as review
    }
  }

  Widget postButton(String text) => BouncingButton(
      bgColor: Colors.black,
      borderColor: Colors.black,
      buttonText: text,
      textColor: Colors.white,
      onClick: () {
        final title = TextEditingController();
        final desc = TextEditingController();
        XFile? imageFile;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(child: CreateReviewForm(placeId: widget.placeId));
            });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => CreateReviewForm(
        //             placeId: widget.placeId,
        //           )),
        // );
      });

  Widget buildTitle(title) => Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextFormField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Review title',
              prefixIcon: Icon(Icons.sports_basketball_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.length < 4 ||
                  value != null && value.length > 50) {
                return 'Enter between 4-50 characters';
              } else {
                return null;
              }
            },
          ),
        ),
      );

  Widget buildRating(rating) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(10),
        child: DropdownButtonFormField<String>(
          value: rating,
          validator: (value) {
            if (value == "Select a rating") {
              return 'Please select a rating for this facility';
            } else {
              return null;
            }
          },
          isExpanded: true,
          icon: const Icon(Icons.sports_football_outlined),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              rating = newValue!;
            });
          },
          items: <String>[
            "Rate this facility",
            "1 star",
            '2 star',
            '3 star',
            '4 star',
            '5 star',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      );

  Widget buildDesc(desc) => Flexible(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            controller: desc,
            decoration: const InputDecoration(
              labelText: 'Describe your time here!',
              prefixIcon: Icon(Icons.sports_basketball_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.length > 300) {
                return 'Please keep to a character limit of 300.';
              } else {
                return null;
              }
            },
          ),
        ),
      );
}

class ReviewWidget extends StatelessWidget {
  ReviewWidget({
    Key? key,
    required this.review,
    required this.imageid,
    required this.user,
  }) : super(key: key);

  final Review review;
  final String imageid;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.downloadURL(imageid),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Container(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Expanded(
                    child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      SizedBox(
                        height: 75,
                        width: 75,
                        child: Image.asset(user.image, fit: BoxFit.cover),
                      ),
                      RatingBarIndicator(
                        rating: review.rating * 1.0,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 13.0,
                        direction: Axis.horizontal,
                      )
                    ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 4,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                            Text('posted by ${user.username}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                            SizedBox(height: 4),
                            Text(
                              review.desc,
                            ),
                          ]))
                ])));
          } else {
            return Container(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Expanded(
                    child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: Column(children: [
                      SizedBox(
                        height: 75,
                        width: 75,
                        child: Image.asset(user.image, fit: BoxFit.cover),
                      ),
                      RatingBarIndicator(
                        rating: review.rating * 1.0,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 13.0,
                        direction: Axis.horizontal,
                      )
                    ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 4,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                            Text('posted by ${user.username}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )),
                            SizedBox(height: 4),
                            Text(
                              review.desc,
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    alignment: Alignment.center,
                                    image: NetworkImage(snapshot.data!),
                                    fit: BoxFit.cover),
                                border: Border.all(
                                  color: Colors.lightBlueAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ]))
                ])));
          }
        });
  }
}

String removeEmail(String email) {
  List split = email.split("@");
  return split[0];
}
