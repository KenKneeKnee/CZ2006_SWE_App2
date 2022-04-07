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
              }
            }
          }
          return Container(color: Colors.red);
        });
  }
}