import 'package:flutter/material.dart';

class FriendsActionWidget extends StatelessWidget {
  FriendsActionWidget();

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Add Friend'),
          backgroundColor: Colors.green,
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
        FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Report'),
          backgroundColor: Colors.red,
        )
      ]);
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );
}
