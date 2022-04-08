import 'package:flutter/material.dart';
import 'package:my_app/events/cluster_repository.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/retrievedevent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/cluster_repository.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/events/view_event.dart';
import 'package:my_app/map/facil_map.dart';
import 'package:my_app/map/map_data.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;

class CompleteEventPage extends StatefulWidget {
	CompleteEventPage({Key? key, required this.event_id}) : super(key: key);
	String event_id;

	@override
	State<CompleteEventPage> createState() => _CompleteEventPageState();
}

class _CompleteEventPageState extends State<CompleteEventPage> {
  final ClusterRepository clusterRepo = ClusterRepository();
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();
  late List<SportsFacility> SportsFacilityList;
  late bool loading;

  Future getData() async {
    var sportsfacildatasource = SportsFacilDataSource();
    final facildata = await sportsfacildatasource.someFunction();
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      SportsFacilityList = facildata;
      loading = false;
    });
  }

  ScrollController controller = ScrollController();
  double topContainer = 0;

  @override
  void initState() {
    super.initState();
    loading = true;
    getData();
    controller.addListener(() {
      double value = controller.offset / 1000;
      setState(() {
        topContainer = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return(!loading)
    ? StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (snapshot1.hasError) {
            print("calista 1");
            return const Text('Something went wrong');
          }
          if (!snapshot1.hasData) {
            print("calista 2");
            return const CircularProgressIndicator();
          }
          List recommendedEventIds = [];
          List<Widget> eventbuttons = [];
          Map<String, SportEvent> ActiveEventMap = {};
          final Size size = MediaQuery
              .of(context)
              .size;
          print("calista 3");
          Future<QuerySnapshot> recommendations = clusterRepo.retrieveSameLabel(
              widget.event_id);
          FutureBuilder<QuerySnapshot>(
              future: recommendations,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot_rec) {
                if (snapshot_rec.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot_rec.connectionState == ConnectionState.done) {
                  if (snapshot_rec.hasError) {
                    return const Text('Error');
                  } else if (snapshot_rec.hasData) {
                    Future<QuerySnapshot> activeEvents = booking.retrieveActiveEvents(uid);
                    FutureBuilder<QuerySnapshot>(
                        future: activeEvents,
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> snapshot,) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            } else if (snapshot.hasData) {
                              snapshot_rec.data!.docs.forEach((element) {
                                bool check = true;
                                snapshot.data!.docs.forEach((element1) {
                                  if (element["eventId"] ==
                                      element1["eventId"]) {
                                    check = false;
                                  }
                                });
                                if (check) {
                                  recommendedEventIds.add(element['eventId']);
                                }
                              });
                              return const Text("Success");
                            }
                            else {
                              return const Text("empty data");
                            }
                          } else {
                            return Text('State: ${snapshot.connectionState}');
                          }
                        });
                    return const Text("success!");
                  } else {
                    return const Text("empty data");
                  }
                }
                else {
                  return Text('State: ${snapshot_rec.connectionState}');
                }
              });

          for (String eventid in recommendedEventIds) {
            SportEvent currentevent = ActiveEventMap[eventid] as SportEvent;
            SportsFacility sportsfacil = SportsFacilityList[int.parse(
                currentevent.placeId)];
            eventbuttons.add(Container(
                height: size.height * 0.2,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 10.0),
                    ]),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                currentevent.name.toString(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              SportEventTextWidget.Subtitle(
                                  sportsfacil.facilityType),
                              Text(
                                "Current capacity: " +
                                    currentevent.curCap.toString() +
                                    "/" +
                                    currentevent.maxCap.toString(),
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: <Widget>[
                                  FloatingActionButton.extended(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return Dialog(
                                              backgroundColor:
                                              Color(0xffE5E8E8),
                                              child: ViewEventPopUp(
                                                placeIndex: int.parse(
                                                    currentevent
                                                        .placeId),
                                                event: RetrievedEvent(
                                                  currentevent.name,
                                                  currentevent.start,
                                                  currentevent.end,
                                                  currentevent.maxCap,
                                                  currentevent.curCap,
                                                  currentevent
                                                      .placeId,
                                                  currentevent.type,
                                                  currentevent.active,
                                                  eventid,
                                                ),
                                                SportsFacil:
                                                sportsfacil,
                                              ),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          20.0))),
                                            );
                                          },
                                        );
                                      },
                                      label: const Text('View'),
                                      backgroundColor: Colors.orange),
                                  const SizedBox(
                                    height: 24,
                                    child: VerticalDivider(),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ]))));


            // return Scaffold(
            // 		appBar: AppBar(
            // 			elevation: 0,
            // 			leading: BackButton(
            // 					color: Colors.white,
            // 					onPressed: () {
            // 						// Navigator.push(
            // 						//   context,
            // 						//   MaterialPageRoute(
            // 						//       builder: (context) => FacilitiesMap()), //return to map
            // 						// );
            // 						Navigator.of(context).popUntil((route) => route.isFirst);
            // 						Navigator.pushReplacement(
            // 								context,
            // 								MaterialPageRoute(
            // 										builder: (BuildContext context) => Homepage()));
            // 					}),
            // 			backgroundColor: Color(0xFF049cac),
            // 			title: Text(
            // 				"Completed Event",
            // 				style: TextStyle(
            // 					color: Colors.white,
            // 				),
            // 			),
            // 		),
            // 		body: Container(color: Colors.white)
            // );
          }
          return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.deepPurple,
                  body: Container(
                      height: size.height,
                      child: ListView.builder(
                          controller: controller,
                          itemCount: eventbuttons.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            double scale = 1.0;
                            if (topContainer > 0.1) {
                              scale = index + 0.1 - topContainer;
                              if (scale < 0) {
                                scale = 0;
                              } else if (scale > 1) {
                                scale = 1;
                              }
                            }
                            return Opacity(
                              opacity: scale,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..scale(scale, scale),
                                alignment: Alignment.bottomCenter,
                                child: Align(
                                    heightFactor: 0.8,
                                    alignment: Alignment.topCenter,
                                    child: eventbuttons[index]),
                              ),
                            );
                          }))));
        }): CircularProgressIndicator();
  }
}
