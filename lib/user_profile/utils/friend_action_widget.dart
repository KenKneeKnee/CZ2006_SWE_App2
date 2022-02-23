import 'package:flutter/material.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/user_profile/screens/others_profile_page.dart';

class FriendsActionWidget extends StatelessWidget {
  FriendsActionWidget();

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        //can maybe change to remove friend
        FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('This bud is your friend!'),
          backgroundColor: Colors.lightGreen,
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
        FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => _buildReportDialog(context));
          },
          label: const Text('Report'),
          backgroundColor: Colors.red,
        )
      ]);
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );
  Widget _buildReportDialog(BuildContext context) {
    return UserProfileDialog(bgDeco: DialogBoxDecoration.userReportedBg);
  }

  Widget _buildRequestDialog(BuildContext context) {
    return UserProfileDialog(bgDeco: DialogBoxDecoration.friendAddedBg);
  }
}

class UserProfileDialog extends StatelessWidget {
  UserProfileDialog({
    Key? key,
    required this.bgDeco,
  }) : super(key: key);
  // String paragraph;
  // String title;
  BoxDecoration bgDeco;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 400,
        width: 400,
        decoration: bgDeco,
      ),
      actions: [],
    );
  }
}
