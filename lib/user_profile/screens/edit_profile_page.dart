import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/user_profile/utils/progress_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/storage_repository.dart';

/// A page for users to edit their profile information
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// TextController where [user.username] is edited
  TextEditingController displayNameController = TextEditingController();

  /// TextController where [user.about] is edited
  TextEditingController bioController = TextEditingController();

  final Storage storage = Storage();
  bool isLoading = false;

  /// Data of the current user
  late UserData user;

  /// Check for validity of new [user.username]
  bool _displayNameValid = true;

  /// Check for validity of new [user.about]
  bool _bioValid = true;

  /// Current [user.image]
  late final image;

  /// New [user.image] that [user] may upload
  late String newPic;

  UserDbManager userdb = UserDbManager();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  /// Sets the current user
  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    user = UserData.fromSnapshot(doc);
    displayNameController.text = user.username;
    bioController.text = user.about;
    image = Image.network(user.image);

    setState(() {
      isLoading = false;
    });
  }

  /// Field where [user] may choose new [user.image]
  Column buildImageField(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
            child: ElevatedButton(
              onPressed: () async {
                // Pick new image
                final newImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                // Upload image to Firebase if a new image is picked
                if (newImage != null) {
                  await storage.uploadFile(newImage.path, user.userid!);
                } else {}
                // Download new image from Firebase and set as user's proifle picture
                newPic = await storage.downloadURL(user.userid!);
                userdb.collection
                    .doc(FirebaseAuth.instance.currentUser?.email)
                    .update({"image": newPic});
                setState(() {});
              },
              child: const Text('Pick New Image'),
              style: ElevatedButton.styleFrom(
                  primary: Color(0xFF31A462),
                  textStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }

  /// Field where [user.about] and [user.username] are edited
  Column buildField(String title, String hint, TextEditingController controller,
      bool check, String warning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                errorText: check ? null : warning,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Update [user]'s details if all details entered are valid
  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 140
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      userdb.collection.doc(FirebaseAuth.instance.currentUser?.email).update({
        "username": displayNameController.text,
        "about": bioController.text
      });
      Navigator.pop(context);
      SnackBar snackbar = const SnackBar(
        content: Text("Profile updated!"),
        backgroundColor: Color(0xffE3663E),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Color _getTextColor(Set<MaterialState> states) => states.any(<MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      }.contains)
          ? Colors.green
          : Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white, onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Color(0xFF049cac),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? circularProgress()
          : Container(
              color: Color(0xFF049cac),
              child: ListView(
                children: <Widget>[
                  Column(children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(40.0),
                            bottomLeft: Radius.circular(0.0)),
                      ),
                      padding: EdgeInsets.all(36.0),
                      child: Column(
                        children: <Widget>[
                          buildImageField("Profile Picture"),
                          buildField(
                              "Username",
                              "Change username",
                              displayNameController,
                              _displayNameValid,
                              "Username is too short"),
                          buildField(
                              "About",
                              "Talk about yourself...",
                              bioController,
                              _bioValid,
                              "Bio is too long. Character Count: ${bioController.text.length} / 140"),
                          const SizedBox(
                            height: 100,
                          ),
                          ElevatedButton.icon(
                              onPressed: updateProfileData,
                              icon: Icon(Icons.edit),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                )),
                                backgroundColor: MaterialStateColor.resolveWith(
                                    _getTextColor),
                              ),
                              label: const Text(
                                "SAVE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ])
                ],
              ),
            ),
    );
  }
}
