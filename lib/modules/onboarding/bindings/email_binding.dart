import 'package:get/get.dart';
import '../controllers/email_controller.dart';
import '../repositories/onboarding_repository.dart';
import 'personal_details_binding.dart';

class EmailBinding extends Bindings {
  @override
  void dependencies() {
    registerOnboardingRepository();
    Get.lazyPut<EmailController>(() => EmailController(Get.find<OnboardingRepository>()));
  }
}
