class UserData {
  late final String userid;
  late final String username;
  late final int points;
  late final List<String> friend;
  late final List<String> friendrequests;
  late final int reports;

  UserData(this.userid, this.username) {
    this.points = 0;
    this.reports = 0;
    friend = List.empty();
    friendrequests = List.empty();
  }

  String get_userid() {
    return userid;
  }

  int get_points() {
    return points;
  }

  String get_username() {
    return username;
  }

  // ignore: non_constant_identifier_names
  set_points(int newpoints) {
    this.points = newpoints;
  }
}

// 1
