import 'package:flutter/material.dart';
import 'package:my_app/map/map_data.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/widgets/bouncing_button.dart';

class FacilityReview extends StatelessWidget {
  FacilityReview(
      {Key? key,
      required this.text,
      required this.rating,
      required this.username})
      : super(key: key);
  final String text;
  final double rating;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ReviewPage extends StatefulWidget {
  ReviewPage({Key? key, required this.placeId, required this.sportsFacility})
      : super(key: key);
  final String placeId;
  final SportsFacility sportsFacility;
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late final ValueNotifier<List<FacilityReview>> _facilityReviews;
  @override
  void initState() {
    super.initState();
    _facilityReviews = ValueNotifier(_getReviewsForFacility());
    // _facilityReviews = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<FacilityReview> _getReviewsForFacility() {
    return [
      FacilityReview(
        text: "Bad",
        rating: 1,
        username: "jew",
      ),
      FacilityReview(
        text: "Good",
        rating: 5,
        username: "clary",
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Review Page')),
        body: Container(
            child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                padding: EdgeInsets.all(5),
                child: Text('Ratings',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  children: [
                    RatingBarIndicator(
                      rating: calcAvgRating(),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 50.0,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(height: 50),
                    BouncingButton(
                        bgColor: Colors.black,
                        borderColor: Colors.black,
                        buttonText: "Write Review",
                        textColor: Colors.white,
                        onClick: () {}),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 35, 0, 0),
                child: ValueListenableBuilder<List<FacilityReview>>(
                  valueListenable: _facilityReviews,
                  builder: (context, value, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
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
                                  child: Container(
                                    child: ListTile(
                                      isThreeLine: true,
                                      title: Text(value[index].text),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          RatingBarIndicator(
                                            rating: value[index].rating,
                                            itemBuilder: (context, index) =>
                                                Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 20.0,
                                            direction: Axis.horizontal,
                                          ),
                                          Text('${value[index].username}'),
                                        ],
                                      ),
                                      leading: Icon(Icons.reviews),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.arrow_right_alt_outlined),
                                  color: Colors.black),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            )
          ],
        )));
  }

  double calcAvgRating() {
    int sumRating = 0;
    List<int> listRating = [1, 4, 2, 5, 2, 1];

    for (var i = 0; i < listRating.length; i++) {
      sumRating += listRating[i];
    }

    var average = (sumRating / listRating.length);
    return average;
  }
}
