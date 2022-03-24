///////just ignore this file for now
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class GameEvent {
  final String title;
  final int currentCap;
  final int maxCap;

  const GameEvent(this.title, this.currentCap, this.maxCap);

  @override
  String toString() =>
      '${title} | currentCap : ${currentCap} | maxCap : ${maxCap}';
}

/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<GameEvent>>(
  // Each pair is the list of events (value) for a particular day (key)
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

<<<<<<< Updated upstream
// final kEvents = Map<DateTime, List<SportEvent>>()..addAll(_sEventSource);
=======
    List res = [];
    List<RetrievedEvent> gamelist = [];
    await repository.collection
        .where("placeId", isEqualTo: place)
        .where("start", isGreaterThanOrEqualTo: timestamp1)
        .where("start", isLessThan: timestamp2)
        .get()
        .then((value) {
      res = value.docs;
    });
    for (DocumentSnapshot event in res) {
      Timestamp _startTS = event.get("start");
      DateTime _start = _startTS.toDate();
      Timestamp _endTS = event.get("end");
      DateTime _end = _endTS.toDate();
      RetrievedEvent re = RetrievedEvent(event.get("name"), _start, _end,
          event.get("maxCap"), event.get("curCap"), event.get("placeId"), event.id, event.get("active"));
      gamelist.add(re);
    }
>>>>>>> Stashed changes

// //Map<DateTime, List<SportEvent>>
// _fetchEvents() {
//   final EventRepository repository = EventRepository();
//   return StreamBuilder<QuerySnapshot>(
//       stream: repository.getStream(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Text('Something went wrong');
//         }
//         if (!snapshot.hasData) {
//           return const CircularProgressIndicator();
//         }
//       }

// }

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
      item % 4 + 1,
      (index) => GameEvent('Event $item | ${index + 1}', 0, 0),
    )
}..addAll({
    kToday: [
      const GameEvent('Today\'s Event 1', 1, 10),
      const GameEvent('Today\'s Event 2', 1, 10),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount, //length of list -- ie. number of days in range
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3,
    kToday.day); //Sets first day to be 3 months earler
final kLastDay = DateTime(kToday.year, kToday.month + 3,
    kToday.day); //Sets last day to be 3 months later
