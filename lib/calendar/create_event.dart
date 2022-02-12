import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/data/event_repository.dart';
import 'package:my_app/utils/events.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/time_picker.dart';

class CreateEventForm extends StatefulWidget {
  CreateEventForm(
      {Key? key,
      required this.date,
      required this.placeId,
      required this.placeDetails})
      : super(key: key);
  late String placeId;
  late String placeDetails;
  final DateTime date;

  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final formKey = GlobalKey<FormState>();
  final EventRepository repository = EventRepository();

  TimePicker startPicker = TimePicker(
    selectedDate: DateTime.now(),
    labelText: "Start Time",
    initialise: true,
  );
  TimePicker endPicker = TimePicker(
    selectedDate: DateTime.now(),
    labelText: "End Time",
    initialise: false,
  );
  String title = '';
  int maxCap = 0;
  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                decoration: _background,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              _header,
              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orangeAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${widget.placeDetails}",
                        style: _infoStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
                child: Form(
                  key: formKey,
                  child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      buildName(),
                      buildMaxCap(),
                      startPicker,
                      endPicker,
                      BouncingButton(
                        bgColor: Color(0xffE96B46),
                        borderColor: Color(0xffE96B46),
                        buttonText: "Submit",
                        textColor: Color(0xffffffff),
                        onClick: () {
                          final isValid = formKey.currentState?.validate();
                          setState(() {
                            startTime = startPicker.selectedTime;
                            endTime = endPicker.selectedTime;
                          });

                          if (isValid != null && isValid) {
                            formKey.currentState?.save();
                            Event newEvent = new Event(title, startTime!,
                                endTime!, maxCap, 0, widget.placeId);

                            repository.addEvent(newEvent);
                            Navigator.pop(context, true);
                            // Navigator.of(context, rootNavigator: true)
                            //     .pop(); //close dialog
                          } else {
                            Navigator.pop(context, false);
                          }
                        },
                      ),
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
            labelText: 'Max no. of players:',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
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
    image: AssetImage('create-event.png'),
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
