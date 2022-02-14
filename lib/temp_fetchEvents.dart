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
        SportEvent e = SportEvent.fromSnapshot(snapshot.data!.docs[0]);
        return Column(
          children: [
            Text("event name: " + e.name),
            Text("start time: " + e.start.toString()),
            Text("end time: " + e.end.toString()),
            Text("max pax: " + e.maxCap.toString()),
            Text("current pax: " + e.curCap.toString()),
            FloatingActionButton(
                onPressed: () {
                  //join(e);
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add_circle_rounded)),
            FloatingActionButton(
                onPressed: () {
                  //leave(e);
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.remove)),
          ],
        );
      },
    );
  }
}
