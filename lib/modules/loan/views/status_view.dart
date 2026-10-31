import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../core/widgets/form/form_tokens.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_header.dart';
import '../../auth/widgets/auth_tokens.dart';
import '../controllers/status_controller.dart';
import '../models/loan.dart';
import '../widgets/status_stepper.dart';

class StatusView extends GetView<StatusController> {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return CardShell(
      header: const StepHeader(current: 2),
      title: 'Application Status',
      onBack: Navigator.canPop(context) ? () => Get.back() : null,
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 5),
      body: Obx(() {
        final loan = c.loan.value;
        if (loan == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: FormTokens.ink),
                children: [
                  const TextSpan(text: 'Loan application no. '),
                  TextSpan(
                      text: '#${loan.applicationNo}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            StatusStepper(loan: loan),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(key: ValueKey(loan.status), child: _InfoBlock(loan: loan)),
            ),
          ],
        );
      }),
      footer: Obx(() {
        final l = c.loan.value;
        final label = switch (l?.status) {
          LoanStatus.rejected => 'Apply again',
          LoanStatus.disbursed => 'Back to Home',
          _ => 'Continue',
        };
        return PrimaryButton(
          label: label,
          height: 48,
          loading: c.refreshing.value,
          onPressed: c.onContinue,
        );
      }),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.loan});
  final Loan loan;

  (IconData, String, String, Color) get _info => switch (loan.status) {
        LoanStatus.submitted || LoanStatus.underReview || LoanStatus.offered => (
            Icons.find_in_page_outlined,
            'Application Under Review',
            "We're carefully reviewing your application to ensure everything is in order. Thank you for your patience.",
            AuthTokens.actionBlue,
          ),
        LoanStatus.kyc => (
            Icons.verified_user_outlined,
            'E-KYC Verification',
            'Your application is approved. We are verifying your identity electronically.',
            AuthTokens.actionBlue,
          ),
        LoanStatus.nach => (
            Icons.account_balance_outlined,
            'E-Nach Registration',
            'Setting up the auto-debit mandate for your repayment date.',
            AuthTokens.actionBlue,
          ),
        LoanStatus.sign => (
            Icons.draw_outlined,
            'E-Sign Agreement',
            'Your loan agreement is ready. Please wait while we complete the digital signature.',
            AuthTokens.actionBlue,
          ),
        LoanStatus.disbursing => (
            Icons.payments_outlined,
            'Disbursement in Progress',
            'Your loan amount is on its way to your bank account.',
            AuthTokens.actionBlue,
          ),
        LoanStatus.disbursed => (
            Icons.check_circle_outline_rounded,
            'Loan Disbursed',
            '${rs(loan.disbursed)} has been credited to your account. Total payable: ${rs(loan.totalPayable)}.',
            const Color(0xFF2E9E5B),
          ),
        LoanStatus.rejected => (
            Icons.cancel_outlined,
            'Application Rejected',
            loan.rejectionReason ?? 'We could not approve your application at this time.',
            AuthTokens.error,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, title, text, color) = _info;
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: FormTokens.ink)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}
