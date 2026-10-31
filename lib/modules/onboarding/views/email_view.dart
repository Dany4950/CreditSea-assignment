import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/widgets/auth_tokens.dart';
import '../controllers/email_controller.dart';
import '../widgets/illustrations.dart';
import '../widgets/labeled_field.dart';
import '../widgets/onboarding_input.dart';
import '../widgets/onboarding_shell.dart';

class EmailView extends GetView<EmailController> {
  const EmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return OnboardingShell(
      step: 0,
      title: 'Personal Email ID',
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 2, hero: true),
      onBack: Navigator.canPop(context) ? () => Get.back() : null,
      body: _Body(c: c),
      footer: Obx(() => PrimaryButton(
            label: 'Verify',
            height: 48,
            loading: c.verifying.value,
            onPressed: c.canVerify.value ? c.verify : null,
          )),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c});
  final EmailController c;

  static const _helper = TextStyle(fontSize: 13, color: OnboardingTokens.ink);
  static final _emailFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(100),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: RepaintBoundary(child: EmailIllustration())),
        const SizedBox(height: 20),
        LabeledField(
          label: 'Email ID*',
          error: c.emailError,
          child: OnboardingTextField(
            controller: c.email,
            focusNode: c.emailFocus,
            hint: 'Enter your email ID',
            error: c.emailError,
            keyboardType: TextInputType.emailAddress,
            capitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            inputFormatters: _emailFormatters,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => c.sendOtp(),
          ),
        ),
        const SizedBox(height: 24),
        LabeledField(
          label: 'OTP Verification',
          error: c.otpError,
          child: _OtpBoxes(c: c),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Didn't receive it? ", style: _helper),
            Obx(() {
              final enabled = c.secondsLeft.value == 0 && !c.sending.value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? () => c.sendOtp(manual: true) : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: enabled ? 1 : 0.45,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Resend Code',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AuthTokens.actionBlue)),
                  ),
                ),
              );
            }),
            const Spacer(),
            Obx(() => Text(c.timerLabel,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OnboardingTokens.ink))),
          ],
        ),
      ],
    );
  }
}

/// 6 boxes that stretch to the available width (Figma: ~52 x 46, 6dp gap).
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.c});
  final EmailController c;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      const gap = 6.0;
      final boxW = (box.maxWidth - gap * (EmailController.otpLength - 1)) /
          EmailController.otpLength;

      PinTheme theme(Color border,
              {double borderWidth = 1, Color fill = Colors.white}) =>
          PinTheme(
            width: boxW,
            height: 46,
            textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: OnboardingTokens.ink),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: borderWidth),
            ),
          );

      return Obx(() => Pinput(
            length: EmailController.otpLength,
            controller: c.otp,
            focusNode: c.otpFocus,
            enabled: c.otpSent.value,
            keyboardType: TextInputType.number,
            mainAxisAlignment: MainAxisAlignment.start,
            separatorBuilder: (_) => const SizedBox(width: gap),
            defaultPinTheme: theme(OnboardingTokens.border),
            focusedPinTheme: theme(AuthTokens.actionBlue, borderWidth: 1.5),
            errorPinTheme: theme(AuthTokens.error, borderWidth: 1.5),
            disabledPinTheme: theme(OnboardingTokens.border,
                fill: OnboardingTokens.background),
            forceErrorState: c.otpError.value != null,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onCompleted: (_) => c.verify(),
          ));
    });
  }
}
