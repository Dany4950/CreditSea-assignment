import '../../../core/network/api_models.dart';

// ---- personal details: GET/PUT /onboarding/personal ------------------------
class PersonalDetailsDto {
  const PersonalDetailsDto({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.maritalStatus,
  });

  final String firstName;
  final String lastName;
  final String gender; // Male | Female | Other
  final String dob; // yyyy-MM-dd
  final String maritalStatus; // Single | Married | Divorced | Widowed

  factory PersonalDetailsDto.fromJson(Map<String, dynamic> j) => PersonalDetailsDto(
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        dob: j['dob'] as String? ?? '',
        maritalStatus: j['maritalStatus'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'dob': dob,
        'maritalStatus': maritalStatus,
      };
}

/// GET response: `personal` is null until the user saves the form once.
class PersonalDetailsResponse {
  const PersonalDetailsResponse({this.personal});
  final PersonalDetailsDto? personal;
  factory PersonalDetailsResponse.fromJson(Map<String, dynamic> j) => PersonalDetailsResponse(
        personal: j['personal'] is Map
            ? PersonalDetailsDto.fromJson(Map<String, dynamic>.from(j['personal'] as Map))
            : null,
      );
}

/// PUT response, also reused by email/PAN verification: tells the app whether onboarding is finished.
class OnboardingResult {
  const OnboardingResult({required this.profileComplete, this.message = ''});
  final bool profileComplete;
  final String message;
  factory OnboardingResult.fromJson(Map<String, dynamic> j) =>
      OnboardingResult(profileComplete: j['profileComplete'] == true, message: j['message'] as String? ?? '');
}

// ---- email ------------------------------------------------------------------
class EmailStatus {
  const EmailStatus({this.email, required this.verified});
  final String? email;
  final bool verified;
  factory EmailStatus.fromJson(Map<String, dynamic> j) =>
      EmailStatus(email: asStringOrNull(j['email']), verified: j['verified'] == true);
}

class SendEmailOtpRequest {
  const SendEmailOtpRequest({required this.email});
  final String email;
  Map<String, dynamic> toJson() => {'email': email};
}

class VerifyEmailRequest {
  const VerifyEmailRequest({required this.email, required this.otp});
  final String email;
  final String otp; // 6 digits
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

// ---- PAN --------------------------------------------------------------------
class PanStatus {
  const PanStatus({required this.verified, this.panMasked});
  final bool verified;
  final String? panMasked;
  factory PanStatus.fromJson(Map<String, dynamic> j) =>
      PanStatus(verified: j['verified'] == true, panMasked: asStringOrNull(j['panMasked']));
}

class VerifyPanRequest {
  const VerifyPanRequest({required this.pan});
  final String pan;

  /// Never log or keep this object around: it carries the raw PAN.
  Map<String, dynamic> toJson() => {'pan': pan};
}
