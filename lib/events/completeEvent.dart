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
    List recommendedEventIds = [];
    List<Widget> eventbuttons = [];
    Map<String, SportEvent> ActiveEventMap = {};
    List eventlist = [];
    List<SportEvent> selist = [];
    List<Widget> recevents = [];
    final Size size = MediaQuery.of(context).size;

    // Future<QuerySnapshot> recommendations = clusterRepo.retrieveSameLabel(
    //     widget.event_id);

    return FutureBuilder<QuerySnapshot>(
        future: clusterRepo.retrieveSameLabel(widget.event_id),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot_rec) {
          if (!snapshot_rec.hasData) {
            print("whhhhhaht 1");
            return Text("nodata");
          } else {
            if (snapshot_rec.connectionState == ConnectionState.waiting) {
              print("whhhhhah 2t");
              return CircularProgressIndicator();
            } else if (snapshot_rec.connectionState == ConnectionState.done) {
              if (snapshot_rec.hasError) {
                print("whhhhhah 3t");
                return const Text('Error');
              } else if (snapshot_rec.hasData) {
                snapshot_rec.data!.docs.forEach((element) {
                  recommendedEventIds.add(element['eventId']);
                });

                for (String eventid in recommendedEventIds) {
                  print(recommendedEventIds.length);
                }

                return StreamBuilder(
                    stream: repository.getStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshote) {
                      for (DocumentSnapshot docss in snapshote.data!.docs) {
                        print(docss.id);
                        if (recommendedEventIds.contains(docss.id)) {
                          selist.add(SportEvent.fromSnapshot(docss));
                        }
                      }
                      for (SportEvent i in selist) {
                        // add ui
                        recevents.add(Container(child: Text('${i.name}')));
                      }
                      return ListView(children: recevents);
                    });

                // SportEvent currentevent =
                //     ActiveEventMap[eventid] as SportEvent;
                // SportsFacility sportsfacil =
                //     SportsFacilityList[int.parse(currentevent.placeId)];
                // eventbuttons.add(Container(
                //     height: size.height * 0.2,
                //     margin: const EdgeInsets.symmetric(
                //         horizontal: 20, vertical: 10),
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //         color: Colors.white,
                //         boxShadow: [
                //           BoxShadow(
                //               color: Colors.black.withAlpha(100),
                //               blurRadius: 10.0),
                //         ]),
                //     child: Padding(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 20.0, vertical: 10),
                //         child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: <Widget>[
                //               Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: <Widget>[
                //                   Text(
                //                     currentevent.name.toString(),
                //                     style: const TextStyle(
                //                         fontSize: 20,
                //                         fontWeight: FontWeight.bold),
                //                   ),
                //                   SportEventTextWidget.Subtitle(
                //                       sportsfacil.facilityType),
                //                   Text(
                //                     "Current capacity: " +
                //                         currentevent.curCap.toString() +
                //                         "/" +
                //                         currentevent.maxCap.toString(),
                //                     style: const TextStyle(
                //                         fontSize: 17, color: Colors.grey),
                //                   ),
                //                   const SizedBox(
                //                     height: 10,
                //                   ),
                //                   Row(
                //                     children: <Widget>[
                //                       FloatingActionButton.extended(
                //                           onPressed: () {
                //                             showDialog(
                //                               context: context,
                //                               builder:
                //                                   (BuildContext context) {
                //                                 return Dialog(
                //                                   backgroundColor:
                //                                       Color(0xffE5E8E8),
                //                                   child: ViewEventPopUp(
                //                                     placeIndex: int.parse(
                //                                         currentevent.placeId),
                //                                     event: RetrievedEvent(
                //                                       currentevent.name,
                //                                       currentevent.start,
                //                                       currentevent.end,
                //                                       currentevent.maxCap,
                //                                       currentevent.curCap,
                //                                       currentevent.placeId,
                //                                       currentevent.type,
                //                                       currentevent.active,
                //                                       eventid,
                //                                     ),
                //                                     SportsFacil: sportsfacil,
                //                                   ),
                //                                   shape: const RoundedRectangleBorder(
                //                                       borderRadius:
                //                                           BorderRadius.all(
                //                                               Radius.circular(
                //                                                   20.0))),
                //                                 );
                //                               },
                //                             );
                //                           },
                //                           label: const Text('View'),
                //                           backgroundColor: Colors.orange),
                //                       const SizedBox(
                //                         height: 24,
                //                         child: VerticalDivider(),
                //                       ),
                //                     ],
                //                   )
                //                 ],
                //               ),
                //             ]))));

              }
            }
          }
          return Container(color: Colors.red);
        });
  }
}
