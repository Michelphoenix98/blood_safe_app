import 'dart:async';

import 'package:blood_donor/data_structs.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_questions/conditional_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'backend_services.dart';
import 'common.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';

import 'home_screen.dart';
import 'text_resource.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  resizeToAvoidBottomInset: false,
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
      body: Container(
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewPortConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewPortConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: RegistrationForm(),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

enum Gender { MALE, FEMALE }

class _RegistrationFormState extends State<RegistrationForm> {
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _pass1Controller = new TextEditingController();
  TextEditingController _pass2Controller = new TextEditingController();
  TextEditingController _emailIDController = new TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _bloodGroupController = new TextEditingController();

  QuestionHandler questionManager;
  @override
  void initState() {
    super.initState();
    questionManager = QuestionHandler(questions(), callback: update);
  }

  static final _formKey = GlobalKey<FormState>();
  String _chosenDate = "Date of Birth";
  Gender _groupVal = null;
  bool _isConsentGiven = false;
  bool _promptConsent = false;

  void update() {
    setState(() {});
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      //we wait for the dialog to return
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (date != null) //if the user has selected a date
      setState(() {
        // we format the selected date and assign it to the state variable
        _chosenDate = new DateFormat.yMMMMd("en_US").format(date);
        _dateController.text = _chosenDate.toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    //print("children:${(questions().first as NestedQuestion).children}");
    final passValidator = MultiValidator([
      RequiredValidator(errorText: 'password is required'),
      MinLengthValidator(8,
          errorText: 'password must be\nat least 8 digits long'),
      PatternValidator(r'(?=.*?[#?!@$%^&*-])',
          errorText: 'passwords must have\nat least one special character')
    ]);
    return Form(
      key: _formKey,
      child: Column(
        // mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          Expanded(
            child: ClipPath(
              clipper: MyClipper(),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: SvgPicture.asset("images/register.svg",
                          semanticsLabel: 'Acme Logo'),
                    ),
                    Expanded(
                      child: Text(
                        "Save a life today!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3383CD),
                      Color(0xFF11249F),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextBox(
                  textController: _firstNameController,
                  hintText: "First name",
                  validationFunction: (field) {
                    if (field.isEmpty) return "Field empty";
                    return null;
                  },
                ),
              ),
              Expanded(
                child: TextBox(
                  textController: _lastNameController,
                  hintText: "Last name",
                  validationFunction: (field) {
                    if (field.isEmpty) return "Field empty";
                    return null;
                  },
                ),
              ),
            ],
          ),
          TextBox(
            textController: _emailIDController,
            hintText: "Email ID",
            validationFunction: (String string) {
              if (string.isEmpty)
                return "Field empty";
              else
                return EmailValidator(errorText: '').isValid(string) != true
                    ? 'Enter a valid email address'
                    : null;
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextBox(
                  textController: _pass1Controller,
                  validationFunction: (String string) {
                    if (string.isEmpty)
                      return "Field empty";
                    else
                      return passValidator.isValid(string)
                          ? null
                          : passValidator.errorText;
                  },
                  hintText: "Create password",
                  obscureText: true,
                ),
              ),
              Expanded(
                child: TextBox(
                  textController: _pass2Controller,
                  validationFunction: (String string) {
                    if (string.isEmpty)
                      return "Field empty";
                    else
                      return string == _pass1Controller.text
                          ? null
                          : "Passwords don't match";
                  },
                  hintText: "Confirm password",
                  obscureText: true,
                ),
              ),
            ],
          ),
          Row(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.0,
                child: TextBox(
                  readOnly: true,
                  //  isEnabled: false,
                  hintText: "$_chosenDate",
                  textController: _dateController,
                  validationFunction: (field) {
                    if (field.isEmpty) return "Select a date";
                    return null;
                  },
                ),
              ),
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  tooltip: 'Tap to open date picker',
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    _pickDate(context);
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 25, 8),
                      child: Row(
                        children: <Widget>[
                          Radio(
                            value: Gender.MALE,
                            groupValue: _groupVal,
                            onChanged: (value) {
                              setState(() {
                                _groupVal = value;
                              });
                            },
                          ),
                          Text("Male"),
                          Radio(
                            value: Gender.FEMALE,
                            groupValue: _groupVal,
                            onChanged: (value) {
                              setState(() {
                                _groupVal = value;
                              });
                            },
                          ),
                          Text("Female"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextBox(
            textController: _bloodGroupController,
            hintText: "Blood Group eg A +ve",
            validationFunction: (String string) {
              if (string.isEmpty) return "Field empty";
              return null;
            },
          ),
          Column(
            children: questionManager.getWidget(context),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                value: _isConsentGiven,
                onChanged: (value) {
                  setState(() {
                    _isConsentGiven = value;
                  });
                },
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "By registering, I agree to the ",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => print('Tap Here onTap'), //legal prints
                      text: "Terms of Service\n",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto"),
                    ),
                    TextSpan(
                      text: "and ",
                      style:
                          TextStyle(fontFamily: "Roboto", color: Colors.grey),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => print('LEGAL'), //legal prints
                      text: "Privacy Policy.",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
              )
            ],
          ),
          _promptConsent
              ? Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  child: Text(
                    "You must agree to the terms.",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Container(),
          Button(
            text: "Register",
            onPressed: () async {
              UserRec user;
              // Focus.of(context).unfocus();
              FocusScope.of(context).unfocus();
              print("---->1toMap:${questionManager.toMap()}");
              Map<dynamic, dynamic> temp = questionManager.toMap();
              questionManager.resetState();
              print("2toMap:${questionManager.toMap()}");
              questionManager.setState(temp);
              print("3toMap:${questionManager.toMap()}");
              if (/*_formKey.currentState.validate()*/ questionManager
                      .validate() &&
                  _isConsentGiven == true) {
                _promptConsent = false;
                Auth auth = new Auth();
                await auth
                    .signUp(
                        _firstNameController.text +
                            " " +
                            _lastNameController.text,
                        _emailIDController.text,
                        _pass1Controller.text)
                    .then((value) {
                  user = value;
                }).whenComplete(() {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${user.message}",
                      ),
                    ),
                  );
                  if (auth.state == STATE.SUCCESS) {
                    //PLEASE VERIFY
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please check your mail for the verification link",
                        ),
                      ),
                    );
                    Timer(Duration(seconds: 6), () {
                      //pop off all details of the donor encapsulated into a single object

                      FirebaseFirestore.instance
                          .collection("unverifiedUsers")
                          .doc("${auth.getUser().user.uid}")
                          .set({
                        'firstName': _firstNameController.text,
                        'lastName': _lastNameController.text,
                        'bloodGroup': _bloodGroupController.text,
                        'dateOfBirth': _dateController.text,
                        'emailID': _emailIDController.text,
                        'uid': auth.getUser().user.uid,
                        'status': 'pending'
                      });

                      Navigator.of(context).pop();
                    });
                  }
                });
              } else
                FocusScope.of(context).requestFocus(FocusNode());

              setState(() {
                if (_isConsentGiven == false)
                  _promptConsent = true;
                else
                  _promptConsent = false;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //questionManager.dispose();
    super.dispose();
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
