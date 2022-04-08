import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

                return StreamBuilder(
                    stream: repository.getStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshote) {
                      if (!snapshote.hasData) {
                        return const CircularProgressIndicator();
                      }
                      for (DocumentSnapshot docss in snapshote.data!.docs) {
                        if (recommendedEventIds.contains(docss.id)) {
                          selist.add(SportEvent.fromSnapshot(docss));
                        }
                      }
                      for (SportEvent i in selist) {
                        // add ui
                        recevents.add(RecWidget(event: i));
                      }
                      return Scaffold(
                        appBar: AppBar(
                          title: Text("You may also like these:",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        body: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: recevents.length,
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
                                              child: recevents[index],
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
                        ),
                      );
                    });
              }
            }
          }
          return Container(color: Colors.red);
        });
  }
}

class RecWidget extends StatelessWidget {
  RecWidget({
    Key? key,
    required this.event,
  }) : super(key: key);

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat.yMd().add_jm();
            return Material(
              child: Container(
                  color: Colors.amberAccent,
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Expanded(
                            flex: 4,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.indigoAccent,
                                      )),
                                  SizedBox(height: 10),
                                  Text("Located at ${event.placeId}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.indigo,
                                      )),
                                  SizedBox(height: 10),
                                  Text("Starts on ${formatter.format(event.start)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      )),
                                  SizedBox(height: 10),
                                  Text("Ends on ${formatter.format(event.end)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      )),
                                  SizedBox(height: 10),
                                ]))
              ),
            );
  }
}
