import 'package:get/get.dart';

import '../../modules/auth/api/auth_api.dart';
import '../../modules/auth/services/session_service.dart';
import '../../modules/loan/api/loan_api.dart';
import '../../modules/onboarding/api/onboarding_api.dart';
import '../../modules/profile/api/user_api.dart';
import '../network/api_client.dart';
import '../services/cache_service.dart';
import '../services/secure_storage_service.dart';

/// Call once in main() after ApiClient / SecureStorageService / CacheService are registered.
/// `fenix: true` recreates an API object if GetX ever disposes it.
void registerApis() {
  Get.lazyPut<AuthApi>(() => AuthApi(Get.find<ApiClient>()), fenix: true);
  Get.lazyPut<UserApi>(() => UserApi(Get.find<ApiClient>()), fenix: true);
  Get.lazyPut<OnboardingApi>(() => OnboardingApi(Get.find<ApiClient>()), fenix: true);
  Get.lazyPut<LoanApi>(() => LoanApi(Get.find<ApiClient>(), Get.find<CacheService>()), fenix: true);
  Get.put<SessionService>(
    SessionService(
      storage: Get.find<SecureStorageService>(),
      cache: Get.find<CacheService>(),
      authApi: Get.find<AuthApi>(),
    ),
    permanent: true,
  );
}
