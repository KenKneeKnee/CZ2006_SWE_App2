import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/facil_repository.dart';
import 'package:my_app/reviews/ratingchart.dart';
import 'package:my_app/reviews/storage_repository.dart';
import '../map/map_data.dart';
import '../widgets/bouncing_button.dart';
import 'Review.dart';

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
                  for (DocumentSnapshot doc in revs!.docs) {
                    String imageid = doc.id;
                    Review retrieved = ReviewFromJson(doc.data() as Map<String,dynamic>);
                    reviewlist.add(ReviewWidget(review: retrieved, imageid: imageid,));
                  }
                  return Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Expanded(
                      child: RatingChart(
                      sportsFacility: widget.sportsFacility,
                      ),
                      flex: 5,
                    ),
                BouncingButton(
                bgColor: Colors.black,
                borderColor: Colors.black,
                buttonText: "Write Review",
                textColor: Colors.white,
                onClick: () {}),
                SizedBox(height: 30),
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
        )
      );
  }
}
