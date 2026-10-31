import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../../../routes/app_routes.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';

class OfferController extends GetxController {
  OfferController(this._repo);
  final LoanRepository _repo;

  late final String loanId;
  final status = ViewStatus.loading.obs;
  final loan = Rxn<Loan>();
  final accepting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    loanId = args is Map ? (args['loanId'] as String? ?? '') : '';
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /loans/:id
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final l = await _repo.fetchLoan(loanId);
      if (l.status != LoanStatus.offered) {
        // Offer already accepted: continue with the application status.
        Get.offNamed(Routes.status, arguments: {'loanId': loanId});
        return;
      }
      loan.value = l;
      status.value = ViewStatus.ready;
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  /// POST /loans/:id/accept -> Status
  Future<void> accept() async {
    if (accepting.value) return;
    accepting.value = true;
    try {
      await _repo.acceptOffer(loanId);
      Get.offNamed(Routes.status, arguments: {'loanId': loanId});
    } catch (_) {
      Get.snackbar('Could not accept offer', 'Please try again',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } finally {
      accepting.value = false;
    }
  }

  /// "Extend Offer": back to the calculator to choose another amount/tenure.
  void extend() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(Routes.calculator);
    }
  }
}
