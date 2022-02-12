import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/time_picker.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({Key? key}) : super(key: key);

  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final formKey = GlobalKey<FormState>();

  TimePicker startPicker = TimePicker(labelText: "Start Time");
  TimePicker endPicker = TimePicker(labelText: "End Time");
  String title = '';
  int maxCap = 0;
  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          decoration: _background,
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        _header,
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
                    print("hello");
                    final isValid = formKey.currentState?.validate();
                    setState(() {
                      startTime = startPicker.selectedTime;
                      endTime = endPicker.selectedTime;
                    });

                    if (isValid != null && isValid) {
                      formKey.currentState?.save();
                      final message =
                          'Event Name: $title\nMax Capacity: $maxCap\nStart Time: $startTime\nEnd Time: $endTime';
                      final snackBar = SnackBar(
                        content: Text(
                          message,
                          style: TextStyle(fontSize: 20),
                        ),
                        backgroundColor: Colors.green,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
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
