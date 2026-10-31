import 'loan_quote.dart';

class Eligibility {
  const Eligibility({
    required this.eligible,
    this.minAmount = LoanConfig.minAmount,
    this.maxAmount = 0,
    this.reason,
    this.activeLoanId,
  });

  final bool eligible;
  final int minAmount;
  final int maxAmount;
  final String? reason;
  final String? activeLoanId;
}
