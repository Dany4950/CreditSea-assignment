import 'package:get/get.dart';
import '../controllers/create_password_controller.dart';
import '../repositories/auth_repository.dart';
import 'auth_binding.dart';

class CreatePasswordBinding extends Bindings {
  @override
  void dependencies() {
    registerAuthRepository();
    Get.lazyPut<CreatePasswordController>(
        () => CreatePasswordController(Get.find<AuthRepository>()));
  }
}
