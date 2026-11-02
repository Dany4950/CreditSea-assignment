import 'package:creditsea/modules/loan/models/loan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_ui.dart';

/// Bottom sheet to pick a (mock) payment method and confirm the repayment.
void showRepaySheet(Loan loan, {required void Function(String method) onPay}) {
  Get.bottomSheet<void>(
    _RepaySheet(loan: loan, onPay: onPay),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(ProfileUi.sheetRadius)),
    ),
  );
}

class _RepaySheet extends StatefulWidget {
  const _RepaySheet({required this.loan, required this.onPay});
  final Loan loan;
  final void Function(String method) onPay;

  @override
  State<_RepaySheet> createState() => _RepaySheetState();
}

class _RepaySheetState extends State<_RepaySheet> {
  static const _methods = [
    ('UPI', 'UPI', Icons.qr_code_2_rounded),
    ('CARD', 'Debit / Credit card', Icons.credit_card_rounded),
    ('NETBANKING', 'Net banking', Icons.account_balance_rounded),
  ];

  String _method = 'UPI';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ProfileUi.pad, 12, ProfileUi.pad, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: ProfileUi.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Repay your loan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
            const SizedBox(height: 4),
            Text('#${widget.loan.applicationNo}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ProfileUi.muted)),
            const SizedBox(height: 16),
            Text(ProfileUi.inr(widget.loan.totalPayable),
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: ProfileUi.ink)),
            const SizedBox(height: 4),
            Text(
              'Repay on or before ${ProfileUi.date(widget.loan.dueDate)} to improve your credit score.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.muted),
            ),
            const SizedBox(height: 20),
            const Text('Pay using',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ProfileUi.ink)),
            const SizedBox(height: 8),
            for (final (value, label, icon) in _methods) ...[
              _MethodTile(
                label: label,
                icon: icon,
                selected: _method == value,
                onTap: () => setState(() => _method = value),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            const Text(
              'Demo payment: no real money is charged.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ProfileUi.muted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Get.back<void>();
                widget.onPay(_method);
              },
              child: Text('Pay ${ProfileUi.inr(widget.loan.totalPayable)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ProfileUi.tint : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ProfileUi.radius),
        side: BorderSide(color: selected ? ProfileUi.action : ProfileUi.border, width: selected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: selected ? ProfileUi.action : ProfileUi.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ProfileUi.ink)),
              ),
              Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? ProfileUi.action : ProfileUi.border),
            ],
          ),
        ),
      ),
    );
  }
}
