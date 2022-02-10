import 'package:flutter/material.dart';

import 'package:my_app/widgets/bouncing_button.dart';

import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: [
            BackgroundImage(imagePath: 'background.png'),
            BackgroundImage(imagePath: 'welcome-player1.png'),
            BackgroundImage(imagePath: 'welcome-player2.png'),
            BackgroundImage(imagePath: 'welcome-player3.png'),
            BackgroundImage(imagePath: 'welcome-player4.png'),
            Positioned(
              child: Image.asset(
                'sportsbuds-logo.png',
                height: 230,
              ),
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0, //left, right=0 makes it centered
            ),
            Column(
              children: [
                const SizedBox(height: 500),
                BouncingButton(
                  bgColor: Color(0xffE3663E),
                  borderColor: Color(0xffFFFFFF),
                  buttonText: 'Create Account',
                  textColor: Color(0xffFFFFFF),
                  routeTo:
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                ),
                const SizedBox(height: 18),
                BouncingButton(
                  bgColor: Color(0xffFFFFFF),
                  borderColor: Color(0xffE3663E),
                  buttonText: 'Login',
                  textColor: Color(0xffE3663E),
                  routeTo: MaterialPageRoute(builder: (context) => LoginPage()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
