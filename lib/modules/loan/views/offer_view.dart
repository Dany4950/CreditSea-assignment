import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../core/widgets/form/form_tokens.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_header.dart';
import '../controllers/offer_controller.dart';
import '../models/loan.dart';
import '../widgets/coin_illustration.dart';

class OfferView extends GetView<OfferController> {
  const OfferView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return CardShell(
      header: const StepHeader(current: 1),
      expandBody: true,
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 0, hero: true),
      body: Obx(() {
        final loan = c.loan.value;
        if (loan == null) return const SizedBox.shrink();
        return Column(
          children: [
            const Spacer(flex: 2),
            const Text('Our Offerings',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: FormTokens.ink)),
            const Spacer(flex: 3),
            const CoinIllustration(),
            const Spacer(flex: 3),
            _OfferMessage(loan: loan),
            const Spacer(flex: 2),
          ],
        );
      }),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => PrimaryButton(
                label: 'Accept Offer',
                height: 48,
                loading: c.accepting.value,
                onPressed: c.accept,
              )),
          const SizedBox(height: 14),
          OutlineButton(label: 'Extend Offer', height: 48, onPressed: c.extend),
        ],
      ),
    );
  }
}

class _OfferMessage extends StatelessWidget {
  const _OfferMessage({required this.loan});
  final Loan loan;

  static const _base = TextStyle(fontSize: 14, height: 1.5, color: FormTokens.ink);
  static const _bold = TextStyle(fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(style: _base, children: [
            const TextSpan(
                text: 'Congratulations! ',
                style: TextStyle(color: Color(0xFF67C23A), fontWeight: FontWeight.w500)),
            const TextSpan(text: 'We can offer you '),
            TextSpan(text: rs(loan.principal), style: _bold),
            const TextSpan(text: ' Amount Within '),
            const TextSpan(text: '30 minutes', style: _bold),
            TextSpan(text: ' for ${loan.days} days, with a payable amount of '),
            TextSpan(text: rs(loan.totalPayable), style: _bold),
            const TextSpan(text: '. Just with few more steps.'),
          ]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        // Copy as in Figma.
        const Text('Proceed further to',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: FormTokens.ink)),
      ],
    );
  }
}
