//----------------------------------------------------
// UI widgets for the alert dialog of event creation
import 'package:flutter/material.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/hovering_image.dart';

/// (custom) MapMarker consists of location marker image with dynamic size
/// Function holding function to trigger corrsponding details is in the Marker class (flutter)
class MapMarker extends StatelessWidget {
  const MapMarker({Key? key, required this.selected, required this.imagePath})
      : super(key: key);

  final bool selected;
  final String imagePath;
  static const MARKERSIZE_ENLARGED =
      80.0; //TODO: need to make this a "global" constant
  // currenlty need to edit in facil_map too
  static const MARKERSIZE_SHRINKED = 50.0;

  @override
  Widget build(BuildContext context) {
    final size = selected ? MARKERSIZE_ENLARGED : MARKERSIZE_SHRINKED;

    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: const Duration(milliseconds: 400),
        child: Image.asset(imagePath),
      ),
    );
  }
}

///Header holding location details about a sports facility (Place name, Facility Type, Address)
class MapMarkerInfoHeader extends StatelessWidget {
  late String Title; //place name eg. Sun Park
  late String
      Subtitle; //facility type eg. Gym (will be used for place name if place name not available)
  late String Para; //address eg. Street 21 S283710
  late String hoveringIcon;

  MapMarkerInfoHeader(
      String title, String subtitle, String para, String Imgpath,
      {Key? key})
      : super(key: key) {
    if (title == "") {
      title = subtitle;
      subtitle = "";
    }
    this.Title = title;
    this.Subtitle = subtitle;
    this.Para = para;
    this.hoveringIcon = Imgpath;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 10, 0, 10),
      height: MediaQuery.of(context).size.height * 0.3,
      //width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    Title,
                    style: _TitleStyle,
                  ),
                  subtitle: Text(
                    Subtitle,
                    style: _subtitleStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    Para,
                    style: _paraStyle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: AnimatedHoverImage(
                imagePath: hoveringIcon,
                durationMilliseconds: 800,
              )),
        ],
      ),
    );
  }
}

/// Text Styles
final _TitleStyle = TextStyle(
  color: Colors.grey[900],
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

final _subtitleStyle = TextStyle(
    color: Colors.grey[900],
    fontSize: 18,
    //fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic);

final _paraStyle = TextStyle(
  color: Colors.grey[900],
  fontSize: 14,
  //fontWeight: FontWeight.bold,
);

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
