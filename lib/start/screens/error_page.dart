import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/start/screens/welcome_page.dart';

class SmthWrong extends StatelessWidget {
  const SmthWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: AssetImage('assets/images/smthwrong.png'),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                textStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                backgroundColor: Colors.transparent,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => WelcomePage()));
              },
              icon: Icon(
                Icons.exit_to_app,
              ),
              label: Text(
                'RETURN TO MAIN',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
