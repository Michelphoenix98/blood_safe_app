import 'package:flutter/cupertino.dart';

class Donor {
  final firstName;
  final lastName;
  final bloodGroup;
  final dateOfBirth;
  final emailID;
  Donor({
    @required this.firstName,
    @required this.lastName,
    @required this.bloodGroup,
    @required this.dateOfBirth,
    @required this.emailID,
  });
}
