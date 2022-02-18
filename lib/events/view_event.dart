import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/map/map_data.dart';
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
  final SportEvent event;
  // late String placeId = index.toString();

  @override
  _ViewEventPopUpState createState() => _ViewEventPopUpState();
}

class _ViewEventPopUpState extends State<ViewEventPopUp> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();
  void join(SportEvent e, String key) {
    if (e.curCap < e.maxCap) {
      e.curCap += 1;
      booking.addBooking(uid, key);
      repository.updateEvent(e, key);
    }
  }

  void leave(SportEvent e, String key) {
    if (e.curCap > 0) {
      e.curCap -= 1;
      booking.deleteBooking(uid, key);
    }
    if (e.curCap == 0) {
      repository.deleteEvent(e, key);
    } else {
      repository.updateEvent(e, key);
    }
  }

  @override
  Widget build(BuildContext context) {
    SportEvent curEvent = widget.event;
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
                      RoundedBackgroundImage(
                          imagePath: 'view-event-background.png'),
                      Container(
                        decoration: _baseContainer,
                        margin: EdgeInsets.fromLTRB(15, 60, 15, 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            children: [
                              _calendarIcon,
                              Title(widget.event.name),
                              Text(
                                widget.SportsFacil.addressDesc,
                                style: _subtitleStyle,
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                      child: _TextWithIcon(
                                          widget.event.toTime(), _timeIcon)),
                                  Flexible(
                                      child: _TextWithIcon(
                                          '${widget.event.toCap()}\nplayers',
                                          _capIcon)),
                                ],
                              ),
                              _TextContainer('event description', context),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () async {
                                          // int hasBooking = await booking.checkUser(uid, key);
                                          // if (hasBooking > 0) {
                                          //   showDialog(
                                          //     context: context,
                                          //     builder: (context) => AlertDialog(
                                          //       title: Text(
                                          //           "AY MAN You've already joined this event!"),
                                          //       content: Text("Don't be stupid bro"),
                                          //       actions: [
                                          //         ElevatedButton(
                                          //             onPressed: () {
                                          //               Navigator.pop(context);
                                          //             },
                                          //             child: Text('Go Back'))
                                          //       ],
                                          //     ),
                                          //   );
                                          // } else {
                                          //   showDialog(
                                          //     context: context,
                                          //     builder: (context) => AlertDialog(
                                          //       title: const Text('Join Event'),
                                          //       content: const Text('Confirm?'),
                                          //       actions: <Widget>[
                                          //         TextButton(
                                          //           onPressed: () =>
                                          //               Navigator.pop(context, 'Cancel'),
                                          //           child: const Text('Cancel'),
                                          //         ),
                                          //         TextButton(
                                          //           onPressed: () {
                                          //             Navigator.pop(context, 'Ok');
                                          //             join(curEvent, key);
                                          //           },
                                          //           child: const Text('Ok'),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   );
                                          // }
                                        },
                                        color: Colors.green,
                                        icon: const Icon(
                                          Icons.add_circle_rounded,
                                        )),
                                    IconButton(
                                        onPressed: () async {
                                          //   String key = widget.event.
                                          //   int hasBooking = await booking.checkUser(uid, key);
                                          //   if (hasBooking == -1) {
                                          //     showDialog(
                                          //       context: context,
                                          //       builder: (context) => AlertDialog(
                                          //         title: Text("Account Error!"),
                                          //         content:
                                          //             Text("Please make sure you are logged in."),
                                          //         actions: [
                                          //           ElevatedButton(
                                          //               onPressed: () {
                                          //                 Navigator.pop(context);
                                          //               },
                                          //               child: Text('Go Back'))
                                          //         ],
                                          //       ),
                                          //     );
                                          //   }
                                          //   if (hasBooking == 0) {
                                          //     showDialog(
                                          //       context: context,
                                          //       builder: (context) => AlertDialog(
                                          //         title: Text("u havent join this yet"),
                                          //         content: Text("waiting for wat"),
                                          //         actions: [
                                          //           ElevatedButton(
                                          //               onPressed: () {
                                          //                 Navigator.pop(context);
                                          //               },
                                          //               child: Text('Go Back'))
                                          //         ],
                                          //       ),
                                          //     );
                                          //   } else {
                                          //     showDialog(
                                          //       context: context,
                                          //       builder: (context) => AlertDialog(
                                          //         title: const Text('Leave Event'),
                                          //         content: const Text('Confirm?'),
                                          //         actions: <Widget>[
                                          //           TextButton(
                                          //             onPressed: () =>
                                          //                 Navigator.pop(context, 'Cancel'),
                                          //             child: const Text('Cancel'),
                                          //           ),
                                          //           TextButton(
                                          //             onPressed: () {
                                          //               Navigator.pop(context, 'Ok');
                                          //               leave(curEvent, key);
                                          //             },
                                          //             child: const Text('Ok'),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     );
                                          //   }
                                        },
                                        color: Colors.red,
                                        icon: const Icon(Icons
                                            .remove_circle_outline_rounded)),
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

  BoxDecoration _baseContainer = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        spreadRadius: 2,
        color: Colors.grey,
        offset: const Offset(-1, 4),
        blurRadius: 3,
      )
    ],
  );

  Container _calendarIcon = Container(
    color: Colors.transparent,
    margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
    height: 50,
    child: Image.asset('icon-calendar.png'),
  );

  Icon _capIcon = const Icon(Icons.person);
  Icon _timeIcon = const Icon(Icons.timer);

  Container _TextWithIcon(String text, Icon icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
          color: Color(0xffEBEBEB),
          // border: Border.all(
          //   color: Colors.black,
          // ),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          icon,
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                text,
                style: _paraStyleBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _TextContainer(String text, BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.all(10),
        // margin: EdgeInsets.fromLTRB(5, 5, 5, 25),
        decoration: BoxDecoration(
            color: Color(0xffEBEBEB),
            // border: Border.all(
            //   color: Colors.black,
            // ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: _paraStyle,
          ),
        ),
      ),
    );
  }

  Padding Title(String text) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 3),
        child: Text(text, style: _TitleStyle));
  }

  /// Text Styles
  final _TitleStyle = TextStyle(
    color: Colors.grey[900],
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );

  final _subtitleStyle = TextStyle(
      color: Colors.grey[900],
      fontSize: 14,
      //fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic);

  final _paraStyle = TextStyle(
    color: Colors.grey[900],
    fontSize: 14,

    //fontWeight: FontWeight.bold,
  );
  final _paraStyleBold = TextStyle(
    color: Colors.grey[900],
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
}
