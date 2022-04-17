/// Create review form used to get user input when creating a review for a facility

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/reviews/Review.dart';
import 'package:my_app/reviews/facil_repository.dart';
import 'package:my_app/reviews/storage_repository.dart';
import 'package:my_app/user_profile/data/userDbManager.dart';
import 'package:my_app/widgets/bouncing_button.dart';

final uid = FirebaseAuth.instance.currentUser?.email as String;
final Storage storage = Storage();
final UserDbManager userDb = UserDbManager();

class CreateReviewForm extends StatefulWidget {
  const CreateReviewForm({Key? key, required this.placeId}) : super(key: key);
  final String placeId;
  @override
  State<CreateReviewForm> createState() => _CreateReviewFormState();
}

class _CreateReviewFormState extends State<CreateReviewForm> {
  final FacilRepository facils = FacilRepository();
  int _currentStep = 0;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final ratingController = TextEditingController();

  XFile? imageFile;
  // double userRating = 1.0;

  @override
  void initState() {
    super.initState();
    ratingController.text = "3.0";
  }

  /// create review form UI that progresses based on 'steps' the user has taken
  final formKey = GlobalKey<FormState>();
  String reviewTitle = '';
  List<Step> getSteps() => [
        Step(
            title: Text('Rating'),
            content: Container(
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextField(
                    enabled: false,
                    controller: ratingController,
                  ),
                  RatingBar.builder(
                    itemSize: 30,
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        // userRating = rating;
                        ratingController.text = rating.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Description'),
            content: Container(
              child: Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    buildTitle(titleController),
                    buildDesc(descController),
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed),
        Step(
            title: Text('Photo'),
            content: Container(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      imageFile = pickedFile!;
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(135, 180, 187, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    child: Text(
                      "Select Photo",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed)
      ];

  /// helper function to add the review to the facilities database
  void postReview(String title, int rating, String desc, String user,
      XFile? imageFile) async {
    Review r = Review(title, rating, desc, user);
    DocumentReference docref = await facils.addReviewFor(widget.placeId, r);
    if (imageFile != null) {
      await storage.uploadFile(imageFile.path,
          docref.id); // image is uploaded with same doc id as review
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == getSteps().length - 1;
    return Container(

      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
              color: Colors.blue,
              child: Image.asset(
                'assets/images/write-review.png',
              ),
              padding: EdgeInsets.all(8)),

          FutureBuilder<QuerySnapshot>(builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return Stepper(
                type: StepperType.vertical,
                steps: getSteps(),
                currentStep: _currentStep,
                onStepContinue: () {
                  setState(() {
                    if (_currentStep == 0) {
                      print(ratingController.text);
                    } else if (_currentStep == 2) {
                      final isValid = formKey.currentState?.validate();
                      if (isValid != null && isValid) {
                        formKey.currentState?.save();
                        postReview(
                            titleController.text,
                            int.parse(ratingController.text[0]),
                            descController.text,
                            uid,
                            imageFile);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } else {
                        //some function to tell user their form is wrong
                      }
                    }
                    print("the current state is ${_currentStep}");
                    if (!isLastStep) _currentStep += 1;
                  });
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
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
                            onPressed: controls.onStepContinue,
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xffE96B46),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            child: Text(
                              isLastStep ? 'SUBMIT' : 'NEXT',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        (_currentStep != 0)
                            ? Expanded(
                                child: TextButton(
                                  onPressed: controls.onStepCancel,
                                  child: const Text(
                                    'BACK',
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    ),
                  );
                });
          }),
        ],
      ),
    );
  }
}
/// title input widget to be built
Widget buildTitle(title) => Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: title,
        decoration: const InputDecoration(
          labelText: 'Review Title',
          //prefixIcon: Icon(Icons.sports_basketball_outlined),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value != null && value.length < 4 ||
              value != null && value.length > 50) {
            return 'Enter between 4-50 characters';
          } else {
            return null;
          }
        },
      ),
    );

/// description input widget to be built
Widget buildDesc(desc) => Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: desc,
          keyboardType: TextInputType.multiline,
          minLines: 3, //Normal textInputField will be displayed
          maxLines: 8, // when user presses enter it will adapt to it
          decoration: const InputDecoration(
            labelText: 'Describe your time here!',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.length > 300) {
              return 'Please keep to a character limit of 300.';
            } else {
              return null;
            }
          },
        ),
      ),
    );
