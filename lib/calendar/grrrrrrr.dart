import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:my_app/calendar/temp_event.dart';
import 'package:table_calendar/table_calendar.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

var _kEventSource = realEventSource..addAll({DateTime.now(): realTodaySource});

class Grr extends StatefulWidget {
  const Grr({Key? key}) : super(key: key);

  @override
  _GrrState createState() => _GrrState();
}

class _GrrState extends State<Grr> {
  late bool loading;
  late Map<DateTime, List<GameEvent>> grrMap;
  late List<GameEvent> grrToday;
  Map<DateTime, List<GameEvent>> kEvents = {};

  late final ValueNotifier<List<GameEvent>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    loading = true;
    grrGetData();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  Future grrGetData() async {
    print('running grrGetData');
    var eventdatasource = EventDataFetcher();
    final todayData = await eventdatasource.fetchDayEvent(DateTime.now());
    final eventdata = await eventdatasource.fetchAllEvent(
        DateTime.now(), DateTime.now().add(const Duration(days: 7)));

    //await Future.delayed(const Duration(seconds: 3), () {});
    setState(() {
      grrMap = eventdata;
      grrToday = todayData;
      loading = false;
      kEvents = LinkedHashMap<DateTime, List<GameEvent>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(_kEventSource);
    });

    print('real event source has ${realEventSource.entries}');
    print('real today has ${realTodaySource}');
    print('kEvents has ${kEvents.entries}');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<GameEvent> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!loading)
        ? Card(
            color: Colors.amber,
            child: Column(
              children: [
                TableCalendar<GameEvent>(
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    // Use `CalendarStyle` to customize the UI
                    outsideDaysVisible: false,
                  ),
                  onDaySelected: _onDaySelected,
                  //onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                Container(
                  child: ValueListenableBuilder<List<GameEvent>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon:
                                        Icon(Icons.add_circle_outline_rounded),
                                    color: Colors.red),
                                IconButton(
                                  onPressed: () {},
                                  icon:
                                      Icon(Icons.remove_circle_outline_rounded),
                                  color: Colors.green,
                                ),
                                Expanded(
                                  //onTap: () => print('${value[index]}'),
                                  child: Text('${value[index]}'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : Container(color: Colors.amber);

    return (!loading)
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
            ),
            body: Container(
              color: Colors.blue,
              height: 100,
              child: TextButton(
                child: Text(
                  'check',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  print('grrMap has ${grrMap.length} items');
                  print('realEventSource has ${realEventSource.length} items');
                  realEventSource.forEach((key, value) {
                    print(key);
                    print(value);
                  });
                },
              ),
            ),
          )
        : LinearProgressIndicator();
  }
}
