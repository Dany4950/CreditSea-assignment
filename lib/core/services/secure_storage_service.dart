import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Keystore (Android) / Keychain (iOS) backed storage for secrets.
/// The token is mirrored in memory so interceptors never wait on a
/// platform-channel read for every request.
class SecureStorageService extends GetxService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  String? _token;
  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<SecureStorageService> init() async {
    _token = await _storage.read(key: _tokenKey);
    return this;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clear() async {
    _token = null;
    await _storage.deleteAll();
  }
}
