import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Center(
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          children: [
            buildTitle(),
            buildMaxCap(),
            startPicker,
            endPicker,
            buildSubmit(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() => TextFormField(
        decoration: const InputDecoration(
          labelText: 'Event name',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value != null && value.length < 4) {
            return 'Enter at least 4 characters';
          } else {
            return null;
          }
        },
        maxLength: 30,
        onSaved: (value) =>
            setState(() => title = value ??= 'missing event name'),
      );
  Widget buildMaxCap() => TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Max no. of players:',
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
      );

  Widget buildSubmit() => Builder(
        builder: (context) => TextButton(
          child: const Text('Submit Button'),
          onPressed: () {
            final isValid = formKey.currentState?.validate();
            // FocusScope.of(context).unfocus();

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
      );
}
