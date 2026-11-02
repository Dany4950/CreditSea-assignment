import 'package:creditsea/modules/auth/services/session_service.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../api/user_api.dart';
import '../models/user_profile.dart';
import 'profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api, this._session);
  final UserApi _api;
  final SessionService _session;

  @override
  Future<UserProfile> fetchProfile() async {
    try {
      return await _api.getProfile();
    } on ApiException catch (e) {
      throw ProfileException(e.message);
    }
  }

  /// Revokes the token on the server (best effort), clears secure storage + cache, opens Sign In.
  @override
  Future<void> logout() => _session.end();
}

void registerApiProfileRepository() => Get.put<ProfileRepository>(
      ApiProfileRepository(Get.find<UserApi>(), Get.find<SessionService>()),
      permanent: true,
    );
