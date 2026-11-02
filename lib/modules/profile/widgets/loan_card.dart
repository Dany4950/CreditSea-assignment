import 'package:creditsea/modules/loan/models/loan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_ui.dart';

/// One loan in "Your loans". Tap = open its status. Disbursed loans show a "Repay" button.
class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.repayingId,
    required this.onTap,
    required this.onRepay,
  });

  final Loan loan;
  final RxnString repayingId; // the card's button listens to this, nothing else rebuilds
  final VoidCallback onTap;
  final VoidCallback onRepay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileUi.radius),
        side: const BorderSide(color: ProfileUi.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#${loan.applicationNo}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
                  const Spacer(),
                  _StatusChip(loan: loan),
                ],
              ),
              const SizedBox(height: 12),
              Text(ProfileUi.inr(loan.principal),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
              const SizedBox(height: 2),
              Text(
                '${loan.days} days  ·  ${loan.purpose}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.muted),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: ProfileUi.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Metric(label: 'Total payable', value: ProfileUi.inr(loan.totalPayable))),
                  Expanded(child: _secondMetric()),
                ],
              ),
              ..._footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondMetric() {
    switch (loan.status) {
      case LoanStatus.disbursed:
        return _Metric(
          label: loan.isOverdue ? 'Overdue since' : 'Due date',
          value: ProfileUi.date(loan.dueDate),
          valueColor: loan.isOverdue ? ProfileUi.error : ProfileUi.ink,
        );
      case LoanStatus.repaid:
        return _Metric(label: 'Repaid on', value: ProfileUi.date(loan.repaidAt));
      default:
        return _Metric(label: 'Applied on', value: ProfileUi.date(loan.createdAt));
    }
  }

  List<Widget> _footer() {
    switch (loan.status) {
      case LoanStatus.disbursed:
        return [
          const SizedBox(height: 14),
          Obx(() {
            final busy = repayingId.value == loan.id;
            return SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: repayingId.value != null ? null : onRepay,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Repay ${ProfileUi.inr(loan.totalPayable)}'),
              ),
            );
          }),
        ];
      case LoanStatus.rejected:
        final reason = loan.rejectionReason;
        if (reason == null || reason.isEmpty) return const [];
        return [
          const SizedBox(height: 12),
          Text(reason, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.error)),
        ];
      case LoanStatus.repaid:
        final change = loan.scoreChange;
        if (change == null) return const [];
        final up = change >= 0;
        return [
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 18, color: up ? ProfileUi.success : ProfileUi.error),
              const SizedBox(width: 6),
              Text(
                'Credit score ${up ? '+' : ''}$change',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: up ? ProfileUi.success : ProfileUi.error),
              ),
            ],
          ),
        ];
      default:
        return const [];
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.valueColor = ProfileUi.ink});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.muted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.loan});
  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (loan.status) {
      LoanStatus.offered || LoanStatus.submitted || LoanStatus.underReview => (ProfileUi.tint, ProfileUi.action),
      LoanStatus.kyc || LoanStatus.nach || LoanStatus.sign || LoanStatus.disbursing => (
          const Color(0xFFEEF0FF),
          const Color(0xFF4F46E5)
        ),
      LoanStatus.disbursed => (const Color(0xFFE7F5EE), ProfileUi.success),
      LoanStatus.rejected => (const Color(0xFFFDECEA), ProfileUi.error),
      LoanStatus.repaid => (const Color(0xFFF2F4F7), const Color(0xFF475467)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(loan.statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
