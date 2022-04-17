import 'package:flutter/material.dart';

/// Widget built on friend_profile_page displaying stats of selected user
class FriendsDisplayWidget extends StatelessWidget {
  List<dynamic> friends;
  int points;
  FriendsDisplayWidget(this.friends, this.points, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, friends.length.toString(), 'Friends'),
          buildDivider(),
          buildButton(context, points.toString(), 'Points')
        ],
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
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );
}
