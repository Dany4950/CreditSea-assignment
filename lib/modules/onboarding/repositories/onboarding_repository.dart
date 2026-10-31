import '../models/personal_details.dart';

class OnboardingException implements Exception {
  const OnboardingException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Data contract for the Register step. Real implementation = ApiClient calls
/// (see docs/PROGRESS.md "Backend contract"). Controllers never see dio.
abstract interface class OnboardingRepository {
  /// GET /onboarding/personal
  Future<PersonalDetails?> fetchPersonalDetails();

  /// PUT /onboarding/personal
  Future<void> savePersonalDetails(PersonalDetails details);

  /// GET /onboarding/email -> previously entered email, if any
  Future<String?> fetchEmail();

  /// POST /onboarding/email/send-otp -> demo OTP only in demo mode
  Future<String?> sendEmailOtp(String email);

  /// POST /onboarding/email/verify
  Future<void> verifyEmailOtp(String email, String otp);

  /// GET /onboarding/pan -> true if the PAN is already verified
  /// (the PAN itself is never sent back to the client)
  Future<bool> fetchPanVerified();

  /// POST /onboarding/pan/verify
  Future<void> verifyPan(String pan);
}

class MockOnboardingRepository implements OnboardingRepository {
  static const demoEmailOtp = '123456';
  static const _latency = Duration(milliseconds: 500);

  Future<void> _wait() => Future<void>.delayed(_latency);

  @override
  Future<PersonalDetails?> fetchPersonalDetails() async {
    await _wait();
    return null;
  }

  @override
  Future<void> savePersonalDetails(PersonalDetails details) => _wait();

  @override
  Future<String?> fetchEmail() async {
    await _wait();
    return null;
  }

  @override
  Future<String?> sendEmailOtp(String email) async {
    await _wait();
    return demoEmailOtp;
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    await _wait();
    if (otp != demoEmailOtp) throw const OnboardingException('Incorrect OTP. Please try again.');
  }

  @override
  Future<bool> fetchPanVerified() async {
    await _wait();
    return false;
  }

  @override
  Future<void> verifyPan(String pan) async {
    await _wait();
    if (pan == 'AAAAA0000A') throw const OnboardingException('PAN not found. Please check and retry.');
  }
}
