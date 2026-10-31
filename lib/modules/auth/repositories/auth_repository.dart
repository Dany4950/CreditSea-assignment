class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Data contract for auth. Controllers depend on this abstraction only.
/// The real implementation (backend step) stores the JWT via
/// SecureStorageService inside [signIn].
abstract interface class AuthRepository {
  /// Returns the OTP only in demo mode (null in production).
  Future<String?> requestOtp(String mobile);
  Future<void> verifyOtp(String mobile, String otp);
  Future<void> setPassword({required String mobile, required String password});

  /// Returns `profileComplete` so the caller can route correctly.
  Future<bool> signIn({required String mobile, required String password});
}

class MockAuthRepository implements AuthRepository {
  static const demoOtp = '1234';
  static const _latency = Duration(milliseconds: 600);

  // static: survives repository re-creation (demo only, lost on app restart).
  static final Map<String, String> _users = {};

  @override
  Future<String?> requestOtp(String mobile) async {
    await Future<void>.delayed(_latency);
    return demoOtp;
  }

  @override
  Future<void> verifyOtp(String mobile, String otp) async {
    await Future<void>.delayed(_latency);
    if (otp != demoOtp) throw const AuthException('Incorrect OTP. Please try again.');
  }

  @override
  Future<void> setPassword({required String mobile, required String password}) async {
    await Future<void>.delayed(_latency);
    _users[mobile] = password;
  }

  @override
  Future<bool> signIn({required String mobile, required String password}) async {
    await Future<void>.delayed(_latency);
    if (_users[mobile] != password) {
      throw const AuthException('Invalid mobile number or password');
    }
    return false; // profile not complete yet -> Personal Details
  }
}
