import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/hovering_image.dart';
import './login_page.dart';
import './onboarding.dart';
import '../../user_profile/screens/profile_page.dart';
import 'package:my_app/widgets/bouncing_button.dart';

TextStyle myTitleStyle() {
  return const TextStyle(
    color: Colors.black,
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'RobotoMono',
  );
}

TextStyle myBodyStyle() {
  return const TextStyle(
    color: Colors.black,
    fontSize: 15.0,
    fontFamily: 'RobotoMono',
  );
}

class RegisterSuccess extends StatefulWidget {
  final User user;

  const RegisterSuccess({required this.user});

  @override
  _RegisterSuccessState createState() => _RegisterSuccessState();
}

class _RegisterSuccessState extends State<RegisterSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage('register-success.png'),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Stack(
          children: [
            _hoveringBackground(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                Text(
                  'Registration Complete!',
                  style: myTitleStyle(),
                ),
                SizedBox(height: 20),
                Text(
                  'You’re almost there! Let us \nteach you the ropes and you’ll be playing in no time',
                  style: myBodyStyle(),
                ),
                SizedBox(height: 50),
                BouncingButton(
                    bgColor: Color(0xffE3663E),
                    borderColor: Color(0xffE3663E),
                    buttonText: 'Teach me',
                    textColor: Color(0xffffffff),
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Onboarding(
                                  user: widget.user,
                                )),
                      );
                    }),
                SizedBox(height: 20),
                BouncingButton(
                  bgColor: Color(0xffffffff),
                  borderColor: Color(0xffffffff),
                  buttonText: 'I already know how',
                  textColor: Color(0xffE3663E),
                  onClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                user: widget.user,
                              )),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _hoveringBackground extends StatelessWidget {
  const _hoveringBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedHoverImage(
          imagePath: 'tick-circle.png',
          durationMilliseconds: 500,
        )
      ],
    );
  }
}
