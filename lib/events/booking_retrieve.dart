import 'package:flutter/material.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


final uid = FirebaseAuth.instance.currentUser!.email as String;


class bookingPage extends StatefulWidget {
  bookingPage({Key? key}) : super(key: key);
  _bookingPageState createState() => _bookingPageState();
}

class _bookingPageState extends State<bookingPage> {
  final EventRepository repository = EventRepository();
  final BookingRepository booking = BookingRepository();




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<QuerySnapshot>(
      stream: booking.getStream(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1){
        return StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            List pastEventIds =[];
            for (DocumentSnapshot doc in BookingList) {
              if (doc['userId'] == uid) {
                if(doc['active'] == true){
                  activeEventIds.add(doc['eventId']);}
                      }
              else{
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




            return Scaffold(
                appBar: AppBar(title: const Text("Event Page")),
                body: ListView.builder(
                    shrinkWrap: true,
                    itemCount: PastEventMap.length,
                    padding: const EdgeInsets.only(top: 10.0),
                    itemBuilder: (context, index) {
                      String key = PastEventMap.keys.elementAt(index);
                      SportEvent curEvent = PastEventMap[key] as SportEvent;
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
                        ]),

                      );

                    }));
          },
        );
      },
    );
  }
}
