///////just ignore this file for now
import 'dart:collection';

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

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<GameEvent>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

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
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
