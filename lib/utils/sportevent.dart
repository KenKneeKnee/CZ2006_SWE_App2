import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SportEvent {
  final String name;
  // late String id;
  final DateTime start;
  final DateTime end;
  final int maxCap;
  int curCap;
  final String placeId;

  SportEvent(
      this.name, this.start, this.end, this.maxCap, this.curCap, this.placeId);

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
  String toString() => 'Event<$SportEvent>';
}

// 1
SportEvent _EventFromJson(Map<String, dynamic> json) {
  return SportEvent(
    json['name'] as String,
    (json['start'] as Timestamp).toDate(),
    (json['end'] as Timestamp).toDate(),
    json['maxCap'] as int,
    json['curCap'] as int,
    json['placeId'] as String,
  );
}

// 2
Map<String, dynamic> _EventToJson(SportEvent instance) => <String, dynamic>{
      'name': instance.name,
      //'id': instance.id,
      'start': instance.start,
      'end': instance.end,
      'maxCap': instance.maxCap,
      'curCap': instance.curCap,
      'placeId': instance.placeId
    };
