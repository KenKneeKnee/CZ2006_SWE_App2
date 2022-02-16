import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/themes.dart';

AppBar buildAppBar(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final icon = CupertinoIcons.moon_stars;

  return AppBar(
    title: const Text('Profile'),
    leading: BackButton(
        color: Colors.black, onPressed: () => Navigator.of(context).pop()),
    foregroundColor: Colors.black,
    backgroundColor: Colors.orange,
    elevation: 0,
    actions: [
      ThemeSwitcher(
        builder: (context) => IconButton(
          icon: Icon(icon),
          onPressed: () {
            final theme = isDarkMode ? MyThemes.lightTheme : MyThemes.darkTheme;

            final switcher = ThemeSwitcher.of(context);
            switcher.changeTheme(theme: theme);
          },
        ),
      ),
    ],
  );
}
