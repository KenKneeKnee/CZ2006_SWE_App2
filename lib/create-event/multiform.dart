import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/calendar/grrrrrrr.dart';
import 'package:my_app/events/booking_repository.dart';
import 'package:my_app/events/create_event.dart';
import 'package:my_app/events/event_repository.dart';
import 'package:my_app/events/sportevent.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:my_app/widgets/time_picker.dart';

class MultiStepForm extends StatefulWidget {
  MultiStepForm({Key? key, required this.placeId, required this.sportsFacility})
      : super(key: key);
  final String placeId;
  final SportsFacility sportsFacility;
  late Grr grrCalendar;
  TimePicker startPicker = TimePicker(
      labelText: "Start Time", selectedDate: DateTime.now(), initialise: true);
  TimePicker endPicker = TimePicker(
      labelText: "End Time", selectedDate: DateTime.now(), initialise: true);

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;
  bool isCompleted = false;
  DateTime date = DateTime.now();

  final formKey = GlobalKey<FormState>();
  final EventRepository repository = EventRepository();
  final BookingRepository bookings = BookingRepository();
  final uid = FirebaseAuth.instance.currentUser?.email as String;
  String title = '';
  int maxCap = 0;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    widget.grrCalendar =
        Grr(placeId: widget.placeId, sportsFacility: widget.sportsFacility);
  }

  List<Step> getSteps() => [
        Step(
            title: Text('Date'),
            content: widget.grrCalendar,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Details'),
            content: Container(
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
                    // BouncingButton(
                    //     bgColor: Color(0xffE96B46),
                    //     borderColor: Color(0xffE96B46),
                    //     buttonText: "Submit",
                    //     textColor: Color(0xffffffff),
                    //     onClick: () async {
                    //       final isValid = formKey.currentState?.validate();
                    //       bool overnight = false;
                    //       setState(() {
                    //         startTime = widget.startPicker.selectedTime;
                    //         endTime = widget.endPicker.selectedTime;
                    //         if (endTime!.isBefore(startTime!)) {
                    //           overnight = true;
                    //           Navigator.pop(context, 2);
                    //         }
                    //       });

                    //       if (isValid != null && isValid && !overnight) {
                    //         formKey.currentState?.save();
                    //         SportEvent newEvent = SportEvent(
                    //           title,
                    //           startTime!,
                    //           endTime!,
                    //           maxCap,
                    //           1,
                    //           widget.placeId, //temporary id
                    //         );

                    //         DocumentReference addedDocRef =
                    //             await repository.addEvent(newEvent);
                    //         String newId = addedDocRef.id;
                    //         bookings.addBooking(uid, newId);

                    //         Navigator.pop(context, 1);
                    //       } else {
                    //         Navigator.pop(context, 0);
                    //       }
                    //     }),
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Complete'),
            content: Container(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed)
      ];

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == getSteps().length - 1;
    SportsFacility SportsFacil = widget.sportsFacility;

    return StreamBuilder<QuerySnapshot>(
        stream: repository.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return Container(color: Colors.black);
          }

          return Scaffold(
            appBar: AppBar(title: Text('Create Event')),
            body: Container(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: MapMarkerInfoHeader(
                        SportsFacil.placeName,
                        SportsFacil.facilityType,
                        SportsFacil.addressDesc,
                        SportsFacil.hoverImgPath),
                  ),
                  Expanded(
                    flex: 2,
                    child: Stepper(
                        type: StepperType.horizontal,
                        steps: getSteps(),
                        currentStep: _currentStep,
                        onStepContinue: () {
                          if (isLastStep) {
                            // setState(() {
                            //   isCompleted = true;
                            // });

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
                                  date = widget.grrCalendar.submittedDate;
                                  print(date);
                                });
                              }
                              _currentStep += 1;
                            });
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() {
                              print(_currentStep);
                              _currentStep -= 1;
                            });
                          }
                        },
                        onStepTapped: (step) => setState(() {
                              _currentStep = step;
                            }),
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
                                              startTime = widget
                                                  .startPicker.selectedTime;
                                              endTime =
                                                  widget.endPicker.selectedTime;
                                              if (endTime!
                                                  .isBefore(startTime!)) {
                                                overnight = true;
                                                Navigator.pop(context, 2);
                                              }
                                            });

                                            if (isValid != null &&
                                                isValid &&
                                                !overnight) {
                                              formKey.currentState?.save();
                                              SportEvent newEvent = SportEvent(
                                                title,
                                                startTime!,
                                                endTime!,
                                                maxCap,
                                                1,
                                                widget.placeId, //temporary id
                                              );

                                              DocumentReference addedDocRef =
                                                  await repository
                                                      .addEvent(newEvent);
                                              String newId = addedDocRef.id;
                                              bookings.addBooking(uid, newId);

                                              Navigator.pop(context, 1);
                                            } else {
                                              Navigator.pop(context, 0);
                                            }
                                          },
                                    child:
                                        Text(isLastStep ? 'CONFIRM' : 'NEXT'),
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
