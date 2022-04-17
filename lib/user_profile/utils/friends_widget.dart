import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/user_profile/screens/friend_page.dart';
import 'package:my_app/user_profile/screens/requests_page.dart';
import 'package:my_app/user_profile/screens/view_past_events_page.dart';

/// Widget built on profile_page displaying stats of current user
class FriendsWidget extends StatelessWidget {
  List<dynamic> friends;
  List<dynamic> friendrequests;
  int points;

  FriendsWidget(this.friends, this.friendrequests, this.points);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: buildFButton(context, friends.length.toString(),
                        'Friends', Colors.orange)),
                Expanded(
                  child: buildRButton(context, friendrequests.length.toString(),
                      'Requests', Colors.pink),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: buildPButton(
                        context, points.toString(), 'Points', Colors.purple)),
                Expanded(
                    child: buildEButton(
                        context,
                        round((points / 20)).toStringAsFixed(0),
                        'Events',
                        Colors.green)),
              ],
            )
          ],
        ),
      );

  /// Utility widget to add space between elements
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  /// Button widget displaying number of past events the user have joined
  ///
  /// Leads to view_past_events_page when pressed
  Widget buildEButton(
          BuildContext context, String value, String text, Color color) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ViewEventPage()),
          );
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, color: color),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24, color: color),
                ),
                SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      );

  /// Button widget displaying number of friends the user have
  ///
  /// Leads to friend_page when pressed
  Widget buildFButton(
          BuildContext context, String value, String text, Color color) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Friend_Page(friends: friends),
          ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, color: color),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24, color: color),
                ),
                SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      );

  /// Button widget displaying number of friend requests that the user have
  ///
  /// Leads to requests_page when pressed
  Widget buildRButton(
          BuildContext context, String value, String text, Color color) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Request_Page(friendrequests: friendrequests),
          ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, color: color),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24, color: color),
                ),
                SizedBox(height: 2),
                Text(text,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      );

  /// (Unused)Button widget displaying number of points the user have
  ///
  /// Leads to rewards_page when pressed
  Widget buildPButton(
          BuildContext context, String value, String text, Color color) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        onPressed: () {
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => RewardsPage(),
          // ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: color),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24, color: color),
                ),
                SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      );
}
