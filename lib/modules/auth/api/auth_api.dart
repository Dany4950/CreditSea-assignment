import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_models.dart';
import '../models/auth_models.dart' hide OtpSentResponse;

/// Remote data source for /auth/*. Pure HTTP: no UI, no storage.
class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  /// 409 USER_EXISTS if the number is already registered.
  Future<OtpSentResponse> requestOtp(RequestOtpRequest r) =>
      _client.postObject(ApiEndpoints.requestOtp, OtpSentResponse.fromJson, data: r.toJson());

  /// 400 INVALID_OTP / OTP_EXPIRED, 429 TOO_MANY_ATTEMPTS.
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest r) =>
      _client.postObject(ApiEndpoints.verifyOtp, VerifyOtpResponse.fromJson, data: r.toJson());

  Future<MessageResponse> setPassword(SetPasswordRequest r) =>
      _client.postObject(ApiEndpoints.setPassword, MessageResponse.fromJson, data: r.toJson());

  /// 401 INVALID_CREDENTIALS, 429 ACCOUNT_LOCKED. Does NOT store the token: SessionService.start does.
  Future<LoginResponse> login(LoginRequest r) =>
      _client.postObject(ApiEndpoints.login, LoginResponse.fromJson, data: r.toJson());

  /// Revokes every token of the user on the server.
  Future<MessageResponse> logout() =>
      _client.postObject(ApiEndpoints.logout, MessageResponse.fromJson, data: const <String, dynamic>{});
}
