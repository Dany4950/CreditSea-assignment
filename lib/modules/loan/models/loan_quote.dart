/// Product constants. Server enforces the same numbers.
abstract final class LoanConfig {
  static const interestPerDayPct = 1;
  static const processingFeePct = 10;
  static const minDays = 20;
  static const maxDays = 45;
  static const defaultDays = 30;
  static const minAmount = 5000;
  static const amountStep = 1000;
}

/// Pure, deterministic loan maths (integers only).
/// Display-only on the client; the backend recomputes on apply.
class LoanQuote {
  const LoanQuote({
    required this.principal,
    required this.days,
    required this.interest,
    required this.processingFee,
  });

  final int principal;
  final int days;
  final int interest;
  final int processingFee;

  int get totalPayable => principal + interest;
  int get disbursed => principal - processingFee;

  factory LoanQuote.compute(int principal, int days) => LoanQuote(
        principal: principal,
        days: days,
        interest: principal * LoanConfig.interestPerDayPct * days ~/ 100,
        processingFee: principal * LoanConfig.processingFeePct ~/ 100,
      );
}
