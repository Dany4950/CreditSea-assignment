import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../../../routes/app_routes.dart';
import '../models/eligibility.dart';
import '../models/loan_quote.dart';
import '../repositories/loan_repository.dart';

class CalculatorController extends GetxController {
  CalculatorController(this._repo);
  final LoanRepository _repo;

  static const purposes = [
    'Medical emergency',
    'Education',
    'Travel',
    'Home renovation',
    'Vehicle purchase or repair',
    'Gadget purchase',
    'Wedding',
    'Other',
  ];

  final status = ViewStatus.loading.obs;
  final eligibility = Rxn<Eligibility>();
  final principal = LoanConfig.minAmount.obs;
  final days = LoanConfig.defaultDays.obs;
  final purpose = RxnString();
  final purposeError = RxnString();
  final applying = false.obs;

  /// Live quote. Read inside an Obx so it reacts to principal/days.
  LoanQuote get quote => LoanQuote.compute(principal.value, days.value);

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /loans/eligibility
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final e = await _repo.fetchEligibility();
      eligibility.value = e;
      if (e.eligible) {
        _resetValues(e);
      }
      status.value = ViewStatus.ready;
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  void _resetValues(Eligibility e) {
    final mid = e.minAmount + ((e.maxAmount - e.minAmount) ~/ 2);
    principal.value = _snap(mid, e);
    days.value = LoanConfig.defaultDays;
  }

  int _snap(num v, Eligibility e) {
    final stepped = (v / LoanConfig.amountStep).round() * LoanConfig.amountStep;
    return stepped.clamp(e.minAmount, e.maxAmount).toInt();
  }

  void setPrincipal(double v) {
    final e = eligibility.value;
    if (e == null) return;
    final p = _snap(v, e);
    if (p != principal.value) {
      HapticFeedback.selectionClick();
      principal.value = p;
    }
  }

  void setDays(double v) {
    final d = v.round().clamp(LoanConfig.minDays, LoanConfig.maxDays).toInt();
    if (d != days.value) {
      HapticFeedback.selectionClick();
      days.value = d;
    }
  }

  void setPurpose(String v) {
    purpose.value = v;
    purposeError.value = null;
  }

  /// POST /loans/apply -> Offer
  Future<void> apply() async {
    if (applying.value) return;
    if (purpose.value == null) {
      HapticFeedback.mediumImpact();
      purposeError.value = 'Select purpose of loan';
      return;
    }
    applying.value = true;
    try {
      final loan = await _repo.apply(
        amount: principal.value,
        days: days.value,
        purpose: purpose.value!,
      );
      Get.toNamed(Routes.offer, arguments: {'loanId': loan.id});
    } on LoanException catch (e) {
      _snack('Could not apply', e.message);
    } catch (_) {
      _snack('Could not apply', 'Please check your connection and try again');
    } finally {
      applying.value = false;
    }
  }

  /// Cancel = go back if there is a previous screen, otherwise reset the form.
  void cancel() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    final e = eligibility.value;
    if (e != null && e.eligible) _resetValues(e);
    purpose.value = null;
    purposeError.value = null;
  }

  void viewActiveLoan() {
    final id = eligibility.value?.activeLoanId;
    if (id != null) Get.toNamed(Routes.status, arguments: {'loanId': id});
  }

  void _snack(String title, String message) => Get.snackbar(title, message,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
}
