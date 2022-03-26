import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/facil_repository.dart';
import 'package:my_app/reviews/ratingchart.dart';
import 'package:my_app/reviews/storage_repository.dart';
import '../map/map_data.dart';
import '../widgets/bouncing_button.dart';
import 'Review.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;
final Storage storage = Storage();
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
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Review Page',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.yellow),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
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
                  Map ratings={}; // rating:count
                  for (DocumentSnapshot doc in revs!.docs) {
                    String imageid = doc.id;
                    Review retrieved = ReviewFromJson(doc.data() as Map<String,dynamic>);
                    if (ratings[retrieved.rating]!=null) {
                      ratings[retrieved.rating]+=1;
                    } else {
                      ratings[retrieved.rating]=1;
                    }
                    reviewlist.add(ReviewWidget(review: retrieved, imageid: imageid,));
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
                    BouncingButton(
                    bgColor: Colors.black,
                    borderColor: Colors.black,
                    buttonText: "Write Review",
                    textColor: Colors.white,
                    onClick: () {
                      final title = TextEditingController();
                      final desc = TextEditingController();
                      XFile? imageFile;

                      showDialog(context: context, builder: (BuildContext context){
                        return Dialog(
                            child: Form(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    buildTitle(title),
                                    Container(
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
                                    ),
                                    buildDesc(desc),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    BouncingButton(
                                      bgColor: Color.fromRGBO(135, 180, 187, 1),
                                      borderColor: Color.fromRGBO(135, 180, 187, 1),
                                      buttonText: "Add a photo?",
                                      textColor: Color(0xffffffff),
                                      onClick: () async{
                                      final pickedFile = await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      imageFile=pickedFile!;

                                    },),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    BouncingButton(
                                      bgColor: Color(0xffE96B46),
                                      borderColor: Color(0xffE96B46),
                                      buttonText: "Post!",
                                      textColor: Color(0xffffffff),
                                      onClick: () {
                                      postReview(title.text, int.parse(rating[0]), desc.text, uid, imageFile);
                                      Navigator.pop(context);
                                    },)
                                  ],
                                )
                            )
                        );

                      });
                    }),
                    SizedBox(height: 30,),
                      ListView.builder(
                            shrinkWrap: true,
                            itemCount: reviewlist.length,
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
                                    ),],
                                ),
                              );
                            },
                      ),
                    ],
                    ),
                  ),);
                }
              },
            ),
          ),
    );
  }

  void postReview(String title, int rating, String desc, String user, XFile? imageFile) async{
    Review r = Review(title, rating, desc, user);
    DocumentReference docref = await facils.addReviewFor(widget.placeId, r);
    if (imageFile!=null) {
      await storage.uploadFile(imageFile.path, docref.id); // image is uploaded with same doc id as review
    }
  }

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
          if (value != null && value.length < 4 ||  value != null && value.length > 50){
            return 'Enter between 4-50 characters';
          } else {
            return null;
          }
        },
      ),
    ),
  );

  Widget buildRating(rating)=> Container(
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
  ReviewWidget(
      {Key? key,
        required this.review,
        required this.imageid,})
      : super(key: key);

  final Review review;
  final String imageid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
    future: storage.downloadURL(imageid),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      if (!snapshot.hasData) {
        return Container(
            padding: EdgeInsets.fromLTRB(10,10,10,10),
            child: Expanded(
                child: Row(
                    children:[
                      Expanded(flex:1, child: Text(review.user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,))),
                      Expanded(flex:4, child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            RatingBarIndicator(
                              rating:
                              review.rating*1.0,
                              itemBuilder:
                                  (context, index) =>
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction:
                              Axis.horizontal,
                            ),
                            Text(review.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                            SizedBox(height:4),
                            Text(review.desc,),
                          ]
                      ))
                    ]
                )
            )
        );
      }
      else {
        return Container(
          padding: EdgeInsets.fromLTRB(10,10,10,10),
          child: Expanded(
            child: Row(
              children:[
                Expanded(flex:1, child: Text(review.user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,))),
                Expanded(flex:4, child:Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    RatingBarIndicator(
                      rating:
                      review.rating*1.0,
                      itemBuilder:
                          (context, index) =>
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction:
                      Axis.horizontal,
                    ),
                    Text(review.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                    SizedBox(height:4),
                    Text(review.desc,),
                    Container(
                        height: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                alignment: Alignment.center,
                                image: NetworkImage(snapshot.data!))
                        ),),
                  ]
                ))
              ]
            )
          )
        );
      }
    }
        );
  }
}
