import 'loan_quote.dart';

enum LoanStatus { offered, submitted, underReview, kyc, nach, sign, disbursing, disbursed, rejected, repaid }

enum StepState { done, current, pending, error }

class Loan {
  const Loan({
    required this.id,
    required this.applicationNo,
    required this.principal,
    required this.days,
    required this.purpose,
    required this.interest,
    required this.processingFee,
    required this.status,
    this.rejectionReason,
    this.createdAt,
    this.dueDate,
    this.repaidAt,
    this.scoreChange,
    this.isOverdue = false,
  });

  final String id;
  final String applicationNo; // e.g. CS12323
  final int principal;
  final int days;
  final String purpose;
  final int interest;
  final int processingFee;
  final LoanStatus status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final DateTime? repaidAt;

  /// Credit score change caused by repaying this loan (+50 on time, -30 late).
  final int? scoreChange;
  final bool isOverdue;

  int get totalPayable => principal + interest;
  int get disbursed => principal - processingFee;

  /// The brief's chain: Submitted -> Under Review -> Approved/Rejected -> Disbursed (+ Repaid).
  String get statusLabel => switch (status) {
        LoanStatus.offered => 'Offered',
        LoanStatus.submitted => 'Submitted',
        LoanStatus.underReview => 'Under Review',
        LoanStatus.kyc || LoanStatus.nach || LoanStatus.sign || LoanStatus.disbursing => 'Approved',
        LoanStatus.disbursed => 'Disbursed',
        LoanStatus.rejected => 'Rejected',
        LoanStatus.repaid => 'Repaid',
      };

  static const stepLabels = [
    'Application Submitted',
    'Application under Review',
    'E-KYC',
    'E-Nach',
    'E-Sign',
    'Disbursement',
  ];

  Loan copyWith({LoanStatus? status, String? rejectionReason}) => Loan(
        id: id,
        applicationNo: applicationNo,
        principal: principal,
        days: days,
        purpose: purpose,
        interest: interest,
        processingFee: processingFee,
        status: status ?? this.status,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        createdAt: createdAt,
        dueDate: dueDate,
        repaidAt: repaidAt,
        scoreChange: scoreChange,
        isOverdue: isOverdue,
      );

  factory Loan.fromQuote({
    required String id,
    required String applicationNo,
    required LoanQuote quote,
    required String purpose,
    LoanStatus status = LoanStatus.offered,
  }) =>
      Loan(
        id: id,
        applicationNo: applicationNo,
        principal: quote.principal,
        days: quote.days,
        purpose: purpose,
        interest: quote.interest,
        processingFee: quote.processingFee,
        status: status,
        createdAt: DateTime.now(),
      );

  /// Index of the step in progress (6 = everything done).
  int get currentStep => switch (status) {
        LoanStatus.offered => 0,
        LoanStatus.submitted => 1,
        LoanStatus.underReview => 1,
        LoanStatus.kyc => 2,
        LoanStatus.nach => 3,
        LoanStatus.sign => 4,
        LoanStatus.disbursing => 5,
        LoanStatus.disbursed => 6,
        LoanStatus.rejected => 1,
        LoanStatus.repaid => 6,
      };

  StepState stepState(int i) {
    if (status == LoanStatus.rejected) {
      return i == 0 ? StepState.done : (i == 1 ? StepState.error : StepState.pending);
    }
    if (i < currentStep) return StepState.done;
    if (i == currentStep) return StepState.current;
    return StepState.pending;
  }

  /// The status screen stops polling here.
  bool get isTerminal =>
      status == LoanStatus.disbursed || status == LoanStatus.rejected || status == LoanStatus.repaid;
}
