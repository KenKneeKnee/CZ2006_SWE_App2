import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/error_page.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/screens/friend_profile_page.dart';

/// A page where users' friends are shown and where user may search
/// for other users
class Friend_Page extends StatefulWidget {
  final List<dynamic> friends;
  const Friend_Page({Key? key, required this.friends}) : super(key: key);
  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<Friend_Page> {
  bool isSearchClicked = false;
  final UserDbManager repository = UserDbManager();
  UserDbManager userdb = UserDbManager();

  /// TextController to search for other users
  final TextEditingController _filter = TextEditingController();

  /// List of [cu.friends]'s [userid]
  late List<dynamic> friendData = widget.friends;

  /// List of [cu.friends]'s [UserData]
  final List<UserData> listfriends = [];

  /// Controller for scrolling through friend list
  ScrollController controller = ScrollController();

  /// List of cards for each friend in [cu.friends]
  final List<Widget> friendbuttons = [];

  /// Start coordiante of first card
  double topContainer = 0;

  /// [UserData] of current user
  late UserData cu;

  /// Sets the current user
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
    double height = 48;

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
          stream: repository.getStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return SmthWrong();
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            UserData u = UserData.fromSnapshot(snapshot.data!.docs[0]);

            List DocList = snapshot.data!.docs;

            // Appends listfriends with UserData of current user's friends
            listfriends.clear();
            for (String userid in friendData) {
              for (DocumentSnapshot doc in DocList) {
                if (doc["userid"] == userid) {
                  u = UserData.fromSnapshot(doc);
                  listfriends.add(u);
                }
              }
            }

            // Adds a card for each of current user's friends
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
                            color: Colors.black.withAlpha(100),
                            blurRadius: 2.0),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  u.userid.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FriendProfilePage(u: u)),
                                    );
                                  },
                                  child: const Text('Visit'),
                                  style: ElevatedButton.styleFrom(
                                      primary: Color(0xFF31A462),
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: Ink.image(
                                  image: Image.network(u.image).image,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 128,
                                ),
                              ),
                            )
                          ]))));
            }

            ///Search Icon and the logic behind search function
            IconButton userSearchIcon = IconButton(
                onPressed: () {
                  //Flag to determine if searched userid exist
                  bool found = false;

                  //Flag to determine if searched userid is already in friendlist
                  bool alrFriend = false;

                  for (DocumentSnapshot doc in DocList) {
                    if (doc["userid"] == _filter.text) {
                      //UserData of searched user
                      UserData userFound = UserData.fromSnapshot(doc);

                      if (!cu.friends.contains(userFound.userid) &&
                          cu.userid != userFound.userid) {
                        //searched userid is neither the user's nor
                        //their friends' userid
                        found = true;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  FriendProfilePage(u: userFound)),
                        );
                        return;
                      } else if (cu.friends.contains(userFound.userid)) {
                        //searched userid is that of user's friend
                        alrFriend = true;
                      }
                    }
                  }
                  if (found == false) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: alrFriend
                                ? Text(
                                    '${_filter.text} is already your friend! ')
                                : Text('${_filter.text} does not exist :('),
                          );
                        });
                  } else {
                    print("friend found!!");
                  }
                },
                icon: Icon(Icons.search, color: Colors.blue));

            /// Area where most of the page elements are built
            return Scaffold(
              body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxScrolled) {
                    return <Widget>[createSilverAppBar(userSearchIcon)];
                  },
                  body: Container(
                    color: Colors.white,
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
                  )),
            );
          }),
    );
  }

  SliverAppBar createSilverAppBar(Widget searchIcon) {
    return SliverAppBar(
      backgroundColor: Color(0xFF31A462),
      expandedHeight: 420,
      collapsedHeight: 80,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(top: 15, bottom: 15),
          centerTitle: true,
          title:
              //isSearchClicked ?
              Container(
            padding: EdgeInsets.only(bottom: 2),
            constraints: BoxConstraints(minHeight: 40, maxHeight: 40),
            width: 220,
            child: CupertinoTextField(
              controller: _filter,
              keyboardType: TextInputType.text,
              placeholder: "Search to new friends",
              placeholderStyle: const TextStyle(
                color: Color(0xffC4C6CC),
                fontSize: 14.0,
                fontFamily: 'Brutal',
              ),
              prefix: searchIcon,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
            ),
          ),
          background: Image.asset(
            'assets/images/friends-list.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          )),
    );
  }
}
