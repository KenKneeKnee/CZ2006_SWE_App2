import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePicker extends StatefulWidget {
  TimePicker({Key? key, required this.labelText}) : super(key: key);
  final String labelText;

  DateTime? selectedTime;

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TextEditingController timeinput = TextEditingController();
  //text editing controller for text field

  @override
  void initState() {
    timeinput.text = ""; //set the initial value of text field
    widget.selectedTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        height: 100,
        child: Center(
            child: TextField(
          controller: timeinput, //editing controller of this TextField
          decoration: InputDecoration(
              icon: Icon(Icons.timer), //icon of text field
              labelText: this.widget.labelText //label text of field
              ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );

            if (pickedTime != null) {
              print(pickedTime.format(context)); //output 10:51 PM
              DateTime parsedTime =
                  DateFormat.jm().parse(pickedTime.format(context).toString());
              //converting to DateTime so that we can further format on different pattern.
              print(parsedTime); //output 1970-01-01 22:53:00.000
              String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
              print(formattedTime); //output 14:59:00
              //DateFormat() is from intl package, you can format the time on any pattern you need.

              setState(() {
                timeinput.text = formattedTime; //set the value of text field.

                //convert the selected TimeOfDay into DateTime to be saved
                final DateTime now = DateTime.now();
                widget.selectedTime = DateTime(now.year, now.month, now.day,
                    pickedTime.hour, pickedTime.minute);
              });
            } else {
              print("Time is not selected");
            }
          },
        )));
  }
}
