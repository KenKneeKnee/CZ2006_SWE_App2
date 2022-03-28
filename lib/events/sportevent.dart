import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SportEvent {
  final String name;
  final DateTime start;
  final DateTime end;
  final int maxCap;
  int curCap;
  final String placeId;
  bool active;
  final String type;

  /// Description of what will be in the event
  // final String activity;

  SportEvent(
    {required this.name, required this.start, required this.end, required this.maxCap,
      required this.curCap, required this.placeId, required this.type, required this.active});

  factory SportEvent.fromSnapshot(DocumentSnapshot snapshot) {
    final newEvent =
        SportEvent.fromJson(snapshot.data() as Map<String, dynamic>);
    //newEvent.id = snapshot.reference.id;
    return newEvent;
  }

  factory SportEvent.fromJson(Map<String, dynamic> json) =>
      _EventFromJson(json);
  Map<String, dynamic> toJson() => _EventToJson(this);

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
}

// 1
SportEvent _EventFromJson(Map<String, dynamic> json) {
  return SportEvent(
    name: json['name'] as String,
    start: (json['start'] as Timestamp).toDate(),
    end: (json['end'] as Timestamp).toDate(),
    maxCap: json['maxCap'] as int,
    curCap: json['curCap'] as int,
    placeId: json['placeId'] as String,
    type: json['type'] as String,
    active: json['active'] as bool,
  );
}

// 2
Map<String, dynamic> _EventToJson(SportEvent instance) => <String, dynamic>{
  'name': instance.name,
  'start': instance.start,
  'end': instance.end,
  'maxCap': instance.maxCap,
  'curCap': instance.curCap,
  'placeId': instance.placeId,
  'type':instance.type,
  'active':instance.active,
};
