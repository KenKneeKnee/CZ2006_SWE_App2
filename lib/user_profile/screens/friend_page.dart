import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

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
    print('received a list ${widget.friends.length}');
    print('first friend is ${widget.friends[0]}');
    controller.addListener(() {
      double value = controller.offset / 119;
      setState(() {
        topContainer = value;
      });
<<<<<<< HEAD

      UserData tempuser = new UserData(
          data["userid"],
          data["username"],
          data["points"],
          data["reports"],
          data["friends"],
          data["friendrequests"],
          data["about"]);

      listofUsers.add(tempuser);
    });

    listofUsers.forEach((user) {
      listItems.add(Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.username,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.userid.toString(),
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      user.points.toString(),
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Image.asset(
                  "assets/images/1573252249390.jpeg",
                  height: double.infinity,
                )
              ],
            ),
          )));
    });

    setState(() {
      friendsData = listItems;
=======
>>>>>>> c55c065a7874fc52fa5c45e57bd36c2c857d288c
    });
    print(friendsData.length);
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
          print('initial list : ${listfriends.length}');
          for (String userid in friendData) {
            for (DocumentSnapshot doc in DocList) {
              if (doc["userid"] == userid) {
                u = UserData.fromSnapshot(doc);
                listfriends.add(u);
              }
            }
          }

          for (UserData u in listfriends) {
            friendbuttons.add(Container(
                height: size.height * 0.5,
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
                              SizedBox(
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
          print('friend button list : ${friendbuttons.length}');

          return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                    actions: <Widget>[
                      Text("HI",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.search, color: Colors.black),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.black),
                        onPressed: () {},
                      )
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
                                  heightFactor: 0.8,
                                  alignment: Alignment.topCenter,
                                  child: friendbuttons[index]),
                            ),
                          );
                        }),
                  )));
        });
  }
}
