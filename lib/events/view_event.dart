import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/retrievedevent.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/background.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;

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
  void join(RetrievedEvent e) {
    String key=e.eventId;
    if (e.curCap < e.maxCap) {
      e.curCap += 1;
      booking.addBooking(uid, key);
      repository.updateEvent(e.toSportEvent(), key);
    }
  }

  void leave(RetrievedEvent e) {
    String key=e.eventId;
    if (e.curCap > 0) {
      e.curCap -= 1;
      booking.deleteBooking(uid, key);
    }
    if (e.curCap == 0) {
      repository.deleteEvent(e.toSportEvent(), key);
    } else {
      repository.updateEvent(e.toSportEvent(), key);
    }
  }

  Future<int> hasActiveEvent(String uid, RetrievedEvent e) async {

    Timestamp eventStart = Timestamp.fromDate(e.start);
    Timestamp eventEnd = Timestamp.fromDate(e.end); //current event timebox

    QuerySnapshot ss = await booking.retrieveActiveEvents(uid); // current bookings for this user
    for (DocumentSnapshot doc in ss.docs) {
      String eid = await doc.get("eventId");
      DocumentReference docref = repository.collection.doc(eid);
      DocumentSnapshot docsnap = await docref.get();
      Timestamp activestart = await docsnap.get('start');
      Timestamp activeend = await docsnap.get('end');
      // case 1, curevent start < booking end
      // case 2, bookings has event that ends after curevent starts
      if (((activeend.compareTo(eventStart)<0) && (activestart.compareTo(activeend))<0)
          || ((activestart.compareTo(eventEnd)>0) && (activeend.compareTo(activestart))>0)){
        continue; //no clash
      } else {
        return 1;
      }
    }
    return 0;
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
                  return const Text('Something went wrong');
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Card(
                  child: Stack(
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
                              Row(
                                children: [
                                  Flexible(
                                      child: TextWithIcon(
                                          widget.event.toTime(), timeIcon)),
                                  Flexible(
                                      child: TextWithIcon(
                                          '${widget.event.toCap()}\nplayers',
                                          capIcon)),
                                ],
                              ),
                              TextContainer('event description', context),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () async{
                                          print(uid);
                                          int hasBooking = await booking.checkUser(uid, curEvent.eventId);
                                          int hasClash = await hasActiveEvent(uid, curEvent);
                                          if (hasBooking==-1) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Account Error!"),
                                                content: Text("Please make sure you are logged in."),
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
                                          else if (hasBooking>0){
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("AY MAN You've already joined this event!"),
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
                                          }
                                          else if (hasClash==1){
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("you have an active booking which clashes"),
                                                content: Text("leave other booking if you want this"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Go Back'))
                                                ],
                                              ),
                                            );
                                          } else{
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Join Event'),
                                                content: const Text('Confirm?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, 'Ok');
                                                      join(curEvent);
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return JoinedEventDialog(
                                                              bgDeco: DialogBoxDecoration
                                                                  .joinEventBg,
                                                              title: 'Joined Successfully!',
                                                              paragraph:
                                                              'Your fellow SportBuds can\'t wait to see you!',
                                                            );
                                                          });
                                                    },
                                                    child: const Text('Ok'),
                                                  ),
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
                                          int hasBooking = await booking.checkUser(uid, curEvent.eventId);
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
                                          else if (hasBooking == 0) {
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
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, 'Ok');
                                                      leave(curEvent);
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return LeftEventDialog(
                                                              bgDeco: DialogBoxDecoration
                                                                  .leaveEventBg,
                                                              title: 'Left successfully',
                                                              paragraph:
                                                              'Sorry to see you go. Hope to sometime soon!',
                                                            );
                                                          });
                                                    },
                                                    child: const Text('Ok'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        color: Colors.red,
                                        icon: const Icon(
                                            Icons.remove_circle_outline_rounded)),
                                  ]),
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
}

/// Find Marker image path according to the facility Type
String _FindBackgroundImage(String facilityType) {
  if (facilityType.contains("Gym")) {
    return ('view-event-gym.png');
  }
  if (facilityType.contains("wim")) {
    return ('view-event-swimming.png');
  }
  if (facilityType.contains("ennis")) {
    return ('view-event-tennis.png');
  }
  if (facilityType.contains('all')) {
    return ('view-event-basketball.png');
  }
  if (facilityType.contains("tadium")) {
    return ('stadium-hover.png');
  }

  return ('view-event-soccer.png');
}
