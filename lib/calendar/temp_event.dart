///////just ignore this file for now
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
final repository = EventRepository();

/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
// final kEvents = LinkedHashMap<DateTime, List<SportEvent>>(
//   // Each pair is the list of events (value) for a particular day (key)
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll(_kEventSource);

final Map<DateTime, List<SportEvent>> realEventSource = {};

List<SportEvent> realTodaySource = [];

// final kEvents = Map<DateTime, List<SportEvent>>()..addAll(_sEventSource);

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

class EventDataFetcher {
  Future fetchDayEvent(DateTime day) async {
    DateTime curDay = DateTime(day.year, day.month, day.day);
    DateTime nextDay =
        DateTime(day.year, day.month, day.day).add(const Duration(hours: 24));
    Timestamp timestamp1 = Timestamp.fromDate(curDay);
    Timestamp timestamp2 = Timestamp.fromDate(nextDay);
    List res = [];
    List<SportEvent> gamelist = [];
    await repository.collection
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
      SportEvent ge = SportEvent(event.get("name"), _start, _end,
          event.get("maxCap"), event.get("curCap"), event.get("placeId"));
      gamelist.add(ge);
    }

    // print(
    //     'fetchDayEvent: fetched ${gamelist.length} events for ${day} from DB! C:');
    return gamelist;
  }

  Future fetchAllEvent(DateTime start, DateTime end) async {
    Map<DateTime, List<SportEvent>> grrMap = <DateTime, List<SportEvent>>{};
    final dayCount = end.difference(start).inDays;

    DateTime curDay = start;
    print('start fetching!');
    realTodaySource = await fetchDayEvent(curDay);

    for (int i = 0; i <= dayCount; i++) {
      curDay = curDay.add(const Duration(days: 1));
      List<SportEvent> dayEvents = await fetchDayEvent(curDay);
      grrMap[curDay] = dayEvents;
      realEventSource[curDay] = dayEvents;
    }
    print('finished fetching ${realEventSource.length + 1} entries !');
    return grrMap;
  }
}
