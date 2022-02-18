import 'package:flutter/material.dart';
import 'package:my_app/widgets/bouncing_button.dart';

BoxDecoration baseContainer = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      spreadRadius: 2,
      color: Colors.grey,
      offset: const Offset(-1, 4),
      blurRadius: 3,
    )
  ],
);

Container calendarIcon = Container(
  color: Colors.transparent,
  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
  height: 50,
  child: Image.asset('icon-calendar.png'),
);

Icon capIcon = const Icon(Icons.person);
Icon timeIcon = const Icon(Icons.timer);

Container TextWithIcon(String text, Icon icon) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    decoration: const BoxDecoration(
        color: Color(0xffEBEBEB),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Row(
      children: [
        icon,
        Flexible(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              text,
              style: _paraStyleBold,
            ),
          ),
        ),
      ],
    ),
  );
}

Expanded TextContainer(String text, BuildContext context) {
  return Expanded(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.all(10),
      // margin: EdgeInsets.fromLTRB(5, 5, 5, 25),
      decoration: BoxDecoration(
          color: Color(0xffEBEBEB),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: paraStyle,
        ),
      ),
    ),
  );
}

class SportEventTextWidget {
  static Padding Title(String text) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 3),
        child: Text(text, style: titleStyle));
  }

  static Text Subtitle(String text) {
    return Text(
      text,
      style: subtitleStyle,
      textAlign: TextAlign.center,
    );
  }
}

/// Text Styles
final titleStyle = TextStyle(
  color: Colors.grey[900],
  fontSize: 36,
  fontWeight: FontWeight.bold,
);

final subtitleStyle = TextStyle(
    color: Colors.grey[900],
    fontSize: 14,
    //fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic);

final paraStyle = TextStyle(
  color: Colors.grey[900],
  fontSize: 14,

  //fontWeight: FontWeight.bold,
);
final _paraStyleBold = TextStyle(
  color: Colors.grey[900],
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

class ReturnToMapButton extends StatelessWidget {
  const ReturnToMapButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "Return to Map",
      onClick: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

class JoinedEventDialog extends StatelessWidget {
  JoinedEventDialog(
      {Key? key,
      required this.bgDeco,
      required this.paragraph,
      required this.title})
      : super(key: key);
  String paragraph;
  String title;
  BoxDecoration bgDeco;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 350,
        decoration: bgDeco,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Text(
                  title,
                  style: _dialogTitleStyle,
                ),
                const SizedBox(height: 15),
                Text(
                  paragraph,
                  style: _dialogParaStyleBold,
                ),
                //ReturnToMapButton(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        const ReturnToMapButton(),
      ],
    );
  }
}

class LeftEventDialog extends StatelessWidget {
  LeftEventDialog(
      {Key? key,
      required this.bgDeco,
      required this.paragraph,
      required this.title})
      : super(key: key);
  String paragraph;
  String title;
  BoxDecoration bgDeco;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 350,
        decoration: bgDeco,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Text(
                  title,
                  style: _dialogTitleStyle,
                ),
                const SizedBox(height: 15),
                Text(
                  paragraph,
                  style: _dialogParaStyleBold,
                ),
                //ReturnToMapButton(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        const ReturnToMapButton(),
      ],
    );
  }
}

//Text Styles
const TextStyle _dialogTitleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _dialogParaStyleBold = TextStyle(
  color: Colors.black87,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
