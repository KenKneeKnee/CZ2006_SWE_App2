import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/screens/friend_profile_page.dart';

class Friend_Page extends StatefulWidget {
  final List<dynamic> friends;
  const Friend_Page({Key? key, required this.friends}) : super(key: key);
  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<Friend_Page> {
  final myController = TextEditingController();
  final UserDbManager repository = UserDbManager();
  late List<dynamic> friendData = widget.friends;
  final List<UserData> listfriends = [];
  ScrollController controller = ScrollController();
  final List<Widget> friendbuttons = [];
  double topContainer = 0;
  UserDbManager userdb = UserDbManager();
  late UserData cu;
  getUser() async {
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    cu = UserData.fromSnapshot(doc);
  }

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

          friendbuttons.clear();

          for (UserData u in listfriends) {
            friendbuttons.add(Container(
                height: size.height * 0.15,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(100), blurRadius: 2.0),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                u.userid.toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //Button to press
                              // FloatingActionButton.extended(
                              //     onPressed: () {
                              //       Navigator.of(context).push(
                              //         MaterialPageRoute(
                              //             //change to test pages
                              //             builder: (context) =>
                              //                 FriendProfilePage(u: u)),
                              //       );
                              //     },
                              //     label: const Text('Visit'),
                              //     backgroundColor: Colors.orange),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          Image.asset(
                            u.image,
                            height: double.infinity,
                          )
                        ]))));
          }

          //Appbar kinda of the page
          return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Color(0xFF60d5df),
                    leading: BackButton(
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop()),
                  ),
                  body: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Image.asset('assets/images/invite-friends.png',
                            scale: 1),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Invite more friends",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: TextField(
                                    controller: myController,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: () {
                                      late UserData su;
                                      for (DocumentSnapshot doc in DocList) {
                                        if (doc["userid"] ==
                                            myController.text) {
                                          su = UserData.fromSnapshot(doc);
                                        }
                                      }

                                      print(su.userid);
                                      try {
                                        if (!cu.friends.contains(su.userid) &&
                                            cu.userid != su.userid) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                //change to test pages
                                                builder: (context) =>
                                                    FriendProfilePage(u: su)),
                                          );
                                        }
                                      } finally {
                                        //
                                      }
                                    },
                                    icon: Icon(Icons.search,
                                        color: Colors.black)),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Friends List",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30.0),
                                bottomRight: Radius.circular(0.0),
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(0.0)),
                          ),
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                          child: SizedBox(
                            height: 300,
                            child: ListView.builder(
                                shrinkWrap: true,
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
                                          heightFactor: 0.8,
                                          alignment: Alignment.topCenter,
                                          child: friendbuttons[index]),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  )));
        });
  }
}
