import 'package:get/get.dart';
import '../controllers/create_account_controller.dart';
import '../repositories/auth_repository.dart';

/// fenix: true -> the repo is recreated if its owning route was disposed,
/// so every auth binding can safely call this.
void registerAuthRepository() =>
    Get.lazyPut<AuthRepository>(MockAuthRepository.new, fenix: true);

class CreateAccountBinding extends Bindings {
  @override
  void dependencies() {
    registerAuthRepository();
    Get.lazyPut<CreateAccountController>(
        () => CreateAccountController(Get.find<AuthRepository>()));
  }
}
