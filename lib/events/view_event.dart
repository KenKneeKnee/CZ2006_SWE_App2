import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/completeEvent.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/retrievedevent.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/start/screens/error_page.dart';
import 'package:my_app/widgets/background.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'dart:math';

import '../map/facil_map.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;

///ViewEventPopUp is the Pop Up displaying a SportEvent and its details.
/// Helper Functions include:
///1. _FindBackgroundImage which fetches the corresponding background image depending on the facility type
///2. renderButton which decides which buttons to be displayed. Button examples include but are not limited to : Join Event/Leave Event/Complete Event/Event Full
///Event details include date of event, time of event, event type, current cacpacity/max capacity, title of event, address of facility
class ViewEventPopUp extends StatefulWidget {
  ViewEventPopUp(
      {Key? key,
      required this.SportsFacil,
      required this.placeIndex,
      required this.event})
      : super(key: key);
  final SportsFacility SportsFacil;
  final int placeIndex;
  final RetrievedEvent event;
  // late String placeId = index.toString();

  @override
  _ViewEventPopUpState createState() => _ViewEventPopUpState();
}

class _ViewEventPopUpState extends State<ViewEventPopUp> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();
  String status = "unchecked";
  String completeStatus = "unchecked";

  @override
  void initState() {
    super.initState();
    JoinLeaveCheck(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    RetrievedEvent curEvent = widget.event;
    SportsFacility facility = widget.SportsFacil;
    String _imagePath = _FindBackgroundImage(facility.facilityType);

    return StreamBuilder<QuerySnapshot>(
        stream: booking.getStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          return StreamBuilder<QuerySnapshot>(
              stream: repository.getStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return ErrorPage();
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Stack(
                    children: [
                      RoundedBackgroundImage(imagePath: _imagePath),
                      Container(
                        decoration: baseContainer,
                        margin: EdgeInsets.fromLTRB(15, 60, 15, 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            children: [
                              calendarIcon,
                              SportEventTextWidget.Title(widget.event.name),
                              SportEventTextWidget.Subtitle(
                                  widget.SportsFacil.addressDesc),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                        child: TextWithIcon(
                                            widget.event.toDate(),
                                            Icon(Icons.date_range))),
                                    Flexible(
                                        child: TextWithIcon(
                                            widget.event.toTime(), timeIcon)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextWithIcon(widget.event.type,
                                          Icon(Icons.sports_rugby_rounded)),
                                    ),
                                    Flexible(
                                        child: TextWithIcon(
                                            '${widget.event.toCap()}\nplayers',
                                            capIcon)),
                                  ],
                                ),
                              ),
                              renderButton(curEvent),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  ///Helper Function which checks the Database(Bookings) if user has a clashing event
  ///The result is used in the JoinLeaveCheck function
  ///Returns 0 if there is no clash
  ///Returns 1 if there is a clash
  Future<int> hasActiveEvent(String uid, RetrievedEvent e) async {
    Timestamp eventStart = Timestamp.fromDate(e.start);
    Timestamp eventEnd = Timestamp.fromDate(e.end); //current event timebox

    QuerySnapshot ss = await booking
        .retrieveActiveEvents(uid); // current bookings for this user
    for (DocumentSnapshot doc in ss.docs) {
      String eid = await doc.get("eventId");
      DocumentReference docref = repository.collection.doc(eid);
      DocumentSnapshot docsnap = await docref.get();
      Timestamp activestart = await docsnap.get('start');
      Timestamp activeend = await docsnap.get('end');
      // case 1, curevent start < booking end
      // case 2, bookings has event that ends after curevent starts
      if (((activeend.compareTo(eventStart) < 0) &&
              (activestart.compareTo(activeend)) < 0) ||
          ((activestart.compareTo(eventEnd) > 0) &&
              (activeend.compareTo(activestart)) > 0)) {
        continue; //no clash
      } else {
        return 1;
      }
    }
    return 0;
  }

  ///Helper Function of ViewEventPopUp which returns result to Helper Function JoinLeaveCheck.
  ///Returns a string reprsenting the status of whether user can complete the event.
  ///Possible statuses:
  ///1. Not at location (cannot complete -- user cannot be at the event based on mismatch of location)
  ///2. Completed (cannot complete -- user has already completed event)
  ///3. Can Complete
  ///4. Event expired (cannot complete -- event has already ended)
  ///5. Future event (cannot complete -- event has yet to start )
  Future<String> canCompleteEvent(String uid, RetrievedEvent curEvent) async {
    LocationData userLocation = await checkLocation();
    BookingRepository booking = BookingRepository();
    var sportsfacildatasource = SportsFacilDataSource();
    List<SportsFacility> objects =
        await sportsfacildatasource.getSportsFacilities();
    DateTime? curTime = DateTime.now();
    SportsFacility obj = objects[265]; // aljunied swimming complex
    var lat2 = obj.coordinates.latitude;
    var lon2 = obj.coordinates.longitude;
    bool inRadius = calculateDistance(
            userLocation.latitude, userLocation.longitude, lat2, lon2) <
        1000000000;
    String completeStatus = "error";
    bool found = false;

    //check in order (1) time (2) location (3) if already completed
    if (curTime.isAfter(curEvent.start) & curTime.isBefore(curEvent.end)) {
      if (inRadius) {
        print("yes in radius");
        QuerySnapshot zz = await booking.retrievePastEvents(uid);
        for (DocumentSnapshot doc in zz.docs) {
          String eid = await doc.get("eventId");
          if (eid == curEvent.eventId) {
            completeStatus = "completed";
            found = true;
          }
        }

        if (found == false) {
          QuerySnapshot ss = await booking
              .retrieveActiveEvents(uid); // current bookings for this user

          for (DocumentSnapshot doc in ss.docs) {
            String eid = await doc.get("eventId");
            if (eid == curEvent.eventId) {
              bool active = await doc.get('active');
              found = true;
              //print("booking repo status: ${active}");
              if (active) {
                completeStatus = "can complete";
              }
            }
          }
        }
      } else {
        completeStatus = "not at location";
      }
    } else {
      if (curTime.isAfter(curEvent.end)) {
        completeStatus = "event expired"; //checked
      } else if (curTime.isBefore(curEvent.start)) {
        completeStatus = "future event"; //checked
      } else {
        completeStatus = "invalid timing";
      }
    }
    //print("canComplete check: ${completeStatus}");
    return completeStatus;
  }

  /// Helper Function of ViewEventPopUp to check whether button shown is "Join Event" / "Leave Event"
  Future JoinLeaveCheck(RetrievedEvent curEvent) async {
    String _newStatus;
    String _completeStatus = "unchecked";

    int hasBooking = await booking.checkUser(uid, curEvent.eventId);
    if (hasBooking == -1) {
      _newStatus = "not logged in";
    } else if (hasBooking == 1) {
      _newStatus = "joined";
      _completeStatus = await canCompleteEvent(uid, curEvent);
    } else {
      // has not joined this event
      // now must check if user CAN join the event
      int hasClash = await hasActiveEvent(uid, curEvent);

      if (curEvent.curCap < curEvent.maxCap) {
        if (hasClash == 0) {
          _newStatus = "can join";
        } else {
          //clashing timing
          _newStatus = "timing clash";
        }
      } else {
        _newStatus = "event full";
      }
    }
    setState(() {
      // print("join status ${_newStatus}");
      status = _newStatus;
      completeStatus = _completeStatus;
    });
  }

  ///Helper Function of ViewEventPopUp to decide what buttons should be shown
  ///by checking whether the user can join the event or not
  ///and if so, whether the user can complete the event or not
  Widget renderButton(RetrievedEvent _curEvent) {
    if (status != "unchecked") {
      if (status == "not logged in") {
        return NotLoggedInButton();
      } else if (status == "joined") {
        Widget statusChip = Chip(
          label: Text(completeStatus),
        );

        if (completeStatus == "not at location") {
          statusChip = Chip(label: Text("You are not here!"));
        } else if (completeStatus == "event expired") {
          return Chip(
              backgroundColor: Colors.red[300],
              avatar: Icon(
                Icons.timer,
                color: Colors.white,
              ),
              label: Text(
                "EXPIRED EVENT",
                style: TextStyle(color: Colors.white),
              )); //cannot leave this event anymore
        } else if (completeStatus == "future event") {
          statusChip = Chip(
              backgroundColor: Colors.amber,
              avatar: Icon(Icons.calendar_month),
              label: Text("Please Wait"));
        } else if (completeStatus == "completed") {
          return statusChip = Chip(
              backgroundColor: Colors.indigo,
              avatar: Icon(
                Icons.star,
                color: Colors.white,
              ),
              label: Text(
                "Completed Event",
                style: TextStyle(color: Colors.white),
              ));
        } else if (completeStatus == "can complete") {
          statusChip = CompleteEventButton(
              curEvent: _curEvent,
              buttonFunction: () async {
                String key = _curEvent.eventId;
                booking.completeBooking(uid, key);
              },
              buttontext: "Complete Event");
        }

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: LeaveButton(
                    curEvent: _curEvent,
                    leaveFunction: () async {
                      String key = _curEvent.eventId;
                      if (_curEvent.curCap > 0) {
                        _curEvent.curCap -= 1;
                        booking.deleteBooking(uid, key);
                      }
                      if (_curEvent.curCap == 0) {
                        repository.deleteEvent(_curEvent.toSportEvent(), key);
                      } else {
                        repository.updateEvent(_curEvent.toSportEvent(), key);
                      }
                    }),
              ),
              Expanded(
                child: statusChip,
              ),
            ],
          ),
        );
      } else if (status == "can join") {
        return GreenButton(
          curEvent: _curEvent,
          buttontext: "Join Event",
          buttonFunction: () {
            String key = _curEvent.eventId;
            if (_curEvent.curCap < _curEvent.maxCap) {
              _curEvent.curCap += 1;
              bool active = true;
              booking.addBooking(uid, key, active);
              repository.updateEvent(_curEvent.toSportEvent(), key);
              print('hello ${uid}. Added booking successfully!');
            }
          },
        );
      } else if (status == "event full") {
        return FullEventButton();
      } else {
        //status == "timing clash"
        return ClashingSchedButton();
      }
    } else {
      return Container(
        child: LinearProgressIndicator(),
        color: Colors.amberAccent,
      );
    }
  }
}

/// Helper Fucntion to Find background image path according to the facility Type
/// Returns a string for the image path to ViewEventPopUp
String _FindBackgroundImage(String facilityType) {
  if (facilityType.contains("Gym")) {
    return ('assets/images/view-event-gym.png');
  }
  if (facilityType.contains("wim")) {
    return ('assets/images/view-event-swimming.png');
  }
  if (facilityType.contains("ennis")) {
    return ('assets/images/view-event-tennis.png');
  }
  if (facilityType.contains('all')) {
    return ('assets/images/view-event-basketball.png');
  }
  if (facilityType.contains("tadium")) {
    return ('assets/images/stadium-hover.png');
  }
  return ('assets/images/view-event-soccer.png');
}

///Helper Function to check whether the user is in the vicinity of the event
///Result is returned to canCompleteEvent function
double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)) * 1000;
}
