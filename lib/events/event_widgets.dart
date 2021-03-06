///Contains widgets designed to be used in view_event, completeEvent Pages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/completeEvent.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/retrievedevent.dart';
import 'package:my_app/homepage.dart';
import 'package:my_app/map/facil_map.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/user_profile/data/user.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';

/// This is a pressable button that allows user to cancel their current action.
/// It will bring the user back to their previous page.
TextButton CancelTextButton(BuildContext context) {
  return TextButton(
    onPressed: () => Navigator.pop(context, 'Cancel'),
    child: const Text('Cancel'),
  );
}

/// This is a pressable button that will be shown when users join an event.
/// It will show a JoinedEventDialog that tells users they have joined an event
/// on pressed.
class GreenButton extends StatelessWidget {
  GreenButton(
      {Key? key,
      required this.curEvent,
      required this.buttonFunction,
      required this.buttontext})
      : super(key: key);
  RetrievedEvent curEvent;
  String buttontext;
  void Function() buttonFunction;

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.green,
      textColor: Colors.white,
      borderColor: Colors.white,
      buttonText: buttontext,
      onClick: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              buttonFunction();
              return JoinedEventDialog(
                bgDeco: DialogBoxDecoration.joinEventBg,
                title: 'Joined Successfully!',
                paragraph: 'Your fellow SportBuds can\'t wait to see you!',
              );
            });
      },
    );
  }
}

/// This is a button that will be shown when users can complete an event.
/// It will direct users to a CompleteEventPage on pressed
/// where users will see their points earned from the event
/// and a list of recommendations.
class CompleteEventButton extends StatelessWidget {
  CompleteEventButton(
      {Key? key,
      required this.curEvent,
      required this.buttonFunction,
      required this.buttontext})
      : super(key: key);
  RetrievedEvent curEvent;
  String buttontext;
  void Function() buttonFunction;
  UserDbManager userdb = UserDbManager();
  late UserData cu;
  getUser() async {
    DocumentSnapshot doc = await userdb.collection
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get();
    cu = UserData.fromSnapshot(doc);
  }

  @override
  Widget build(BuildContext context) {
    void function() {
      buttonFunction(); //deals with database
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/completed-event.png'),
                  //    fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                      ),
                      BouncingButton(
                          bgColor: Color(0xFFEDB129),
                          borderColor: Colors.black,
                          buttonText: "OK!",
                          textColor: Color.fromARGB(255, 247, 244, 244),
                          onClick: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CompleteEventPage(
                                        event_id: curEvent.eventId)));
                            cu.points = cu.points + 20;
                            userdb.collection
                                .doc(cu.userid)
                                .update({"points": cu.points});
                          })
                    ]),
              ),
            ));
          });
    }

    return BouncingButton(
      bgColor: Colors.green,
      textColor: Colors.white,
      borderColor: Colors.white,
      buttonText: buttontext,
      onClick: function,
    );
  }
}

/// This is a pressable button that will be shown when users can leave an event.
/// It will show a LeftEventDialog that tells users they have left an event
/// on pressed.
class LeaveButton extends StatelessWidget {
  LeaveButton({Key? key, required this.curEvent, required this.leaveFunction})
      : super(key: key);
  RetrievedEvent curEvent;
  void Function() leaveFunction;

  @override
  Widget build(BuildContext context) {
    void function() {
      leaveFunction(); //MUST put bracket for the function to be actually executed
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return LeftEventDialog(
              bgDeco: DialogBoxDecoration.leaveEventBg,
              title: 'Left Successfully!',
              paragraph:
                  'Your fellow SportBuds will miss you. Hope to see you soon!',
            );
          });
    }

    return BouncingButton(
      bgColor: Colors.red,
      textColor: Colors.white,
      borderColor: Colors.white,
      buttonText: "Leave Event",
      onClick: function,
    );
  }
}

/// This is a button that will be shown when event capacity is full.
/// It does nothing if pressed.
class FullEventButton extends StatelessWidget {
  FullEventButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "EVENT FULL",
      onClick: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DoNothingDialog(
                bgDeco: DialogBoxDecoration.fullEventBg,
              );
            });
      },
    );
  }
}

/// This is a button that will be shown when there is a timing schedule clash
/// for the user.
/// It does nothing if pressed.
class ClashingSchedButton extends StatelessWidget {
  ClashingSchedButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "TIMING CLASH",
      onClick: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DoNothingDialog(
                bgDeco: DialogBoxDecoration.clashingSchedBg,
              );
            });
      },
    );
  }
}

/// This is a button that will be shown when user is not logged in.
/// It does nothing if pressed.
class NotLoggedInButton extends StatelessWidget {
  NotLoggedInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "LOG IN",
      onClick: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return DoNothingDialog(
                bgDeco: DialogBoxDecoration.notLoggedInBg,
              );
            });
      },
    );
  }
}

///A UI class which contains BoxDecoration styles which can be used in Containers.
///These are specifically used in Dialog Pop-ups.
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

///Containers used in building the UI for the view_event Page.
Container calendarIcon = Container(
  color: Colors.transparent,
  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
  height: 50,
  child: Image.asset('assets/images/icon-calendar.png'),
);

Icon capIcon = const Icon(Icons.person);
Icon timeIcon = const Icon(Icons.timer);

/// Containers used in building the UI for the view_event Page.
Container TextWithIcon(String text, Icon icon) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
/// Containers used in building the UI for the view_event Page.
Expanded TextContainer(String text, BuildContext context) {
  return Expanded(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 35),
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

///UI class used for text styles used in SportEvents
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
  ReturnToMapButton({Key? key, required this.dialogContext}) : super(key: key);
  BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "Return to Map",
      onClick: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context); // closes infosheet

        // Navigator.of(context).popUntil((route) => route.isFirst);
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (BuildContext context) => Homepage()));
      },
    );
  }
}

/// Button to direct user to login page
class GoToLoginButton extends StatelessWidget {
  const GoToLoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      bgColor: Colors.white,
      textColor: const Color(0xffD56F2F),
      borderColor: const Color(0xffD56F2F),
      buttonText: "Log In",
      onClick: () {
        //TODO: Link to log in
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

/// Dialog used for JoinedEvent
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        ReturnToMapButton(dialogContext: context),
      ],
    );
  }
}

/// Dialog used for LeftEvent
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        ReturnToMapButton(dialogContext: context),
      ],
    );
  }
}

/// Dialog used for FullEvent and ClashingSchedule
/// User can't do anything about it
/// also i accidentally made the BG with text so there's no need for the title and paragraph inputs - clary
class DoNothingDialog extends StatelessWidget {
  DoNothingDialog({
    Key? key,
    required this.bgDeco,
  }) : super(key: key);
  // String paragraph;
  // String title;
  BoxDecoration bgDeco;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        height: 350,
        decoration: bgDeco,
      ),
      actions: [
        ReturnToMapButton(dialogContext: context),
      ],
    );
  }
}

/// Dialog used for NotLoggedIn
class NotLoggedInDialog extends StatelessWidget {
  NotLoggedInDialog(
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
              ],
            ),
          ),
        ),
      ),
      actions: [
        const GoToLoginButton(),
      ],
    );
  }
}

///Text Styles
const TextStyle _dialogTitleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _dialogParaStyleBold = TextStyle(
  color: Colors.black87,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);
