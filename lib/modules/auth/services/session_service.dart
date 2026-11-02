import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../routes/app_routes.dart';
import '../api/auth_api.dart';

/// Owns "who is logged in": persists the JWT in secure storage and tears the session down on logout.
class SessionService extends GetxService {
  SessionService({
    required SecureStorageService storage,
    required CacheService cache,
    required AuthApi authApi,
  })  : _storage = storage,
        _cache = cache,
        _authApi = authApi;

  final SecureStorageService _storage;
  final CacheService _cache;
  final AuthApi _authApi;

  /// 10-minute token issued after OTP verification and consumed by set-password.
  /// Memory only: never persisted. Lives here (a permanent singleton) so it survives screen/binding changes.
  String? pendingRegistrationToken;

  bool get isLoggedIn => _storage.hasToken;

  /// Call after a successful login. Starts from a clean cache so one user never sees another's data.
  Future<void> start(String token) async {
    await _cache.clear();
    await _storage.saveToken(token);
  }

  /// Manual logout: revoke on the server (best effort), wipe local data, go to Sign In.
  Future<void> end() async {
    try {
      if (_storage.hasToken) await _authApi.logout();
    } on ApiException {
      // offline: still log out locally
    }
    pendingRegistrationToken = null;
    await _storage.clear();
    await _cache.clear();
    Get.offAllNamed(Routes.signIn);
  }
}
