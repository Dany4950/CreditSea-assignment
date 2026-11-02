import 'package:creditsea/core/network/api_models.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/onboarding_models.dart';

/// Remote data source for /onboarding/*.
class OnboardingApi {
  OnboardingApi(this._client);
  final ApiClient _client;

  Future<PersonalDetailsResponse> getPersonal() =>
      _client.getObject(ApiEndpoints.personal, PersonalDetailsResponse.fromJson);

  /// 422 VALIDATION_ERROR (field messages in `ApiException.errors`), 422 AGE_TOO_YOUNG.
  Future<OnboardingResult> savePersonal(PersonalDetailsDto d) =>
      _client.putObject(ApiEndpoints.personal, OnboardingResult.fromJson, data: d.toJson());

  Future<EmailStatus> getEmail() => _client.getObject(ApiEndpoints.email, EmailStatus.fromJson);

  /// 429 RESEND_COOLDOWN carries `retryAfter` seconds for the resend timer.
  Future<OtpSentResponse> sendEmailOtp(SendEmailOtpRequest r) =>
      _client.postObject(ApiEndpoints.emailSendOtp, OtpSentResponse.fromJson, data: r.toJson());

  Future<OnboardingResult> verifyEmail(VerifyEmailRequest r) =>
      _client.postObject(ApiEndpoints.emailVerify, OnboardingResult.fromJson, data: r.toJson());

  Future<PanStatus> getPan() => _client.getObject(ApiEndpoints.pan, PanStatus.fromJson);

  /// 404 PAN_NOT_FOUND, 422 VALIDATION_ERROR.
  Future<OnboardingResult> verifyPan(VerifyPanRequest r) =>
      _client.postObject(ApiEndpoints.panVerify, OnboardingResult.fromJson, data: r.toJson());
}
