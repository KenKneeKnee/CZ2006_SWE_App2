//----------------------------------------------------
// UI widgets for the alert dialog of event creation
import 'package:flutter/material.dart';
import 'package:my_app/widgets/bouncing_button.dart';

class OkButton extends StatelessWidget {
  const OkButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "Got it!",
      onClick: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Container(
          height: 350,
          decoration: _successBackground,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                const Text(
                  'Event Created!',
                  style: _titleStyle,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Now all that\'s left is getting fellow SportBuddies to join your event!',
                  style: _paraStyleBold,
                ),
              ],
            ),
          ),
        ),
        actions: [
          const OkButton(),
        ]);
  }
}

class FailDialog extends StatelessWidget {
  const FailDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Container(
          height: 240,
          decoration: _failBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              const Text(
                'Error!',
                style: _titleStyle,
              ),
              const SizedBox(height: 15),
              const Text(
                'Something went wrong. I\'m sorry :(',
                style: _paraStyleBold,
              ),
            ],
          ),
        ),
        actions: [
          const OkButton(),
        ]);
  }
}

const BoxDecoration _successBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('create-event-success.png'),
    fit: BoxFit.fitWidth,
    alignment: Alignment.topCenter,
  ),
);
const BoxDecoration _failBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('create-event-fail.png'),
    fit: BoxFit.fitWidth,
    alignment: Alignment.topCenter,
  ),
);

//Text Styles
const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _paraStyleBold = TextStyle(
  color: Colors.black87,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
