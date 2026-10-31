import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/otp_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_sheet_title.dart';
import '../widgets/auth_tokens.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) => AuthShell(page: 1, child: _OtpForm(c: controller));
}

class _OtpForm extends StatelessWidget {
  const _OtpForm({required this.c});
  final OtpController c;

  static const _boxRadius = BorderRadius.all(Radius.circular(8));
  static const _textStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  static final _idle = PinTheme(
    width: 50,
    height: 50,
    textStyle: _textStyle,
    decoration: const BoxDecoration(
      borderRadius: _boxRadius,
      border: Border.fromBorderSide(BorderSide(color: AuthTokens.border)),
    ),
  );
  static final _focused = _idle.copyDecorationWith(
    border: Border.all(color: AuthTokens.actionBlue, width: 1.5),
  );
  static final _errored = _idle.copyDecorationWith(
    border: Border.all(color: AuthTokens.error, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthSheetTitle('Enter OTP', onBack: Get.back),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 15),
            children: [
              const TextSpan(text: 'Verify OTP, Sent on '),
              TextSpan(
                  text: c.displayMobile,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Pinput(
              length: OtpController.length,
              controller: c.otp,
              focusNode: c.focus,
              autofocus: true,
              keyboardType: TextInputType.number,
              mainAxisAlignment: MainAxisAlignment.start,
              separatorBuilder: (_) => const SizedBox(width: 25),
              defaultPinTheme: _idle,
              focusedPinTheme: _focused,
              errorPinTheme: _errored,
              forceErrorState: c.error.value != null,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (_) => c.verify(),
            )),
        Obx(() {
          final e = c.error.value;
          return e == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(e, style: const TextStyle(color: AuthTokens.error, fontSize: 12)),
                );
        }),
        const SizedBox(height: 20),
        SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Obx(() => c.secondsLeft.value > 0
                ? Text(c.timerLabel,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
                : TextButton(
                    onPressed: c.resend,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Resend OTP',
                        style: TextStyle(
                            color: AuthTokens.actionBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  )),
          ),
        ),
        const SizedBox(height: 22),
        Obx(() => PrimaryButton(
              label: 'Verify',
              loading: c.loading.value,
              onPressed: c.canVerify.value ? c.verify : null,
            )),
      ],
    );
  }
}
