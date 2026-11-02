import 'dart:async';
import 'package:creditsea/modules/profile/profile_pages.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';

class StatusController extends GetxController {
  StatusController(this._repo);
  final LoanRepository _repo;

  static const _pollEvery = Duration(seconds: 4);

  late final String loanId;
  final status = ViewStatus.loading.obs;
  final loan = Rxn<Loan>();
  final refreshing = false.obs;

  Timer? _poll;
  bool _inFlight = false;

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

  /// GET /loans/:id, then poll until the loan reaches a terminal state.
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final l = await _repo.fetchLoan(loanId);
      loan.value = l;
      status.value = ViewStatus.ready;
      if (!l.isTerminal) _startPolling();
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(_pollEvery, (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    if (!silent) refreshing.value = true;
    try {
      final next = await _repo.fetchLoan(loanId);
      // Only notify the UI when the status really changed.
      if (next.status != loan.value?.status) loan.value = next;
      if (next.isTerminal) _poll?.cancel();
    } catch (_) {
      // keep the last known state; the next poll retries
    } finally {
      _inFlight = false;
      refreshing.value = false;
    }
  }

  /// In progress: refresh now. Finished (disbursed/rejected/repaid): open the Profile
  /// (details + all loans + "New loan" button), clearing the stack so Back never returns here.
  void onContinue() {

  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}
