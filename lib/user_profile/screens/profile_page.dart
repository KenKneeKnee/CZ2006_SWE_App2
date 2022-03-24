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

        return Container(
            decoration: _background,
            child: Builder(
              builder: (context) => Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Profile'),
                  leading: _isSigningOut
                      ? CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.logout),
                          color: Colors.black,
                          onPressed: logout),
                  foregroundColor: Colors.black,
                  backgroundColor: Color(0xffE3663E),
                  elevation: 0,
                  actions: [],
                ),
                body: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    ProfileWidget(
                      imagePath: u.image,
                      onClicked: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    buildName(u),
                    const SizedBox(height: 24),
                    FriendsWidget(u.friends, u.friendrequests, u.points),
                    const SizedBox(height: 48),
                    BouncingButton(
                        bgColor: const Color(0xffE3663E),
                        borderColor: const Color(0xffE3663E),
                        buttonText: "View Events",
                        textColor: const Color(0xffffffff),
                        //Currently leads to current event page
                        onClick: () {
                          // temporary tag
                          if (u.reports >= 5) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildWarningDialog(context));
                            repository.collection
                                .doc(u.userid)
                                .update({"reports": 0});
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                //change to test pages
                                builder: (context) => ViewEventPage()),
                          );
                        }),
                    const SizedBox(height: 24),
                    buildAbout(u),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget buildAbout(UserData user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ignore: prefer_const_constructors
            Center(
              child: const Text('About',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),

            const SizedBox(height: 16),
            Center(
                child: Text(
              user.about,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  background: Paint()
                    ..strokeWidth = 30.0
                    ..color = Colors.white
                    ..style = PaintingStyle.stroke
                    ..strokeJoin = StrokeJoin.round),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      );

  Widget buildName(UserData user) => Column(
        children: [
          Text(
            user.username,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.userid.toString(),
            style: TextStyle(color: Colors.grey),
          )
        ],
      );
}

const BoxDecoration _background = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/background.png'),
    fit: BoxFit.fitHeight,
  ),
);

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
