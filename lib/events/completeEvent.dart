import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/map/facil_map.dart';
import 'dart:math';
import 'package:my_app/map/map_data.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;

class eventPage extends StatefulWidget {
  eventPage({Key? key}) : super(key: key);
  _eventPageState createState() => _eventPageState();
}

class _eventPageState extends State<eventPage> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  Future<void> complete(SportEvent e, String key) async {
    LocationData userLocation = await checkLocation();
    var sportsfacildatasource = SportsFacilDataSource();
    List<SportsFacility> objects = await sportsfacildatasource.someFunction();
    DateTime? curTime = DateTime.now();
    SportsFacility obj = objects[e.placeId];
    var lat2 = obj.coordinates.latitude;
    var lon2 = obj.coordinates.longitude;
    bool inRadius = calculateDistance(
            userLocation.latitude, userLocation.longitude, lat2, lon2) <
        100;
    if (curTime.isAfter(e.start) & inRadius == true) {
      //functions to do once event completed
      booking.completeBooking(key);
    }

    //auto delete for buds that joined but did not complete

    if(curTime.isAfter(e.end)){
      booking.deleteBooking(uid, key);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return StreamBuilder<QuerySnapshot>(
      stream: booking.getStream(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
        return StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            List EventList = snapshot.data!.docs;
            Map<String, SportEvent> EventMap = {};
            for (DocumentSnapshot doc in EventList) {
              if (doc['placeId'] == "92") {
                SportEvent e = SportEvent.fromSnapshot(doc);
                EventMap[doc.id] = e;
              }
            }

            Future<int> hasActiveEvent(String uid, String key) async {
              SportEvent e = EventMap[key] as SportEvent;
              Timestamp eventStart = Timestamp.fromDate(e.start);
              Timestamp eventEnd =
                  Timestamp.fromDate(e.end); //current event timebox

              QuerySnapshot ss = await booking
                  .retrieveActiveEvents(uid); // current bookings for this user
              for (DocumentSnapshot doc in ss.docs) {
                String eid = await doc.get("eventId");
                DocumentReference docref = repository.collection.doc(eid);
                DocumentSnapshot docsnap = await docref.get();
                Timestamp activestart = await docsnap.get('start');
                Timestamp activeend = await docsnap.get('end');
                if ((eventStart.compareTo(activeend) <= 0) ||
                    (eventEnd.compareTo(activestart)) >= 0) {
                  return 1; // has clash
                }
              }
              return 0;
            }

            return Scaffold(
                appBar: AppBar(title: const Text("Event Page")),
                body: ListView.builder(
                    shrinkWrap: true,
                    itemCount: EventMap.length,
                    padding: const EdgeInsets.only(top: 10.0),
                    itemBuilder: (context, index) {
                      String key = EventMap.keys.elementAt(index);
                      SportEvent curEvent = EventMap[key] as SportEvent;
                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: <Widget>[
                          Container(
                            child: Expanded(
                              child: Text(
                                  'id: ${key} event: ${curEvent.name} at ${curEvent.placeId} curCap: ${curEvent.curCap} maxCap: ${curEvent.maxCap}'),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                int hasBooking =
                                    await booking.checkUser(uid, key);
                                int hasClash = await hasActiveEvent(uid, key);
                                if (hasBooking == -1) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Account Error!"),
                                      content: Text(
                                          "Please make sure you are logged in."),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Go Back'))
                                      ],
                                    ),
                                  );
                                } else if (hasBooking > 0) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                          "AY MAN You've already joined this event!"),
                                      content: Text("Don't be stupid bro"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'Ok');
                                            },
                                            child: Text('Go Back'))
                                      ],
                                    ),
                                  );
                                } else if (hasClash == 1) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                          "you have an active booking which clashes"),
                                      content: Text(
                                          "leave other booking if you want this"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Go Back'))
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Join Event'),
                                      content: const Text('Confirm?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        // TextButton(
                                        //     onPressed: () {
                                        //       Navigator.pop(context, 'Ok');
                                        //       join(curEvent,key);
                                        //       showDialog(
                                        //           context: context,
                                        //           builder: (BuildContext context) {
                                        //             return JoinedEventDialog(
                                        //               bgDeco: DialogBoxDecoration
                                        //                   .joinEventBg,
                                        //               title: 'Joined Successfully!',
                                        //               paragraph:
                                        //               'Your fellow SportBuds can\'t wait to see you!',
                                        //             );
                                        //           });
                                        //     },
                                        //     child: const Text('Ok'),
                                        // ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              color: Colors.green,
                              icon: const Icon(
                                Icons.add_circle_rounded,
                              )),
                          IconButton(
                              onPressed: () async {
                                int hasBooking =
                                    await booking.checkUser(uid, key);
                                if (hasBooking == -1) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Account Error!"),
                                      content: Text(
                                          "Please make sure you are logged in."),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Go Back'))
                                      ],
                                    ),
                                  );
                                }
                                if (hasBooking == 0) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("u havent join this yet"),
                                      content: Text("waiting for wat"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Go Back'))
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Leave Event'),
                                      content: const Text('Confirm?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        // TextButton(
                                        //   onPressed: () {
                                        //     Navigator.pop(context, 'Ok');
                                        //     leave(curEvent, key);
                                        //     showDialog(
                                        //         context: context,
                                        //         builder: (BuildContext context) {
                                        //           return LeftEventDialog(
                                        //             bgDeco: DialogBoxDecoration
                                        //                 .leaveEventBg,
                                        //             title: 'Left successfully',
                                        //             paragraph:
                                        //             'Sorry to see you go. Hope to sometime soon!',
                                        //           );
                                        //         });
                                        //   },
                                        //   child: const Text('Ok'),
                                        // ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              color: Colors.red,
                              icon: const Icon(
                                  Icons.remove_circle_outline_rounded)),
                        ]),
                      );
                    }));
          },
        );
      },
    );
  }
}
