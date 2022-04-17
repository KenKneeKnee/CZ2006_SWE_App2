import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/calendar/sportsbudcalendar.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/event_widgets.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/start/screens/error_page.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/time_picker.dart';

/// Multi-step form displayed when user clicks on 'View Calendar' from a SportsFacility Pop Up
/// Consists of three steps :
/// 1. Calendar which displays the list of events scheduled for the SportsFacility for each date.
/// This is also used to select the date for the event to be created
/// 2. Event details form where users can input the event title (with helper function BuildName()),
/// maximum capacity (with helper function buildMaxCap()),
/// time of event (with widgets StartPicker and End Picker),
/// event type (with helper function buildDropDown())
/// 3. Confirmation of event to be created
///
/// Also includes the use of a BookingRepository and EventRepository to facilitate the creation of event in the database
/// Event can only be created if conditions are fulfilled.
class CreateEventForm extends StatefulWidget {
  CreateEventForm(
      {Key? key, required this.placeId, required this.sportsFacility})
      : super(key: key);
  final String placeId;
  final SportsFacility sportsFacility;
  late SportsBudCalendar facilityCalendar;

  TimePicker startPicker = TimePicker(
      labelText: "Start Time", selectedDate: DateTime.now(), initialise: true);
  TimePicker endPicker = TimePicker(
      labelText: "End Time", selectedDate: DateTime.now(), initialise: true);

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  int _currentStep = 0;
  bool isCompleted = false;
  DateTime date = DateTime.now();

  final formKey = GlobalKey<FormState>();
  final EventRepository repository = EventRepository();
  final BookingRepository bookings = BookingRepository();
  final uid = FirebaseAuth.instance.currentUser?.email as String;
  String eventTitle = '';
  int maxCap = 0;
  DateTime? startTime;
  DateTime? endTime;
  String dropdownValue = "Select Sport";

  @override
  void initState() {
    super.initState();
    widget.facilityCalendar = SportsBudCalendar(
        placeId: widget.placeId, sportsFacility: widget.sportsFacility);
    print(uid);
  }

  List<Step> getSteps() => [
        Step(
            title: Text('Date'),
            content: widget.facilityCalendar,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Details'),
            content: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    buildName(),
                    buildMaxCap(),
                    buildDropdown(),
                    widget.startPicker,
                    widget.endPicker,
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Complete'),
            content: (isCompleted)
                ? Container(
                    child: Column(
                      children: [
                        calendarIcon,
                        SportEventTextWidget.Title("Confirm Details"),
                        SportEventTextWidget.Subtitle(eventTitle),
                        SportEventTextWidget.Subtitle(
                            widget.sportsFacility.placeName),
                      ],
                    ),
                  )
                : Container(color: Colors.black, height: 100),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed)
      ];

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == getSteps().length - 1;
    final isFirstStep = _currentStep == 0;
    SportsFacility SportsFacil = widget.sportsFacility;
    SportEvent newEvent;

    return StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return ErrorPage();
          }
          if (!snapshot.hasData) {
            return Container(color: Colors.black);
          }

          return Scaffold(
            appBar: AppBar(),
            body: Container(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Stepper(
                        type: StepperType.horizontal,
                        steps: getSteps(),
                        currentStep: _currentStep,
                        onStepContinue: () {
                          if (isLastStep) {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      decoration: DialogBoxDecoration
                                          .createEventSuccessBg,
                                      child: BouncingButton(
                                          bgColor: Color(0xffE96B46),
                                          borderColor: Color(0xffE96B46),
                                          buttonText: "Return to Map",
                                          textColor: Color(0xffffffff),
                                          onClick: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }));
                                });
                          } else {
                            setState(() {
                              if (_currentStep == 0) {
                                setState(() {
                                  date = widget.facilityCalendar.submittedDate;
                                  widget.startPicker = TimePicker(
                                      labelText: "Start Time",
                                      selectedDate:
                                          widget.facilityCalendar.submittedDate,
                                      initialise: true);

                                  widget.endPicker = TimePicker(
                                      labelText: "End Time",
                                      selectedDate:
                                          widget.facilityCalendar.submittedDate,
                                      initialise: true);

                                  print(date);
                                });
                              } else if (_currentStep == 1) {
                                setState(() {
                                  startTime = widget.startPicker.selectedTime;
                                  DateTime today = DateTime.now();
                                  if (startTime == null) {
                                    startTime = today.add(Duration(
                                        hours: today.hour,
                                        minutes: today.minute));
                                  }
                                  endTime = widget.endPicker.selectedTime;
                                  if (endTime == null) {
                                    endTime = today.add(Duration(
                                        hours: today.hour,
                                        minutes: today.minute));
                                  }

                                  final isValid =
                                      formKey.currentState?.validate();
                                  if (isValid != null && isValid) {
                                    formKey.currentState?.save();
                                    isCompleted = true;
                                  }
                                });
                              }
                              _currentStep += 1;
                            });
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() {
                              _currentStep -= 1;
                            });
                          }
                        },
                        controlsBuilder:
                            (BuildContext context, ControlsDetails controls) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (!isLastStep)
                                        ? controls.onStepContinue
                                        : () async {
                                            final isValid = formKey.currentState
                                                ?.validate();
                                            bool overnight = false;
                                            setState(() {
                                              if (endTime!
                                                  .isBefore(startTime!)) {
                                                overnight = true;
                                                Navigator.pop(context, 2);
                                              }
                                            });

                                            if (isValid != null &&
                                                isValid &&
                                                !overnight) {
                                              newEvent = SportEvent(
                                                  name: eventTitle,
                                                  start: startTime!,
                                                  end: endTime!,
                                                  maxCap: maxCap,
                                                  curCap: 1,
                                                  placeId: widget
                                                      .placeId, //temporary id
                                                  type: dropdownValue,
                                                  active: true);

                                              DocumentReference addedDocRef =
                                                  await repository
                                                      .addEvent(newEvent);
                                              String newId = addedDocRef.id;
                                              bookings.addBooking(
                                                  uid, newId, true);

                                              Navigator.pop(context, 1);
                                            } else {
                                              Navigator.pop(context, 0);
                                            }
                                          },
                                    child: Text((() {
                                      if (isLastStep) {
                                        return "SUBMIT";
                                      } else if (isFirstStep) {
                                        return "CREATE EVENT";
                                      }
                                      return "NEXT";
                                    })()),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                if (_currentStep != 0)
                                  Expanded(
                                    child: TextButton(
                                      onPressed: controls.onStepCancel,
                                      child: const Text(
                                        'BACK',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        });
  }

  ///Helper function of CreateEventForm which builds a widget for the user to input the event title
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
          onSaved: (value) =>
              setState(() => eventTitle = value ??= 'missing event name'),
        ),
      );

  ///Helper function of CreateEventForm which builds a widget for the user to input the maximum capacity
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

  ///Helper function of CreateEventForm which builds a widget for the user to input the event type
  Widget buildDropdown() => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(10),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          validator: (value) {
            if (value == "Select Sport") {
              return 'Please select sport type for this event';
            } else {
              return null;
            }
          },
          isExpanded: true,
          icon: const Icon(Icons.sports_football_outlined),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: <String>[
            "Select Sport",
            'Gym',
            'Ball Games',
            'Aerobic Exercise',
            'Racket Games',
            'Water Sports'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(value),
              ),
            );
          }).toList(),
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

const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 50, color: Color(0xffE3663E));
const TextStyle _subheadingStyle =
    TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold);
const TextStyle _infoStyle = TextStyle(color: Colors.black87, fontSize: 15);
