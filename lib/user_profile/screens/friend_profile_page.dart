import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/utils/friend_action_widget.dart';
import 'package:my_app/user_profile/utils/other_profile_widget.dart';
import 'package:my_app/user_profile/utils/strangers_action_widget.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import '../utils/appbar_widget.dart';
import 'edit_profile_page.dart';
import '../utils/friends_display_widget.dart';
import 'package:my_app/user_profile/screens/friend_page.dart';

class FriendProfilePage extends StatefulWidget {
  final UserData u;
  FriendProfilePage({Key? key, required this.u}) : super(key: key);

  @override
  _FriendProfilePageState createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  late UserData u;
  late bool isFriends;

  @override
  void initState() {
    this.u = widget.u;
    if (u.friends.contains(FirebaseAuth.instance.currentUser?.email)) {
      isFriends = true;
    } else {
      isFriends = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFriends == false) {
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
                  OtherProfileWidget(
                    imagePath: u.image,
                  ),
                  const SizedBox(height: 24),
                  buildName(u),
                  const SizedBox(height: 24),
                  FriendsDisplayWidget(u.friends, u.points),
                  const SizedBox(height: 24),
                  StrangersActionWidget(u),
                  const SizedBox(height: 48),
                  buildAbout(u),
                ],
              ),
            ),
          ));
    } else {
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
                  OtherProfileWidget(
                    imagePath: u.image,
                  ),
                  const SizedBox(height: 24),
                  buildName(u),
                  const SizedBox(height: 24),
                  FriendsDisplayWidget(u.friends, u.points),
                  const SizedBox(height: 24),
                  FriendsActionWidget(),
                  const SizedBox(height: 48),
                  buildAbout(u),
                ],
              ),
            ),
          ));
    }
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
            const SizedBox(height: 16),
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
    image: AssetImage('background.png'),
    fit: BoxFit.fitHeight,
  ),
);
