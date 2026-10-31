import 'package:get/get.dart';
import '../controllers/otp_controller.dart';
import '../repositories/auth_repository.dart';
import 'auth_binding.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    registerAuthRepository();
    Get.lazyPut<OtpController>(() => OtpController(Get.find<AuthRepository>()));
  }
}
