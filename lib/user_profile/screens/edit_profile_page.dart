import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/utils/profile_widget.dart';
import 'package:my_app/user_profile/utils/textfield_widget.dart';
import 'package:my_app/widgets/bouncing_button.dart';

import '../utils/appbar_widget.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserDbManager repository = UserDbManager();
  late String key;

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
              key = doc.id;
              u = UserData.fromSnapshot(doc);
            }
          }

          return Container(
            child: Builder(
              builder: (context) => Scaffold(
                appBar: buildAppBar(context),
                body: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  physics: BouncingScrollPhysics(),
                  children: [
                    ProfileWidget(
                      imagePath:
                          "https://media.istockphoto.com/photos/white-gibbon-monkeyland-south-africa-picture-id171573599?k=20&m=171573599&s=612x612&w=0&h=FryqWJlMtlWNYM4quWNxU7rJMYQ3CtlgJ_6tU8-R9BU=",
                      isEdit: true,
                      onClicked: () async {},
                    ),
                    const SizedBox(height: 24),
                    TextFieldWidget(
                      label: 'username',
                      text: u.username,
                      onChanged: (name) {
                        setState(() {
                          u.username = name;
                          print(
                              'set state was called ${u.username} should be changed to ${name}');
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFieldWidget(
                      label: 'About',
                      text: u.about,
                      maxLines: 5,
                      onChanged: (about) {
                        setState(() {
                          u.about = about;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    BouncingButton(
                        bgColor: Color(0xffE96B46),
                        borderColor: Color(0xffE96B46),
                        buttonText: "Confirm",
                        textColor: Color(0xffffffff),
                        onClick: () async {
                          print('hiiii ${u.username}');
                          await repository.updateUser(u, key);
                          Navigator.pop(context, true);
                        })
                  ],
                ),
              ),
            ),
          );
        });
  }
}
