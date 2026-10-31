import 'package:get/get.dart';
import '../controllers/sign_in_controller.dart';
import '../repositories/auth_repository.dart';
import 'auth_binding.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    registerAuthRepository();
    Get.lazyPut<SignInController>(() => SignInController(Get.find<AuthRepository>()));
  }
}
