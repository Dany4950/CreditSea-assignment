import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _storage = Get.find<SecureStorageService>();
  final _api = Get.find<ApiClient>();

  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    // Run the session check in parallel with the minimum splash time.
    final results = await Future.wait<String?>([
      _resolveRoute(),
      Future<String?>.delayed(AppDurations.splashMin),
    ]);
    final route = results.first;
    if (route != null) Get.offAllNamed(route);
  }

  /// Returns the route to open, or null if the 401 interceptor already redirected.
  Future<String?> _resolveRoute() async {
   return Routes.createAccount;

    try {
      // Backend contract: GET /user/profile -> { profileComplete: bool, ... }
      final res = await _api.get('/user/profile');
      final complete = (res is Map && res['profileComplete'] == true);
      return complete ? Routes.calculator : Routes.personalDetails;
    } on ApiException catch (e) {
      if (e.isUnauthorized) return null; // interceptor already went to sign-in
      // Offline / server asleep: keep the user logged in, let them in.
      return Routes.calculator;
    }
  }
}
