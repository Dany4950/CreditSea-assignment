import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../api/onboarding_api.dart';
import '../models/onboarding_models.dart';
import '../models/personal_details.dart';
import 'onboarding_repository.dart';

/// Real OnboardingRepository: talks to the Render backend through [OnboardingApi].
class ApiOnboardingRepository implements OnboardingRepository {
  ApiOnboardingRepository(this._api);
  final OnboardingApi _api;

  static final _wireDate = DateFormat('yyyy-MM-dd');

  @override
  Future<PersonalDetails?> fetchPersonalDetails() => _guard(() async {
        final d = (await _api.getPersonal()).personal;
        if (d == null) return null;
        return PersonalDetails(
          firstName: d.firstName,
          lastName: d.lastName,
          gender: d.gender,
          dob: DateTime.parse(d.dob),
          maritalStatus: d.maritalStatus,
        );
      });

  @override
  Future<void> savePersonalDetails(PersonalDetails details) => _guard(() async {
        await _api.savePersonal(PersonalDetailsDto(
          firstName: details.firstName,
          lastName: details.lastName,
          gender: details.gender,
          dob: _wireDate.format(details.dob),
          maritalStatus: details.maritalStatus,
        ));
      });

  @override
  Future<String?> fetchEmail() => _guard(() async => (await _api.getEmail()).email);

  /// Returns the OTP only when the server runs in demo mode and no SMTP is configured.
  @override
  Future<String?> sendEmailOtp(String email) =>
      _guard(() async => (await _api.sendEmailOtp(SendEmailOtpRequest(email: email))).otp);

  @override
  Future<void> verifyEmailOtp(String email, String otp) =>
      _guard(() async => _api.verifyEmail(VerifyEmailRequest(email: email, otp: otp)));

  @override
  Future<bool> fetchPanVerified() => _guard(() async => (await _api.getPan()).verified);

  @override
  Future<void> verifyPan(String pan) => _guard(() async => _api.verifyPan(VerifyPanRequest(pan: pan)));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw OnboardingException(e.message);
    }
  }
}

void registerApiOnboardingRepository() =>
    Get.put<OnboardingRepository>(ApiOnboardingRepository(Get.find<OnboardingApi>()), permanent: true);
