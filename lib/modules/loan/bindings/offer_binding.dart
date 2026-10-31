import 'package:get/get.dart';
import '../controllers/offer_controller.dart';
import '../repositories/loan_repository.dart';
import 'calculator_binding.dart';

class OfferBinding extends Bindings {
  @override
  void dependencies() {
    registerLoanRepository();
    Get.lazyPut<OfferController>(() => OfferController(Get.find<LoanRepository>()));
  }
}
