import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_app/user_profile/screens/profile_page.dart';
import 'package:my_app/start/screens/register_page.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import '../../user_profile/screens/profile_page.dart';
import 'package:my_app/user_profile/screens/others_profile_page.dart';
import '../utils/fire_auth.dart';
import '../utils/validator.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TapGestureRecognizer _textGestureRecognizer;
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //change back to pushReplacement after testing
      Navigator.of(context).push(
        MaterialPageRoute(
          //change to test pages
          builder: (context) => OtherProfilePage(
            user: user,
          ),
        ),
      );
    }
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    _textGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RegisterPage(),
          ),
        );
      };

    TextFormField _pwField = TextFormField(
      controller: _passwordTextController,
      focusNode: _focusPassword,
      obscureText: true,
      validator: (value) => Validator.validatePassword(
        password: value,
      ),
      decoration: InputDecoration(
        icon: Icon(Icons.lock_outline, color: Colors.grey),
        labelText: "PASSWORD",
        errorBorder: _errorBorder,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );

    TextFormField _emailField = TextFormField(
      controller: _emailTextController,
      focusNode: _focusEmail,
      validator: (value) => Validator.validateEmail(
        email: value,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        label: const Text(
          "EMAIL",
        ),
        errorBorder: _errorBorder,
        icon: const Icon(
          Icons.email_outlined,
          color: Colors.grey,
        ),
      ),
    );

    return Container(
      decoration: _background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    40, MediaQuery.of(context).size.height * 0.38, 40, 100),
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  runSpacing: 30,
                  //crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Welcome back!',
                        style: _titleStyle, textAlign: TextAlign.left),
                    const Text(
                        'Ready for more fun and games? Login to your account now',
                        style: _subheadingStyle,
                        textAlign: TextAlign.left),
                    Form(
                      key: _formKey,
                      child: Wrap(
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.center,
                        runSpacing: 40,
                        children: <Widget>[
                          _FormFieldContainer(_emailField),
                          //const SizedBox(height: 28.0),
                          _FormFieldContainer(_pwField),
                          //const SizedBox(height: 24.0),
                          _isProcessing
                              ? const CircularProgressIndicator()
                              : BouncingButton(
                                  bgColor: const Color(0xffE3663E),
                                  borderColor: const Color(0xffE3663E),
                                  buttonText: 'LOG IN',
                                  textColor: Color(0xffffffff),
                                  onClick: () async {
                                    _focusEmail.unfocus();
                                    _focusPassword.unfocus();

                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      User? user = await FireAuth
                                          .signInUsingEmailPassword(
                                              email: _emailTextController.text,
                                              password:
                                                  _passwordTextController.text);

                                      setState(() {
                                        _isProcessing = false;
                                      });

                                      if (user != null) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            //Can be changed for
                                            builder: (context) =>
                                                ProfilePage(user: user),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                        ],
                      ),
                    ),
                    Center(
                      child: RichText(
                        //textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Don\'t have an account? ',
                              style: _paraStyle,
                            ),
                            TextSpan(
                                text: ' Sign Up',
                                style: _paraStyleBold,
                                recognizer: _textGestureRecognizer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child:
                  CircularProgressIndicator(), //if not logged in successfully
            );
          },
        ),
      ),
    );
  }
}

//helper functions / UI to keep the main code short

Container _FormFieldContainer(Widget containerChild) {
  return Container(
    child: containerChild,
    height: 50,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 0,
          offset: Offset(-4, 6), // changes position of shadow
        )
      ],
    ),
  );
}

const BoxDecoration _background = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('login-background.png'),
    fit: BoxFit.fitHeight,
  ),
);

//Text Styles
const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _paraStyleBold = TextStyle(
  color: Color(0xffffffff),
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

const TextStyle _paraStyle = TextStyle(color: Color(0xffffffff), fontSize: 15);
const TextStyle _subheadingStyle =
    TextStyle(color: Color(0xff09358F), fontSize: 16);

var _errorBorder = UnderlineInputBorder(
  borderRadius: BorderRadius.circular(6.0),
  borderSide: const BorderSide(
    color: Colors.red,
  ),
);
