import 'package:get/get.dart';
import '../controllers/pan_controller.dart';
import '../repositories/onboarding_repository.dart';
import 'personal_details_binding.dart';

class PanBinding extends Bindings {
  @override
  void dependencies() {
    registerOnboardingRepository();
    Get.lazyPut<PanController>(() => PanController(Get.find<OnboardingRepository>()));
  }
}
