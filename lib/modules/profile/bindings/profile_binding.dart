import 'package:creditsea/modules/loan/repositories/loan_repository.dart';
import 'package:get/get.dart';


import '../controllers/profile_controller.dart';
import '../repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // put (not lazyPut) so onReady() fires and the data starts loading with the route.
    Get.put(ProfileController(Get.find<ProfileRepository>(), Get.find<LoanRepository>()));
  }
}
