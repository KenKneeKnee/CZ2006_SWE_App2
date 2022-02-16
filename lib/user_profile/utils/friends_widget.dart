import 'package:flutter/material.dart';

class FriendsWidget extends StatelessWidget {
  List<dynamic> friends;
  List<dynamic> friendrequests;
  int points;

  FriendsWidget(this.friends, this.friendrequests, this.points);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, friends.length.toString(), 'Friends'),
          buildDivider(),
          buildButton(
              context, friendrequests.length.toString(), 'Friend Requests'),
          buildDivider(),
          buildButton(context, points.toString(), 'Points')
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
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
