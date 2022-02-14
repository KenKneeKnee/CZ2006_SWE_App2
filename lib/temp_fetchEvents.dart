import 'package:flutter/material.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/events/event_repository.dart';

class eventPage extends StatefulWidget {
  eventPage({Key? key}) : super(key: key);
  _eventPageState createState() => _eventPageState();
}

class _eventPageState extends State<eventPage> {
  final EventRepository repository = EventRepository();

  void join(SportEvent e, String key) {
    if (e.curCap < e.maxCap) {
      e.curCap += 1;
    }
    repository.updateEvent(e, key);
  }

  void leave(SportEvent e, String key) {
    if (e.curCap > 0) {
      e.curCap -= 1;
    }
    repository.updateEvent(e, key);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        List DocList = snapshot.data!.docs;
        Map<String, SportEvent> EventMap = {};
        for (DocumentSnapshot doc in DocList) {
          if (doc['placeId'] == "hellohello") {
            SportEvent e = SportEvent.fromSnapshot(doc);
            EventMap[doc.id] = e;
          }
        }

        return Scaffold(
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
                          onPressed: () {
                            join(curEvent,key);
                          },
                          color: Colors.green,
                          icon: const Icon(
                            Icons.add_circle_rounded,
                          )),
                      IconButton(
                          onPressed: () {
                            leave(curEvent,key);
                            if (curEvent.curCap==0){
                              repository.deleteEvent(curEvent, key);
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
  }
}
