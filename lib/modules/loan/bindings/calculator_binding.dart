import 'package:get/get.dart';
import '../controllers/calculator_controller.dart';
import '../repositories/loan_repository.dart';

/// fenix: true -> recreated if its owning route was disposed.
void registerLoanRepository() =>
    Get.lazyPut<LoanRepository>(MockLoanRepository.new, fenix: true);

class CalculatorBinding extends Bindings {
  @override
  void dependencies() {
    registerLoanRepository();
    Get.lazyPut<CalculatorController>(() => CalculatorController(Get.find<LoanRepository>()));
  }
}
