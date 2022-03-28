import 'package:flutter/material.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/retrievedevent.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/events/view_event.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/user_profile/screens/friend_invite_page.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

final uid = FirebaseAuth.instance.currentUser!.email as String;

class ViewCurrentEventPage extends StatefulWidget {
  ViewCurrentEventPage({Key? key}) : super(key: key);
  _ViewCurrentEventPageState createState() => _ViewCurrentEventPageState();
}

class _ViewCurrentEventPageState extends State<ViewCurrentEventPage> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();
  late List<SportsFacility> SportsFacilityList;
  late bool loading;
  UserDbManager userdb = UserDbManager();
  late UserData cu;
  getUser() async {
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    cu = UserData.fromSnapshot(doc);
  }

  ScrollController controller = ScrollController();
  double topContainer = 0;

  @override
  void initState() {
    getUser();
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

  Future getData() async {
    var sportsfacildatasource = SportsFacilDataSource();
    final facildata = await sportsfacildatasource.someFunction();
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      SportsFacilityList = facildata;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (!loading)
        ? StreamBuilder<QuerySnapshot>(
            stream: booking.getStream(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
              return StreamBuilder<QuerySnapshot>(
                  stream: repository.getStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    List EventList = snapshot.data!.docs;
                    List BookingList = snapshot1.data!.docs;
                    Map<String, SportEvent> ActiveEventMap = {};
                    List activeEventIds = [];
                    final Size size = MediaQuery.of(context).size;

                    List<Widget> eventbuttons = [];

                    List tempEventIdlist = [];

                    for (DocumentSnapshot doc in BookingList) {
                      if (doc['userId'] == uid) {
                        if (doc['active'] == true) {
                          activeEventIds.add(doc['eventId']);
                        }
                      }
                    }

                    

                    for (String eid in activeEventIds) {
                      for (DocumentSnapshot doc in EventList) {
                        if (doc.id == eid) {
                          SportEvent e = SportEvent.fromSnapshot(doc);
                          DateTime start = e.start;
                          DateTime end = e.end;

                          DateTime? curTime = DateTime.now();
                          if (curTime.isBefore(start) == true) {
                            ActiveEventMap[eid] = e;
                            tempEventIdlist.add(eid);
                          }
                        }
                      }
                    }

                    activeEventIds = tempEventIdlist;

                    //card for active event
                    for (String eventid in activeEventIds) {
                      SportEvent currentevent =
                          ActiveEventMap[eventid] as SportEvent;
                      SportsFacility sportsfacil =
                          SportsFacilityList[int.parse(currentevent.placeId)];

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
                                            FloatingActionButton.extended(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      Friend_Invite_Page(
                                                          friends: cu.friends),
                                                ));
                                              },
                                              label:
                                                  const Text('Invite friends'),
                                              backgroundColor:
                                                  Colors.deepOrangeAccent,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ]))));
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
                  });
            })
        : CircularProgressIndicator();
  }
}
