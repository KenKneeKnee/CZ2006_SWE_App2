import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  late final String? userid;
  late final String username;
  late final int points;
  late final List<dynamic> friends;
  late final List<dynamic> friendrequests;
  late final int reports;
  late final String about;

  UserData(this.userid, this.username, this.points, this.reports, this.friends,
      this.friendrequests, this.about);

  // ignore: non_constant_identifier_names
  void set_points(int newpoints) {
    this.points = newpoints;
  }

  factory UserData.fromSnapshot(DocumentSnapshot snapshot) {
    final userdata = UserData.fromJson(snapshot.data() as Map<String, dynamic>);

    return userdata;
  }

  factory UserData.fromJson(Map<String, dynamic> json) => _UserFromJson(json);

  Map<String, dynamic> toJson() => _UserToJson(this);
}

// 1
UserData _UserFromJson(Map<String, dynamic> json) {
  return UserData(
      json['userid'] as String,
      json['username'] as String,
      json['points'] as int,
      json['reports'] as int,
      List.from(json['friendrequests']) as List<dynamic>,
      List.from(json['friends']) as List<dynamic>,
      json['about'] as String);
}

// 2

Map<String, dynamic> _UserToJson(UserData instance) => <String, dynamic>{
      'userid': instance.userid,
      //'id': instance.id,
      'username': instance.username,
      'points': instance.points,
      'reports': instance.reports,
      'friendrequests': instance.friendrequests,
      'friends': instance.friends,
      'about': instance.about
    };



// 1
