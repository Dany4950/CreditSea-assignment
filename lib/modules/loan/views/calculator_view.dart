import 'package:creditsea/core/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../core/widgets/color_logo.dart';
import '../../../core/widgets/form/form_tokens.dart';
import '../../../core/widgets/form/labeled_field.dart';
import '../../../core/widgets/form/select_field.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/outline_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/widgets/auth_tokens.dart';
import '../controllers/calculator_controller.dart';
import '../models/loan_quote.dart';
import '../widgets/dashed_box.dart';
import '../widgets/loan_slider.dart';
import '../widgets/summary_box.dart';

class CalculatorView extends GetView<CalculatorController> {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return CardShell(
      header: const ColorLogo(),
      headerGap: 16,
      title: 'Apply for loan',
      // No arrow when this is the root (home) screen.
      onBack: Navigator.canPop(context) ? () => Get.back() : null,
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 3),
      body: Obx(() => (c.eligibility.value?.eligible ?? false)
          ? _EligibleBody(c: c)
          : _NotEligible(c: c)),
      footer: Obx(() {
        final ok = c.eligibility.value?.eligible ?? false;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'Apply',
              height: 48,
              loading: c.applying.value,
              onPressed: ok ? c.apply : null,
            ),
            const SizedBox(height: 14),
            OutlineButton(label: 'Cancel', height: 48, onPressed: c.cancel),
          ],
        );
      }),
    );
  }
}

class _EligibleBody extends StatelessWidget {
  const _EligibleBody({required this.c});
  final CalculatorController c;

  static const _labelStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FormTokens.ink);

  @override
  Widget build(BuildContext context) {
    final e = c.eligibility.value!;
    final min = e.minAmount.toDouble();
    final max = e.maxAmount.toDouble();
    final canSlide = max > min;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "We've calculated your loan eligibility. Select your preferred loan amount and tenure.",
          style: TextStyle(fontSize: 13.5, height: 1.3, color: FormTokens.ink),
        ),
        const SizedBox(height: 20),
        const RepaintBoundary(child: _RateChips()),
        const SizedBox(height: 22),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEF0F3)),
        const SizedBox(height: 24),
        LabeledField(
          label: 'Purpose of Loan*',
          error: c.purposeError,
          child: Obx(() => SelectField(
                hint: 'Select purpose of loan',
                value: c.purpose.value,
                hasError: c.purposeError.value != null,
                onTap: () async {
                  final v = await showOptionSheet(
                    title: 'Purpose of loan',
                    options: CalculatorController.purposes,
                    selected: c.purpose.value,
                  );
                  if (v != null) c.setPurpose(v);
                },
              )),
        ),
        const SizedBox(height: 28),
        _ValueRow(label: 'Principal Amount', value: Obx(() => _ValueText(inrSpaced(c.principal.value)))),
        const SizedBox(height: 10),
        Obx(() => LoanSlider(
              value: c.principal.value.toDouble(),
              min: min,
              max: max,
              divisions: canSlide ? ((max - min) / LoanConfig.amountStep).round() : null,
              onChanged: canSlide ? c.setPrincipal : null,
              semanticFormatter: (v) => inr(v.round()),
            )),
        const SizedBox(height: 30),
        _ValueRow(label: 'Tenure', value: Obx(() => _ValueText('${c.days.value} Days'))),
        const SizedBox(height: 10),
        Obx(() => LoanSlider(
              value: c.days.value.toDouble(),
              min: LoanConfig.minDays.toDouble(),
              max: LoanConfig.maxDays.toDouble(),
              divisions: LoanConfig.maxDays - LoanConfig.minDays,
              onChanged: c.setDays,
              semanticFormatter: (v) => '${v.round()} days',
            )),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${LoanConfig.minDays} Days', style: TextStyle(fontSize: 10.5, color: FormTokens.ink)),
            Text('${LoanConfig.maxDays} Days', style: TextStyle(fontSize: 10.5, color: FormTokens.ink)),
          ],
        ),
        const SizedBox(height: 36),
        Obx(() {
          final q = c.quote;
          return SummaryBox(rows: [
            ('Principle Amount', inr(q.principal)),
            ('Interest', inr(q.interest)),
            ('Total Payable', inr(q.totalPayable)),
          ]);
        }),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'Thank you for choosing CreditSea. Please accept to proceed with the loan details.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, height: 1.3, fontWeight: FontWeight.w500, color: Color(0xFF3B7FA6)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RateChips extends StatelessWidget {
  const _RateChips();

  Widget _chip(String text) => DashedBox(
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: FormTokens.ink)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: _chip('Interest Per Day  ${LoanConfig.interestPerDayPct}%')),
          const SizedBox(width: 12),
          Expanded(child: _chip('Processing Fee  ${LoanConfig.processingFeePct}%')),
        ],
      );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _EligibleBody._labelStyle),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: FormTokens.border),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100, minHeight: 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Center(widthFactor: 1, child: value),
              ),
            ),
          ),
        ],
      );
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 14, color: FormTokens.ink));
}

class _NotEligible extends StatelessWidget {
  const _NotEligible({required this.c});
  final CalculatorController c;

  @override
  Widget build(BuildContext context) {
    final e = c.eligibility.value;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, size: 48, color: AuthTokens.hint),
          const SizedBox(height: 16),
          const Text("You can't apply right now",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(e?.reason ?? 'You are not eligible for a loan at the moment.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AuthTokens.textMuted)),
          if (e?.activeLoanId != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: c.viewActiveLoan,
              child: const Text('View application status',
                  style: TextStyle(
                      color: AuthTokens.actionBlue, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        ],
      ),
    );
  }
}
