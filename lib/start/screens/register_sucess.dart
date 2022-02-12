import 'package:flutter/material.dart';
import './login_page.dart';
import './onboarding.dart';
import '../../user_profile/profile_page.dart';
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
  const RegisterSuccess({Key? key}) : super(key: key);

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
            AnimatedImage(),
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
                        MaterialPageRoute(builder: (context) => Onboarding()),
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
                      MaterialPageRoute(builder: (context) => LoginPage()),
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

class AnimatedImage extends StatefulWidget {
  const AnimatedImage({Key? key}) : super(key: key);

  @override
  _AnimatedImageState createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  late Animation<Offset> _animation = Tween(
    begin: Offset.zero,
    end: Offset(0, 0.05),
  ).animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: _controller));

  late final Animation<double> _animation2 = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );

  //animates the position of a widget relative to its normal position

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
        ),
        Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            SlideTransition(
              child: Image.asset(
                'tick-circle.png',
                fit: BoxFit.contain,
              ),
              position: _animation,
            ),
          ],
        ),
      ],
    );
  }
}
