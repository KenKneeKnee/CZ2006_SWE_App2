import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/error_page.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/screens/friend_profile_page.dart';

///A page where user's friend requests appear
class Request_Page extends StatefulWidget {
  final List<dynamic> friendrequests;
  const Request_Page({Key? key, required this.friendrequests})
      : super(key: key);
  @override
  _FriendRequestState createState() => _FriendRequestState();
}

class _FriendRequestState extends State<Request_Page> {
  final UserDbManager repository = UserDbManager();
  UserDbManager userdb = UserDbManager();

  /// UserData of current user
  late UserData cu;

  /// List of userids of users who have sent a request to current user
  late List<dynamic> friendData = widget.friendrequests;

  /// List of UserData of users who have sent a request to current user
  List<UserData> listfriends = [];

  /// Controller for scrolling through request list
  ScrollController controller = ScrollController();

  /// List of cards for each requests in [cu.friendrequests]
  final List<Widget> friendbuttons = [];
  double topContainer = 0;

  @override
  void initState() {
    getUser();
    super.initState();
    controller.addListener(() {
      double value = controller.offset / 1000;
      setState(() {
        topContainer = value;
      });
    });
  }

  ///Sets the current user
  getUser() async {
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    cu = UserData.fromSnapshot(doc);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return SmthWrong();
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          UserData u = UserData.fromSnapshot(snapshot.data!.docs[0]);

          List DocList = snapshot.data!.docs;

          // Appends listfriends with UserData of users who have sent
          // a request to current user
          listfriends.clear();
          for (String userid in friendData) {
            for (DocumentSnapshot doc in DocList) {
              if (doc["userid"] == userid) {
                u = UserData.fromSnapshot(doc);
                listfriends.add(u);
              }
            }
          }

          // Adds a card for each user who have sent a request to current user
          friendbuttons.clear();
          for (UserData u in listfriends) {
            friendbuttons.add(Container(
                height: size.height * 0.3,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(100), blurRadius: 10.0),
                    ]),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                u.username,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                u.userid.toString(),
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(children: <Widget>[
                                FloatingActionButton.extended(
                                    // Visits the other user's profile page
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfilePage(u: u)),
                                      );
                                    },
                                    label: const Text('Visit'),
                                    backgroundColor: Colors.orange),
                                buildDivider(),
                                FloatingActionButton.extended(
                                    // Accepts friend request
                                    onPressed: () {
                                      cu.friends.add(u.userid);
                                      u.friends.add(cu.userid);
                                      u.friendrequests.remove(cu.userid);
                                      cu.friendrequests.remove(u.userid);

                                      userdb.collection.doc(u.userid).update(
                                          {"friendrequests": u.friendrequests});
                                      userdb.collection
                                          .doc(u.userid)
                                          .update({"friends": u.friends});
                                      userdb.collection
                                          .doc(cu.userid)
                                          .update({"friends": cu.friends});
                                      userdb.collection.doc(cu.userid).update({
                                        "friendrequests": cu.friendrequests
                                      });

                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) => Request_Page(
                                            friendrequests: cu.friendrequests),
                                      ));
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildRequestAcceptedDialog(
                                                  context));
                                    },
                                    label: const Text('Accept'),
                                    backgroundColor: Colors.greenAccent)
                              ]),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                u.points.toString(),
                                style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ]))));
          }

          /// Area where most elements of the page is built
          return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Color(0xffE3663E),
                    leading: BackButton(
                        color: Colors.black,
                        onPressed: () => Navigator.of(context).pop()),
                  ),
                  body: Container(
                    height: size.height,
                    child: ListView.builder(
                        controller: controller,
                        itemCount: friendbuttons.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          double scale = 1.0;
                          if (topContainer > 0.1) {
                            scale = index + 0.1 - topContainer;
                            if (scale < 0) {
                              scale = 0;
                            } else if (scale > 1) {
                              scale = 1;
                            }
                          }
                          return Opacity(
                            opacity: scale,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..scale(scale, scale),
                              alignment: Alignment.bottomCenter,
                              child: Align(
                                  heightFactor: 0.9,
                                  alignment: Alignment.topCenter,
                                  child: friendbuttons[index]),
                            ),
                          );
                        }),
                  )));
        });
  }

  /// Utility Widget for adding space between elements of the page
  Widget buildDivider() => Container(
        height: 12,
        child: VerticalDivider(),
      );

  /// Dialogs that appears when a request is accepted
  Widget _buildRequestAcceptedDialog(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text("Friend request accepted!"),
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
}
