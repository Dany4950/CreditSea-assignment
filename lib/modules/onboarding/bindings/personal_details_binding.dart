import 'package:get/get.dart';
import '../controllers/personal_details_controller.dart';
import '../repositories/onboarding_repository.dart';

/// fenix: true -> recreated if its owning route was disposed.
void registerOnboardingRepository() =>
    Get.lazyPut<OnboardingRepository>(MockOnboardingRepository.new, fenix: true);

class PersonalDetailsBinding extends Bindings {
  @override
  void dependencies() {
    registerOnboardingRepository();
    Get.lazyPut<PersonalDetailsController>(
        () => PersonalDetailsController(Get.find<OnboardingRepository>()));
  }
}
