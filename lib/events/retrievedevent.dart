import 'package:intl/intl.dart';
import 'package:my_app/events/sportevent.dart';

class RetrievedEvent {
  final String name;
  final DateTime start;
  final DateTime end;
  final int maxCap;
  int curCap;
  final String placeId;
  final String eventId;

  /// Description of what will be in the event
  // final String activity;

  RetrievedEvent(
      this.name, this.start, this.end, this.maxCap, this.curCap, this.placeId, this.eventId);

  @override
  String toString() {
    final DateFormat formatter = DateFormat.jm();
    return ('${name} \n ${formatter.format(start)} - ${formatter.format(end)} \n ${curCap}/${maxCap}');
  }

  String toTime() {
    final DateFormat formatter = DateFormat.jm();
    return ('${formatter.format(start)} - ${formatter.format(end)}');
  }

  String toCap() {
    final DateFormat formatter = DateFormat.jm();
    return ('${curCap}/${maxCap}');
  }

  SportEvent toSportEvent() {
    return SportEvent(name, start, end, maxCap, curCap, placeId);
  }
}
