import '../models/user_profile.dart';

class ProfileException implements Exception {
  const ProfileException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Data contract for the Profile screen.
abstract interface class ProfileRepository {
  /// GET /user/profile
  Future<UserProfile> fetchProfile();

  /// POST /auth/logout, then wipe the local session and go to Sign In.
  Future<void> logout();
}
