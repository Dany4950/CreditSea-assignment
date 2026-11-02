import 'package:creditsea/modules/loan/models/loan_page.dart';
import 'package:creditsea/modules/loan/models/repay_result.dart';

import '../models/eligibility.dart';
import '../models/loan.dart';
import '../models/loan_quote.dart';

class LoanException implements Exception {
  const LoanException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Data contract for loans. Real implementation = ApiClient calls
/// (docs/PROGRESS.md section 5). Controllers never see dio.
abstract interface class LoanRepository {
  /// GET /loans/eligibility
  Future<Eligibility> fetchEligibility();

  /// POST /loans/apply -> loan in OFFERED state (replaces a pending offer)
  Future<Loan> apply({required int amount, required int days, required String purpose});

  /// GET /loans/:id
  Future<Loan> fetchLoan(String id);

  /// POST /loans/:id/accept -> SUBMITTED, status engine starts
  Future<Loan> acceptOffer(String id);

  /// GET /loans?page&limit -> My Loans (infinite scroll). Page 1 is cached; [refresh] bypasses the cache.
  Future<LoanPage> fetchLoans({int page = 1, int limit = 10, bool refresh = false});

  /// POST /loans/:id/repay (mock payment) -> loan becomes REPAID and the credit score changes
  Future<RepayResult> repay(String id, {String method = 'UPI'});
}

class _Record {
  _Record(this.loan);
  Loan loan;
  DateTime? acceptedAt;
  bool repaid = false;
}

class MockLoanRepository implements LoanRepository {
  static const _latency = Duration(milliseconds: 500);
  static const _maxAmount = 50000;

  static final Map<String, _Record> _db = {};
  static int _seq = 12322;

  Future<void> _wait() => Future<void>.delayed(_latency);

  /// Status by elapsed seconds since accept (mimics the backend status engine).
  Loan _resolve(_Record r) {
    if (r.repaid) return r.loan.copyWith(status: LoanStatus.repaid);
    final at = r.acceptedAt;
    if (at == null) return r.loan;
    final s = DateTime.now().difference(at).inSeconds;
    final rejected = r.loan.principal == LoanConfig.minAmount; // demo rule
    final LoanStatus st;
    if (s < 4) {
      st = LoanStatus.submitted;
    } else if (s < 10) {
      st = LoanStatus.underReview;
    } else if (rejected) {
      return r.loan.copyWith(
        status: LoanStatus.rejected,
        rejectionReason: 'We could not approve this amount based on your profile.',
      );
    } else if (s < 16) {
      st = LoanStatus.kyc;
    } else if (s < 22) {
      st = LoanStatus.nach;
    } else if (s < 28) {
      st = LoanStatus.sign;
    } else if (s < 34) {
      st = LoanStatus.disbursing;
    } else {
      st = LoanStatus.disbursed;
    }
    return r.loan.copyWith(status: st);
  }

  @override
  Future<Eligibility> fetchEligibility() async {
    await _wait();
    for (final r in _db.values) {
      if (r.acceptedAt != null && !_resolve(r).isTerminal) {
        return Eligibility(
          eligible: false,
          reason: 'You already have an active loan application.',
          activeLoanId: r.loan.id,
        );
      }
    }
    return const Eligibility(eligible: true, maxAmount: _maxAmount);
  }

  @override
  Future<Loan> apply({required int amount, required int days, required String purpose}) async {
    await _wait();
    if (amount > _maxAmount) throw const LoanException('Amount is above your eligible limit.');
    _db.removeWhere((_, r) => r.acceptedAt == null); // replace pending offer
    _seq++;
    final loan = Loan.fromQuote(
      id: 'loan_$_seq',
      applicationNo: 'CS$_seq',
      quote: LoanQuote.compute(amount, days),
      purpose: purpose,
    );
    _db[loan.id] = _Record(loan);
    return loan;
  }

  @override
  Future<Loan> fetchLoan(String id) async {
    await _wait();
    final r = _db[id];
    if (r == null) throw const LoanException('Loan not found');
    return _resolve(r);
  }

  @override
  Future<Loan> acceptOffer(String id) async {
    await _wait();
    final r = _db[id];
    if (r == null) throw const LoanException('Loan not found');
    r.acceptedAt ??= DateTime.now();
    return _resolve(r);
  }

  @override
  Future<LoanPage> fetchLoans({int page = 1, int limit = 10, bool refresh = false}) async {
    await _wait();
    final all = _db.values.where((r) => r.acceptedAt != null).map(_resolve).toList().reversed.toList();
    final start = (page - 1) * limit;
    final end = start + limit > all.length ? all.length : start + limit;
    final items = start >= all.length ? <Loan>[] : all.sublist(start, end);
    return LoanPage(items: items, page: page, hasMore: end < all.length, total: all.length);
  }

  @override
  Future<RepayResult> repay(String id, {String method = 'UPI'}) async {
    await _wait();
    final r = _db[id];
    if (r == null) throw const LoanException('Loan not found');
    if (_resolve(r).status != LoanStatus.disbursed) {
      throw const LoanException('Only a disbursed loan can be repaid.');
    }
    r.repaid = true;
    return RepayResult(loan: _resolve(r), creditScore: 650, scoreChange: 50, onTime: true);
  }
}
