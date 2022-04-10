import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/start/screens/register_success.dart';
import 'package:my_app/start/screens/login_page.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import '../../widgets/bouncing_button.dart';
import '../utils/fire_auth.dart';
import '../utils/validator.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TapGestureRecognizer _textGestureRecognizer;

  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  final CollectionReference userdb = UserDbManager().collection;

  bool _isProcessing = false;
  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    TextFormField _nameField = TextFormField(
      controller: _nameTextController,
      focusNode: _focusName,
      validator: (value) => Validator.validateName(
        name: value,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        icon: Icon(Icons.person_outline),
        labelText: "NAME",
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );

    _textGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
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
        contentPadding: EdgeInsets.fromLTRB(20, 10.0, 20, 10.0),
      ),
    );

    TextFormField _emailField = TextFormField(
      controller: _emailTextController,
      focusNode: _focusEmail,
      validator: (value) => Validator.validateEmail(
        email: value,
      ),
      decoration: InputDecoration(
        label: Text(
          "EMAIL",
        ),
        errorBorder: _errorBorder,
        icon: Icon(
          Icons.email_outlined,
          color: Colors.grey,
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          _focusName.unfocus();
          _focusEmail.unfocus();
          _focusPassword.unfocus();
        },
        child: Container(
          decoration: _background,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.fromLTRB(
                  40, MediaQuery.of(context).size.height * 0.35, 40, 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello there!', style: _titleStyle),
                    SizedBox(height: 20),
                    const Text(
                        'You\'re one step away from a world of games, friends, and no fuss!',
                        style: _subheadingStyle),
                    SizedBox(height: 50),
                    Form(
                      key: _registerFormKey,
                      child: Wrap(
                        runSpacing: 30,
                        children: <Widget>[
                          _FormFieldContainer(_nameField),
                          _FormFieldContainer(_emailField),
                          _FormFieldContainer(_pwField),
                          _isProcessing
                              ? LinearProgressIndicator()
                              : BouncingButton(
                                  bgColor: Color(0xffE3663E),
                                  borderColor: Color(0xffE3663E),
                                  buttonText: 'REGISTER',
                                  textColor: Color(0xffffffff),
                                  onClick: () async {
                                    setState(() {
                                      _isProcessing = true;
                                    });

                                    if (_registerFormKey.currentState!
                                        .validate()) {
                                      User? user = await FireAuth
                                          .registerUsingEmailPassword(
                                        name: _nameTextController.text,
                                        email: _emailTextController.text,
                                        password: _passwordTextController.text,
                                      );

                                      List<String> pictures = [
                                        "assets/images/1573252249390.jpeg",
                                        "assets/images/celerystick.jpg"
                                      ];

                                      UserData newuser = UserData(
                                          _emailTextController.text,
                                          _nameTextController.text,
                                          0,
                                          0,
                                          List<dynamic>.empty(),
                                          List<dynamic>.empty(),
                                          "",
                                          "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg");

                                      await userdb
                                          .doc(_emailTextController.text)
                                          .set(newuser
                                              .toJson()); //adds new user and sets custom ID

                                      setState(() {
                                        _isProcessing = false;
                                      });

                                      if (user != null) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterSuccess(
                                              user: user,
                                            ),
                                            //ProfilePage(widget.user),
                                          ),
                                          ModalRoute.withName('/'),
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        _isProcessing = false;
                                        print('please retry');
                                      });
                                    }
                                  },
                                )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: RichText(
                        //textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Already have an account? ',
                              style: _paraStyle,
                            ),
                            TextSpan(
                                text: ' Log In',
                                style: _paraStyleBold,
                                recognizer: _textGestureRecognizer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// UI to keep the main code short

Container _FormFieldContainer(Widget containerChild) {
  return Container(
    child: containerChild,
    height: 50,
    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
    image: AssetImage('assets/images/register-background.png'),
    fit: BoxFit.fitHeight,
  ),
);

//Text Styles
const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _paraStyleBold = TextStyle(
  color: Color(0xff09358F),
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

const TextStyle _paraStyle = TextStyle(color: Color(0xff09358F), fontSize: 15);
const TextStyle _subheadingStyle =
    TextStyle(color: Color(0xff09358F), fontSize: 16);

var _errorBorder = UnderlineInputBorder(
  borderRadius: BorderRadius.circular(6.0),
  borderSide: BorderSide(
    color: Colors.red,
  ),
);
