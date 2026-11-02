import 'loan.dart';

/// Outcome of a (mock) repayment: the updated loan and the new credit score.
class RepayResult {
  const RepayResult({
    required this.loan,
    required this.creditScore,
    required this.scoreChange,
    required this.onTime,
  });

  final Loan loan;
  final int creditScore;
  final int scoreChange; // +50 on time, -30 late (server rule)
  final bool onTime;
}
