import '../../../../core/network/api_models.dart';

/// Loan JSON exactly as the server sends it. `status` stays a String here;
/// the repository adapter maps it to your domain `LoanStatus`.
class LoanDto {
  const LoanDto({
    required this.id,
    required this.applicationNo,
    required this.principal,
    required this.days,
    required this.purpose,
    required this.interest,
    required this.processingFee,
    required this.totalPayable,
    required this.disbursedAmount,
    required this.status,
    this.statusLabel = '',
    this.rejectionReason,
    this.createdAt,
    this.dueDate,
    this.repaidAt,
    this.scoreChange,
    this.isOverdue = false,
  });

  final String id;
  final String applicationNo;
  final int principal;
  final int days;
  final String purpose;
  final int interest;
  final int processingFee;
  final int totalPayable;
  final int disbursedAmount;
  final String status; // OFFERED | SUBMITTED | UNDER_REVIEW | KYC | NACH | SIGN | DISBURSING | DISBURSED | REJECTED | REPAID
  final String statusLabel; // Submitted | Under Review | Approved | Rejected | Disbursed | Repaid
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final DateTime? repaidAt;
  final int? scoreChange;
  final bool isOverdue;

  factory LoanDto.fromJson(Map<String, dynamic> j) => LoanDto(
        id: j['id'] as String,
        applicationNo: j['applicationNo'] as String? ?? '',
        principal: asInt(j['principal']),
        days: asInt(j['days']),
        purpose: j['purpose'] as String? ?? '',
        interest: asInt(j['interest']),
        processingFee: asInt(j['processingFee']),
        totalPayable: asInt(j['totalPayable']),
        disbursedAmount: asInt(j['disbursedAmount']),
        status: j['status'] as String? ?? '',
        statusLabel: j['statusLabel'] as String? ?? '',
        rejectionReason: asStringOrNull(j['rejectionReason']),
        createdAt: asDate(j['createdAt']),
        dueDate: asDate(j['dueDate']),
        repaidAt: asDate(j['repaidAt']),
        scoreChange: j['scoreChange'] is num ? (j['scoreChange'] as num).toInt() : null,
        isOverdue: j['isOverdue'] == true,
      );
}
