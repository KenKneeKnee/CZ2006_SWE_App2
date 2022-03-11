import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/utils/friend_action_widget.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import '../utils/appbar_widget.dart';
import 'edit_profile_page.dart';
import '../utils/friends_display_widget.dart';
import 'package:my_app/user_profile/utils/other_profile_widget.dart';
import 'package:my_app/user_profile/screens/friend_page.dart' as f;

class OtherProfilePage extends StatefulWidget {
  final UserData u;
  OtherProfilePage({Key? key, required this.u}) : super(key: key);
  @override
  _OtherProfilePageState createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  final UserDbManager repository = UserDbManager();

  @override
  void initState() {
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
          if (doc['userid'] == FirebaseAuth.instance.currentUser?.email) {
            u = UserData.fromSnapshot(doc);
          }
        }

        return Container(
            decoration: _background,
            child: Builder(
              builder: (context) => Scaffold(
                backgroundColor: Colors.transparent,
                appBar: buildAppBar(context),
                body: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    const OtherProfileWidget(
                      imagePath:
                          "https://pbs.twimg.com/profile_images/1453101247217733636/qawViunA_400x400.jpg",
                    ),
                    const SizedBox(height: 24),
                    buildName(u),
                    const SizedBox(height: 24),
                    FriendsDisplayWidget(u.friends, u.points),
                    const SizedBox(height: 24),
                    FriendsActionWidget(u),
                    const SizedBox(height: 48),
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
            Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
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
