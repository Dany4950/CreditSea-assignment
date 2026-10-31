import 'package:get/get.dart';
import '../controllers/status_controller.dart';
import '../repositories/loan_repository.dart';
import 'calculator_binding.dart';

class StatusBinding extends Bindings {
  @override
  void dependencies() {
    registerLoanRepository();
    Get.lazyPut<StatusController>(() => StatusController(Get.find<LoanRepository>()));
  }
}
