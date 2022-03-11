import 'package:flutter/material.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/user_profile/utils/appbar_widget.dart';

final uid = FirebaseAuth.instance.currentUser!.email as String;

class bookingPage extends StatefulWidget {
  bookingPage({Key? key}) : super(key: key);
  _bookingPageState createState() => _bookingPageState();
}

class _bookingPageState extends State<bookingPage> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();

  ScrollController controller = ScrollController();
  double topContainer = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      double value = controller.offset / 1000;

      setState(() {
        topContainer = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                List EventList = snapshot.data!.docs;
                List BookingList = snapshot1.data!.docs;
                Map<String, SportEvent> PastEventMap = {};
                Map<String, SportEvent> ActiveEventMap = {};
                List activeEventIds = [];
                List pastEventIds = [];
                final Size size = MediaQuery.of(context).size;

                List<Widget> eventbuttons = [];

                for (DocumentSnapshot doc in BookingList) {
                  if (doc['userId'] == uid) {
                    if (doc['active'] == true) {
                      activeEventIds.add(doc['eventId']);
                    }
                  } else {
                    pastEventIds.add(doc['eventId']);
                  }
                }

                for (String eid in pastEventIds) {
                  for (DocumentSnapshot doc in EventList) {
                    if (doc.id == eid) {
                      SportEvent e = SportEvent.fromSnapshot(doc);
                      PastEventMap[eid] = e;
                    }
                  }
                }

                for (String eid in activeEventIds) {
                  for (DocumentSnapshot doc in EventList) {
                    if (doc.id == eid) {
                      SportEvent e = SportEvent.fromSnapshot(doc);
                      ActiveEventMap[eid] = e;
                    }
                  }
                }

                for (String eventid in activeEventIds) {
                  SportEvent currentevent =
                      ActiveEventMap[eventid] as SportEvent;

                  eventbuttons.add(Container(
                      height: size.height * 0.2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      currentevent.name.toString(),
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                    FloatingActionButton.extended(
                                        onPressed: () {},
                                        label: const Text('View'),
                                        backgroundColor: Colors.orange),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ]))));
                }

                return SafeArea(
                    child: Scaffold(
                        backgroundColor: Colors.white,
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: Color(0xffE3663E),
                          leading: BackButton(
                              color: Colors.black,
                              onPressed: () => Navigator.of(context).pop()),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.search, color: Colors.black),
                              onPressed: () {},
                            ),
                          ],
                        ),
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
        });
  }
}
