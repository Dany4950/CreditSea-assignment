import 'package:intl/intl.dart';

class PersonalDetails {
  const PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.maritalStatus,
  });

  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dob;
  final String maritalStatus;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'dob': DateFormat('yyyy-MM-dd').format(dob),
        'maritalStatus': maritalStatus,
      };
}
