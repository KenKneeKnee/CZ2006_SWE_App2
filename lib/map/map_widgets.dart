//----------------------------------------------------
// UI widgets for the alert dialog of event creation
import 'package:flutter/material.dart';
import 'package:my_app/map/facil_map.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FacilitiesMap()), //return to map
        );
      },
    );
  }
}

class SuccessDialog extends StatelessWidget {
  SuccessDialog(
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Text(
                    title,
                    style: dialogTitleStyle,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    paragraph,
                    style: dialogParaStyleBold,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          const OkButton(),
        ]);
  }
}

class FailDialog extends StatelessWidget {
  FailDialog(
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
          height: 240,
          decoration: bgDeco,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Text(
                title,
                style: dialogTitleStyle,
              ),
              const SizedBox(height: 15),
              Text(
                paragraph,
                style: dialogParaStyleBold,
              ),
            ],
          ),
        ),
        actions: [
          const OkButton(),
        ]);
  }
}

class OvernightDialog extends StatelessWidget {
  OvernightDialog(
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black87,
                        offset: Offset(7.5, 7.5),
                        blurRadius: 15)]),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    paragraph,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black87,
                            offset: Offset(2.5, 2.5),
                            blurRadius: 15)]),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          const OkButton(),
        ]);
  }
}

class DialogBoxDecoration {
  static const BoxDecoration createEventSuccessBg = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('create-event-success.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    ),
  );

  static const BoxDecoration createEventFailBg = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('create-event-fail.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    ),
  );

  static BoxDecoration joinEventBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('join-event.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );
  static BoxDecoration leaveEventBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('leave-event.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );

  static BoxDecoration fullEventBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('full-event.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );

  static BoxDecoration notLoggedInBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('not-logged-in.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );
  static BoxDecoration clashingSchedBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('clashing-schedules.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );

  static BoxDecoration friendAddedBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('friend-added.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );
  static BoxDecoration userReportedBg = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: const DecorationImage(
      image: AssetImage('user-reported.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  );

  static const BoxDecoration overnightEventBg = BoxDecoration(
    image: DecorationImage(
      image: AssetImage('overnight-event.png'),
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    ),
  );
}

//Text Styles
const TextStyle dialogTitleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle dialogParaStyleBold = TextStyle(
  color: Colors.black87,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
