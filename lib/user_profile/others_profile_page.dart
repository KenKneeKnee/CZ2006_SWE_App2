import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/login_page.dart';
import 'package:my_app/start/utils/fire_auth.dart';
import 'package:my_app/user_profile/user.dart';
import 'package:my_app/user_profile/userDbManager.dart';

class OtherProfilePage extends StatefulWidget {
  final User user;

  const OtherProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<OtherProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  late User _searchedUser;

  final UserDbManager repository = UserDbManager();

  @override
  void initState() {
    // need pass value
    _searchedUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: repository.getStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        UserData u = UserData.fromSnapshot(snapshot.data!.docs[0]);

        List DocList = snapshot.data!.docs;

        for (DocumentSnapshot doc in DocList) {
          if (doc['userid'] == _searchedUser.email) {
            u = UserData.fromSnapshot(doc);
          }
        }
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("userid: " + u.userid.toString()),
                Text("username: " + u.username.toString()),
                Text("points: " + u.points.toString()),
                Text("reports: " + u.reports.toString()),
                Text("friends:" + u.friends.toString()),
                Text("friendrequest:" + u.friendrequests.toString()),
                FloatingActionButton(
                    onPressed: () {
                      u.points = u.points + 1;
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add_circle_rounded)),
                FloatingActionButton(
                    onPressed: () {
                      u.points = u.points - 1;
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.remove)),
              ],
            ),
          ),
        );
      },
    );
  }
}
