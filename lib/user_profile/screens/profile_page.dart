import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/login_page.dart';
import 'package:my_app/user_profile/screens/view_past_events_page.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'edit_profile_page.dart';
import '../utils/friends_widget.dart';
import 'package:my_app/user_profile/screens/view_current_events_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSigningOut = false;

  late User _currentUser;

  final UserDbManager repository = UserDbManager();

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  logout() async {
    setState(() {
      _isSigningOut = true;
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      _isSigningOut = false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
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
          if (doc['userid'] == FirebaseAuth.instance.currentUser?.email) {
            u = UserData.fromSnapshot(doc);
          }
        }

        //if (u.reports >= 5) {
        //  showDialog(
        //      context: context,
        //      builder: (BuildContext context) => _buildWarningDialog(context));
        //  repository.collection.doc(u.userid).update({"reports": 0});
        //}

        return Builder(
          builder: (context) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              actions: <Widget>[
                _isSigningOut
                    ? CircularProgressIndicator()
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: logout,
                        icon: Icon(
                          Icons.logout,
                        ),
                        label: Text(
                          'LOGOUT',
                        ),
                      ),
              ],
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Color(0xFF60d5df),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(0.0)),
              ),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  const Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                  ProfileWidget(
                    imagePath: u.image,
                  ),
                  const SizedBox(height: 24),
                  buildName(u),

                  const SizedBox(height: 24),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(40.0),
                            bottomLeft: Radius.circular(0.0)),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            color: Colors.grey,
                            offset: const Offset(0, 1),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          buildAbout(u),
                          const SizedBox(height: 10),
                          FriendsWidget(u.friends, u.friendrequests, u.points),
                          const SizedBox(height: 100),
                        ],
                      ))

                  // BouncingButton(
                  //     bgColor: Color.fromARGB(255, 65, 37, 28),
                  //     borderColor: const Color(0xffE3663E),
                  //     buttonText: "View Past Events",
                  //     textColor: const Color(0xffffffff),
                  //     //Currently leads to current event page
                  //     onClick: () {
                  //       // temporary tag
                  //       if (u.reports >= 5) {
                  //         showDialog(
                  //             context: context,
                  //             builder: (BuildContext context) =>
                  //                 _buildWarningDialog(context));
                  //         repository.collection
                  //             .doc(u.userid)
                  //             .update({"reports": 0});
                  //       }
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(
                  //             //change to test pages
                  //             builder: (context) => ViewEventPage()),
                  //       );
                  //     }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildAbout(UserData user) => Container(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 120,
            child: Text(
              user.about,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            ),
          ),
          Positioned(
              left: 30,
              top: 12,
              child: Container(
                padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                color: Colors.white,
                child: Text(
                  'Your Bio',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              )),
        ],
      ));

  Widget buildName(UserData user) => Column(
        children: [
          Text(
            user.username,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.userid.toString(),
            style: TextStyle(color: Colors.black, fontSize: 16),
          )
        ],
      );
}

Widget _buildWarningDialog(BuildContext context) {
  return AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
            "Hold it right there bud! It seems like you have been reported many times over the last few day. You need to be better"),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Yes sir, I will do better :('),
      ),
    ],
  );
}
