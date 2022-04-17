import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

/// Widget built on friend_profile_page
/// if current user is not friend with selected user
///
/// Contains actions that current user can take on selected user
class StrangersActionWidget extends StatefulWidget {
  UserData u;
  StrangersActionWidget(this.u);

  _StrangersActionWidgetState createState() => _StrangersActionWidgetState();
}

class _StrangersActionWidgetState extends State<StrangersActionWidget> {
  /// [UserData] of selected user
  late UserData u;

  /// [UserData] of current user
  late UserData cu;

  UserDbManager userdb = UserDbManager();
  @override
  void initState() {
    getUser();
    u = widget.u;

    super.initState();
  }

  /// Sets current user
  getUser() async {
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    cu = UserData.fromSnapshot(doc);
  }

  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FloatingActionButton.extended(
          onPressed: () {
            u.friendrequests.add(cu.userid);
            userdb.collection
                .doc(u.userid)
                .update({"friendrequests": u.friendrequests});
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildRequestDialog(context));
          },
          label: const Text('Add as Friend'),
          backgroundColor: Colors.green,
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
        )
      ]);
}

@override
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

/// Dialog that appears when current user sends a friend request
/// after a request has already been sent
Widget _buildRequestSentDialog(BuildContext context) {
  return AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text("A friend request has already been sent"),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
