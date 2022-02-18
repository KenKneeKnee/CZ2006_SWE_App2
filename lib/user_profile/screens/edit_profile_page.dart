import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/utils/textfield_widget.dart';

import '../utils/appbar_widget.dart';

// class EditProfilePage extends StatefulWidget {
//   @override
//   _EditProfilePageState createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//    UserData  = UserPreferences.myUser;

//   @override
//   Widget build(BuildContext context) => ThemeSwitchingArea(
//         child: Builder(
//           builder: (context) => Scaffold(
//             appBar: buildAppBar(context),
//             body: ListView(
//               padding: EdgeInsets.symmetric(horizontal: 32),
//               physics: BouncingScrollPhysics(),
//               children: [
//                 ProfileWidget(
//                   imagePath: user.imagePath,
//                   isEdit: true,
//                   onClicked: () async {},
//                 ),
//                 const SizedBox(height: 24),
//                 TextFieldWidget(
//                   label: 'username',
//                   text: user.name,
//                   onChanged: (name) {},
//                 ),
//                 const SizedBox(height: 24),
//                 TextFieldWidget(
//                   label: 'About',
//                   text: user.about,
//                   maxLines: 5,
//                   onChanged: (about) {},
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
// }