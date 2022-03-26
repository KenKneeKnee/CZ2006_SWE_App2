import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/loading_lotties/loading_lotties.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/time_picker.dart';

class CreateEventForm extends StatefulWidget {
  CreateEventForm({
    Key? key,
    required this.date,
    required this.placeId,
    // required this.placeDetails
  }) : super(key: key);
  late String placeId;
  // late String placeDetails;
  final DateTime date;
  TimePicker startPicker = TimePicker(
      labelText: "Start Time", selectedDate: DateTime.now(), initialise: true);
  TimePicker endPicker = TimePicker(
      labelText: "End Time", selectedDate: DateTime.now(), initialise: true);

  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final formKey = GlobalKey<FormState>();
  final EventRepository repository = EventRepository();
  final BookingRepository bookings = BookingRepository();
  final uid = FirebaseAuth.instance.currentUser?.email as String;

  String title = '';
  int maxCap = 0;
  DateTime? startTime;
  DateTime? endTime;
  String type = 'insert type here';
  bool active = false;

  // @override
  // void initState() {
  //   super.initState();
  //   print('initialising');
  //   widget.startPicker = TimePicker(
  //     selectedDate: widget.date,
  //     labelText: "Start Time",
  //     initialise: true,
  //   );
  //   widget.endPicker = TimePicker(
  //     selectedDate: widget.date,
  //     labelText: "End Time",
  //     initialise: false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return const LottieEvent();
          }

          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
                child: Form(
                  key: formKey,
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      buildName(),
                      buildMaxCap(),
                      widget.startPicker,
                      widget.endPicker,
                      BouncingButton(
                          bgColor: Color(0xffE96B46),
                          borderColor: Color(0xffE96B46),
                          buttonText: "Submit",
                          textColor: Color(0xffffffff),
                          onClick: () async {
                            final isValid = formKey.currentState?.validate();
                            bool overnight = false;
                            setState(() {
                              startTime = widget.startPicker.selectedTime;
                              endTime = widget.endPicker.selectedTime;
                              if (endTime!.isBefore(startTime!)) {
                                overnight = true;
                                Navigator.pop(context, 2);
                              }
                            });

                            if (isValid != null && isValid && !overnight) {
                              formKey.currentState?.save();
                              if (startTime!.isBefore(DateTime.now()) &&
                                  (!widget.date.isAfter(DateTime.now()))) {
                                active = true;
                              }
                              SportEvent newEvent = SportEvent(
                                name: title,
                                start: startTime!,
                                end: endTime!,
                                maxCap: maxCap,
                                curCap: 1,
                                placeId: widget.placeId,
                                type: type,
                                active: active,
                                //temporary id
                              );

                              DocumentReference addedDocRef =
                                  await repository.addEvent(newEvent);
                              String newId = addedDocRef.id;
                              bookings.addBooking(uid, newId, active);

                              Navigator.pop(context, 1);
                            } else {
                              Navigator.pop(context, 0);
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget buildName() => Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Name of Event',
            prefixIcon: Icon(Icons.sports_basketball_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.length < 4) {
              return 'Enter at least 4 characters';
            } else {
              return null;
            }
          },
          //maxLength: 100,
          //maxLines: 3,
          onSaved: (value) =>
              setState(() => title = value ??= 'missing event name'),
        ),
      );

  Widget buildMaxCap() => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Max no. of Buds attending: ',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          validator: (value) {
            if (value != null && int.parse(value) > 30) {
              return 'Must be at most 30 due to COVID laws';
            } else {
              return null;
            }
          },
          onSaved: (value) => setState(() {
            if (value != null) {
              maxCap = int.parse(value);
            } else {
              maxCap = 0;
            }
          }),
        ),
      );
}

const BoxDecoration _background = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/create-event.png'),
    alignment: Alignment.topCenter,
    fit: BoxFit.fitWidth,
  ),
  borderRadius: BorderRadius.all(Radius.circular(20.0)),
);

Container _header = Container(
  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
  color: Color(0xffE5E8E8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const <Widget>[
      Text('Create Event', style: _titleStyle),
      SizedBox(height: 15),
      Text(
          'Want to host a game? Fill up this form and wait for SportBuddies to join!',
          style: _subheadingStyle),
    ],
  ),
);
const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 50, color: Color(0xffE3663E));
const TextStyle _subheadingStyle =
    TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold);
const TextStyle _infoStyle = TextStyle(color: Colors.black87, fontSize: 15);
