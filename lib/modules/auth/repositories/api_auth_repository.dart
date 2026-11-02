import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../api/auth_api.dart';
import '../models/auth_models.dart';
import '../services/session_service.dart';
import 'auth_repository.dart';

/// Real AuthRepository: talks to the Render backend through [AuthApi].
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._session);
  final AuthApi _api;
  final SessionService _session;

  /// Returns the OTP only when the server runs in demo mode.
  @override
  Future<String?> requestOtp(String mobile) =>
      _guard(() async => (await _api.requestOtp(RequestOtpRequest(mobile: mobile))).otp);

  @override
  Future<void> verifyOtp(String mobile, String otp) => _guard(() async {
        final res = await _api.verifyOtp(VerifyOtpRequest(mobile: mobile, otp: otp));
        _session.pendingRegistrationToken = res.registrationToken; // memory only, used by setPassword
      });

  @override
  Future<void> setPassword({required String mobile, required String password}) => _guard(() async {
        final token = _session.pendingRegistrationToken;
        if (token == null) {
          throw const AuthException('Verification expired. Please verify your number again.');
        }
        await _api.setPassword(SetPasswordRequest(mobile: mobile, password: password, registrationToken: token));
        _session.pendingRegistrationToken = null;
      });

  /// Stores the JWT in secure storage (stay logged in) and returns `profileComplete` for routing.
  @override
  Future<bool> signIn({required String mobile, required String password}) => _guard(() async {
        final res = await _api.login(LoginRequest(mobile: mobile, password: password));
        await _session.start(res.token);
        return res.user.profileComplete;
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}

void registerApiAuthRepository() => Get.put<AuthRepository>(
      ApiAuthRepository(Get.find<AuthApi>(), Get.find<SessionService>()),
      permanent: true,
    );
