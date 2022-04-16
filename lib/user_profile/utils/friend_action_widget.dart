import 'package:flutter/material.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/screens/friend_invite_page.dart';

/// Widget built on friend_profile_page
/// if current user is friends with selected user
///
/// Contains actions that current user can take on selected user
class FriendsActionWidget extends StatelessWidget {
  UserDbManager userdb = UserDbManager();
  UserData u;
  FriendsActionWidget(this.u, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        ElevatedButton(
          onPressed: () {},
          child: Row(
            children: const [
              Icon(Icons.check),
              Text('Friends'),
            ],
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
        FloatingActionButton.extended(
          onPressed: () {
            userdb.collection.doc(u.userid).update({"reports": u.reports + 1});
            showDialog(
                context: context,
                builder: (BuildContext context) => _buildReportDialog(context));
          },
          label: const Text('Report'),
          backgroundColor: Colors.red,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Friend_Invite_Page(friends: u.friends),
                ));
              },
              label: Row(
                children: const [
                  Icon(Icons.people),
                  Text(' Invite'),
                ],
              ),
              backgroundColor: Colors.deepOrangeAccent,
            ),
          ),
        ),
      ]);

  /// Utility Widget for adding space between elements
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  /// Dialog that appears when selected user is reported
  Widget _buildReportDialog(BuildContext context) {
    return UserProfileDialog(bgDeco: DialogBoxDecoration.userReportedBg);
  }

  /// Dialog that appears when current user sends a friend request
  Widget _buildRequestDialog(BuildContext context) {
    return UserProfileDialog(bgDeco: DialogBoxDecoration.friendAddedBg);
  }
}

class UserProfileDialog extends StatelessWidget {
  UserProfileDialog({
    Key? key,
    required this.bgDeco,
  }) : super(key: key);
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
