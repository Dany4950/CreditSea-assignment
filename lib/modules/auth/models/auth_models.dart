import '../../../core/network/api_models.dart';

// POST /auth/request-otp -------------------------------------------------
class RequestOtpRequest {
  const RequestOtpRequest({required this.mobile});
  final String mobile;
  Map<String, dynamic> toJson() => {'mobile': mobile};
}

/// Response of every "send OTP" call. `otp` is only present in the server's demo mode.
class OtpSentResponse {
  const OtpSentResponse({required this.message, this.otp});
  final String message;
  final String? otp;
  factory OtpSentResponse.fromJson(Map<String, dynamic> j) =>
      OtpSentResponse(message: j['message'] as String? ?? 'OTP sent', otp: asStringOrNull(j['otp']));
}

// POST /auth/verify-otp --------------------------------------------------
class VerifyOtpRequest {
  const VerifyOtpRequest({required this.mobile, required this.otp});
  final String mobile;
  final String otp;
  Map<String, dynamic> toJson() => {'mobile': mobile, 'otp': otp};
}

class VerifyOtpResponse {
  const VerifyOtpResponse({required this.registrationToken});

  /// 10-minute token. Keep it in memory and pass it to set-password. Never persist it.
  final String registrationToken;
  factory VerifyOtpResponse.fromJson(Map<String, dynamic> j) =>
      VerifyOtpResponse(registrationToken: j['registrationToken'] as String);
}

// POST /auth/set-password ------------------------------------------------
class SetPasswordRequest {
  const SetPasswordRequest({required this.mobile, required this.password, required this.registrationToken});
  final String mobile;
  final String password;
  final String registrationToken;
  Map<String, dynamic> toJson() =>
      {'mobile': mobile, 'password': password, 'registrationToken': registrationToken};
}

// POST /auth/login -------------------------------------------------------
class LoginRequest {
  const LoginRequest({required this.mobile, required this.password});
  final String mobile;
  final String password;
  Map<String, dynamic> toJson() => {'mobile': mobile, 'password': password};
}

class AuthUser {
  const AuthUser({required this.id, required this.mobile, required this.profileComplete});
  final String id;
  final String mobile;
  final bool profileComplete;
  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'] as String,
        mobile: j['mobile'] as String,
        profileComplete: j['profileComplete'] == true,
      );
}

class LoginResponse {
  const LoginResponse({required this.token, required this.user});
  final String token;
  final AuthUser user;
  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        token: j['token'] as String,
        user: AuthUser.fromJson(Map<String, dynamic>.from(j['user'] as Map)),
      );
}
