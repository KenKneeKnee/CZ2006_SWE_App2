import 'package:flutter/material.dart';
import 'package:my_app/rewards_page/screens/rewards_page.dart';
import 'package:my_app/user_profile/screens/friend_page.dart';
import 'package:my_app/user_profile/screens/requests_page.dart';

class FriendsWidget extends StatelessWidget {
  List<dynamic> friends;
  List<dynamic> friendrequests;
  int points;

  FriendsWidget(this.friends, this.friendrequests, this.points);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildFButton(context, friends.length.toString(), 'Friends'),
          buildDivider(),
          buildRButton(
              context, friendrequests.length.toString(), 'Friend Requests'),
          buildDivider(),
          buildPButton(context, points.toString(), 'Points')
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildFButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Friend_Page(friends: friends),
          ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget buildRButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Request_Page(friendrequests: friendrequests),
          ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget buildPButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (context) => RewardsPage(),
          // ));
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
