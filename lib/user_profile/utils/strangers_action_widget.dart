import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/screens/others_profile_page.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

class StrangersActionWidget extends StatefulWidget {
  UserData u;
  StrangersActionWidget(this.u);

  _StrangersActionWidgetState createState() => _StrangersActionWidgetState();
}

class _StrangersActionWidgetState extends State<StrangersActionWidget> {
  late UserData u;
  late UserData cu;
  UserDbManager userdb = UserDbManager();
  @override
  void initState() {
    getUser();
    u = widget.u;

    super.initState();
  }

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
            if (!u.friendrequests.contains(cu.userid) &&
                !cu.friendrequests.contains(u.userid)) {
              u.friendrequests.add(cu.userid);
              userdb.collection
                  .doc(u.userid)
                  .update({"friendrequests": u.friendrequests});
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildRequestDialog(context));
            } else {
              showDialog(
                  // needs some UI
                  context: context,
                  builder: (BuildContext context) =>
                      _buildRequestSentDialog(context));
            }
          },
          label: const Text('Add as Friend'),
          backgroundColor: Colors.green,
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
}

@override
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
