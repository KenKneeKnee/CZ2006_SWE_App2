import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/login_page.dart';
import 'package:my_app/start/utils/fire_auth.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import '../utils/appbar_widget.dart';
import 'edit_profile_page.dart';
import '../utils/friends_widget.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  late User _currentUser;

  final UserDbManager repository = UserDbManager();

  @override
  void initState() {
    _currentUser = widget.user;
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
                    ProfileWidget(
                      imagePath:
                          "https://media.istockphoto.com/photos/white-gibbon-monkeyland-south-africa-picture-id171573599?k=20&m=171573599&s=612x612&w=0&h=FryqWJlMtlWNYM4quWNxU7rJMYQ3CtlgJ_6tU8-R9BU=",
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

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'NAME: ${_currentUser.displayName}',
//               style: Theme.of(context).textTheme.bodyText1,
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'EMAIL: ${_currentUser.email}',
//               style: Theme.of(context).textTheme.bodyText1,
//             ),
//             SizedBox(height: 16.0),
//             _currentUser.emailVerified
//                 ? Text(
//                     'Email verified',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyText1!
//                         .copyWith(color: Colors.green),
//                   )
//                 : Text(
//                     'Email not verified',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyText1!
//                         .copyWith(color: Colors.red),
//                   ),
//             SizedBox(height: 16.0),
//             _isSendingVerification
//                 ? CircularProgressIndicator()
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           setState(() {
//                             _isSendingVerification = true;
//                           });
//                           await _currentUser.sendEmailVerification();
//                           setState(() {
//                             _isSendingVerification = false;
//                           });
//                         },
//                         child: Text('Verify email'),
//                       ),
//                       SizedBox(width: 8.0),
//                       IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: () async {
//                           User? user = await FireAuth.refreshUser(_currentUser);

//                           if (user != null) {
//                             setState(() {
//                               _currentUser = user;
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//             SizedBox(height: 16.0),
//             _isSigningOut
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: () async {
//                       setState(() {
//                         _isSigningOut = true;
//                       });
//                       await FirebaseAuth.instance.signOut();
//                       setState(() {
//                         _isSigningOut = false;
//                       });
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                           builder: (context) => LoginPage(),
//                         ),
//                       );
//                     },
//                     child: Text('Sign out'),
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
