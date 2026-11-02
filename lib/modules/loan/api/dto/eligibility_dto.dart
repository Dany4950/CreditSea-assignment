import '../../../../core/network/api_models.dart';

/// `reason` values returned when `eligible == false`.
abstract class EligibilityReason {
  static const activeLoanExists = 'ACTIVE_LOAN_EXISTS';
  static const scoreTooLow = 'SCORE_TOO_LOW';
  static const ageNotEligible = 'AGE_NOT_ELIGIBLE';
  static const profileIncomplete = 'PROFILE_INCOMPLETE';
}

/// GET /loans/eligibility
class EligibilityDto {
  const EligibilityDto({
    required this.eligible,
    required this.minAmount,
    required this.maxAmount,
    required this.amountStep,
    required this.minDays,
    required this.maxDays,
    required this.interestPerDayPercent,
    required this.processingFeePercent,
    this.reason,
    this.message,
    this.activeLoanId,
    this.purposes = const [],
    this.creditScore,
  });

  final bool eligible;
  final int minAmount;
  final int maxAmount;
  final int amountStep;
  final int minDays;
  final int maxDays;
  final int interestPerDayPercent;
  final int processingFeePercent;
  final String? reason; // machine code, see EligibilityReason
  final String? message; // human text
  final String? activeLoanId;
  final List<String> purposes;
  final int? creditScore;

  factory EligibilityDto.fromJson(Map<String, dynamic> j) => EligibilityDto(
        eligible: j['eligible'] == true,
        minAmount: asInt(j['minAmount'], 5000),
        maxAmount: asInt(j['maxAmount']),
        amountStep: asInt(j['amountStep'], 1000),
        minDays: asInt(j['minDays'], 20),
        maxDays: asInt(j['maxDays'], 45),
        interestPerDayPercent: asInt(j['interestPerDayPercent'], 1),
        processingFeePercent: asInt(j['processingFeePercent'], 10),
        reason: asStringOrNull(j['reason']),
        message: asStringOrNull(j['message']),
        activeLoanId: asStringOrNull(j['activeLoanId']),
        purposes: ((j['purposes'] as List?) ?? const []).whereType<String>().toList(growable: false),
        creditScore: j['creditScore'] is num ? (j['creditScore'] as num).toInt() : null,
      );
}
