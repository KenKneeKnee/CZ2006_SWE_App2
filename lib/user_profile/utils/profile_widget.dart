import 'package:flutter/material.dart';
import 'package:my_app/user_profile/screens/edit_profile_page.dart';

///Widget for building current user's profile picture
///
///Leads to edit_profile_page when pressed
class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              child: buildEditIcon(color),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = Image.network(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image.image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            isEdit ? Icons.add_a_photo : Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
