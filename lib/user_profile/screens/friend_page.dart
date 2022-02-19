import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/screens/friend_profile_page.dart';
import 'package:my_app/user_profile/screens/profile_page.dart';

class Friend_Page extends StatefulWidget {
  final List<dynamic> friends;
  const Friend_Page({Key? key, required this.friends}) : super(key: key);
  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<Friend_Page> {
  final UserDbManager repository = UserDbManager();
  late List<dynamic> friendData = widget.friends;
  final List<UserData> listfriends = [];
  ScrollController controller = ScrollController();
  final List<Widget> friendbuttons = [];
  double topContainer = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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

          listfriends.clear();
          for (String userid in friendData) {
            for (DocumentSnapshot doc in DocList) {
              if (doc["userid"] == userid) {
                u = UserData.fromSnapshot(doc);
                listfriends.add(u);
              }
            }
          }
          print(listfriends.length);

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
                              FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          //change to test pages
                                          builder: (context) =>
                                              FriendProfilePage(u)),
                                    );
                                  },
                                  label: const Text('Visit'),
                                  backgroundColor: Colors.orange),
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
                          // Image.asset(
                          //   "assets/images/${post["image"]}",
                          //   height: double.infinity,
                          //)
                        ]))));
          }

          return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: BackButton(
                        color: Colors.black,
                        onPressed: () => Navigator.of(context).pop()),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  body: Container(
                    height: size.height,
                    child: ListView.builder(
                        controller: controller,
                        itemCount: friendbuttons.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          double scale = 1.0;
                          if (topContainer > 0.5) {
                            scale = index + 0.5 - topContainer;
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
}
