import '../../../../core/network/api_models.dart';

/// POST /loans/apply. The server recomputes pricing; the client's numbers are display-only.
class ApplyLoanRequest {
  const ApplyLoanRequest({required this.amount, required this.days, required this.purpose});
  final int amount;
  final int days;
  final String purpose;
  Map<String, dynamic> toJson() => {'amount': amount, 'days': days, 'purpose': purpose};
}

/// POST /loans/quote (optional: the calculator already computes locally with the same formula).
class QuoteRequest {
  const QuoteRequest({required this.amount, required this.days});
  final int amount;
  final int days;
  Map<String, dynamic> toJson() => {'amount': amount, 'days': days};
}

class LoanQuoteDto {
  const LoanQuoteDto({
    required this.principal,
    required this.days,
    required this.interest,
    required this.processingFee,
    required this.totalPayable,
    required this.disbursed,
  });

  final int principal;
  final int days;
  final int interest;
  final int processingFee;
  final int totalPayable;
  final int disbursed;

  factory LoanQuoteDto.fromJson(Map<String, dynamic> j) => LoanQuoteDto(
        principal: asInt(j['principal']),
        days: asInt(j['days']),
        interest: asInt(j['interest']),
        processingFee: asInt(j['processingFee']),
        totalPayable: asInt(j['totalPayable']),
        disbursed: asInt(j['disbursed']),
      );
}
