import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../api/dto/loan_dto.dart';
import '../api/dto/loan_requests.dart';
import '../api/loan_api.dart';
import '../models/eligibility.dart';
import '../models/loan.dart';
import 'loan_repository.dart';

/// Real LoanRepository: talks to the Render backend through [LoanApi] and
/// maps server DTOs onto the app's own Loan / Eligibility models.
class ApiLoanRepository implements LoanRepository {
  ApiLoanRepository(this._api);
  final LoanApi _api;

  @override
  Future<Eligibility> fetchEligibility() => _guard(() async {
        final d = await _api.eligibility();
        return Eligibility(
          eligible: d.eligible,
          minAmount: d.minAmount,
          maxAmount: d.maxAmount,
          reason: d.message ?? d.reason, // the UI shows readable text
          activeLoanId: d.activeLoanId,
        );
      });

  @override
  Future<Loan> apply({required int amount, required int days, required String purpose}) => _guard(() async =>
      _toLoan(await _api.apply(ApplyLoanRequest(amount: amount, days: days, purpose: purpose))));

  @override
  Future<Loan> fetchLoan(String id) => _guard(() async => _toLoan(await _api.detail(id)));

  @override
  Future<Loan> acceptOffer(String id) => _guard(() async => _toLoan(await _api.accept(id)));

  Loan _toLoan(LoanDto d) => Loan(
        id: d.id,
        applicationNo: d.applicationNo,
        principal: d.principal,
        days: d.days,
        purpose: d.purpose,
        interest: d.interest,
        processingFee: d.processingFee,
        status: _status(d.status),
        rejectionReason: d.rejectionReason,
      );

  LoanStatus _status(String s) => switch (s) {
        'OFFERED' => LoanStatus.offered,
        'SUBMITTED' => LoanStatus.submitted,
        'UNDER_REVIEW' => LoanStatus.underReview,
        'KYC' => LoanStatus.kyc,
        'NACH' => LoanStatus.nach,
        'SIGN' => LoanStatus.sign,
        'DISBURSING' => LoanStatus.disbursing,
        'DISBURSED' => LoanStatus.disbursed,
        'REJECTED' => LoanStatus.rejected,
        _ => LoanStatus.submitted, // unknown future status: show as in progress rather than crash
      };

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw LoanException(e.message);
    }
  }
}

void registerApiLoanRepository() =>
    Get.put<LoanRepository>(ApiLoanRepository(Get.find<LoanApi>()), permanent: true);
