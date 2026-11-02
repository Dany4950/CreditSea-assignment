import '../../../core/network/api_models.dart';

/// GET /user/profile
class UserProfile {
  const UserProfile({
    required this.id,
    required this.mobile,
    required this.profileComplete,
    this.firstName,
    this.lastName,
    this.gender,
    this.dob,
    this.maritalStatus,
    this.email,
    this.emailVerified = false,
    this.panMasked,
    this.panVerified = false,
    this.creditScore,
  });

  final String id;
  final String mobile;
  final bool profileComplete;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dob; // yyyy-MM-dd
  final String? maritalStatus;
  final String? email;
  final bool emailVerified;
  final String? panMasked; // ABCDE****F, the full PAN is never returned
  final bool panVerified;
  final int? creditScore;

  String get fullName => [firstName, lastName].whereType<String>().join(' ').trim();
  DateTime? get dobDate => dob == null ? null : DateTime.tryParse(dob!);

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String? ?? '',
        mobile: j['mobile'] as String? ?? '',
        profileComplete: j['profileComplete'] == true,
        firstName: asStringOrNull(j['firstName']),
        lastName: asStringOrNull(j['lastName']),
        gender: asStringOrNull(j['gender']),
        dob: asStringOrNull(j['dob']),
        maritalStatus: asStringOrNull(j['maritalStatus']),
        email: asStringOrNull(j['email']),
        emailVerified: j['emailVerified'] == true,
        panMasked: asStringOrNull(j['panMasked']),
        panVerified: j['panVerified'] == true,
        creditScore: j['creditScore'] is num ? (j['creditScore'] as num).toInt() : null,
      );
}

/// PUT /user/profile. Only non-null fields are sent. DOB, gender and PAN are locked once verified.
class UpdateProfileRequest {
  const UpdateProfileRequest({this.firstName, this.lastName, this.maritalStatus});
  final String? firstName;
  final String? lastName;
  final String? maritalStatus;

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
      };
}
