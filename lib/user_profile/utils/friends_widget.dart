import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/rewards_page/screens/rewards_page.dart';
import 'package:my_app/user_profile/screens/friend_page.dart';
import 'package:my_app/user_profile/screens/requests_page.dart';
import 'package:my_app/user_profile/screens/view_past_events_page.dart';

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
                //buildDivider(),
                Expanded(
                  child: buildRButton(context, friendrequests.length.toString(),
                      'Requests', Colors.pink),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: buildPButton(
                        context, points.toString(), 'Points', Colors.purple)),
                //buildDivider(),
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
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

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
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
            SizedBox(
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
