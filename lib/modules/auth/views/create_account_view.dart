import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/create_account_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_sheet_title.dart';
import '../widgets/auth_tokens.dart';
import '../widgets/phone_field.dart';

class CreateAccountView extends GetView<CreateAccountController> {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) =>
      AuthShell(pager: controller.pager, child: _Form(c: controller));
}

class _Form extends StatelessWidget {
  const _Form({required this.c});
  final CreateAccountController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSheetTitle('Welcome to Credit Sea!',
            fontSize: 20, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        const Text('Mobile Number',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        PhoneField(controller: c.mobile, onSubmitted: c.requestOtp),
        Obx(() {
          final e = c.error.value;
          return e == null
              ? const SizedBox(height: 20)
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(e,
                      style: const TextStyle(
                          color: AuthTokens.error, fontSize: 12)),
                );
        }),
        _TermsRow(c: c),
        const SizedBox(height: 20),
        Obx(() => PrimaryButton(
              label: 'Request OTP',
              loading: c.loading.value,
              onPressed: c.canSubmit.value ? c.requestOtp : null,
            )),
        const SizedBox(height: 28),
        Center(
          child: TextButton(
            onPressed: c.goToSignIn,
            child: const Text('Existing User? Sign in',
                style: TextStyle(
                    color: AuthTokens.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.c});
  final CreateAccountController c;

  static const _base =
      TextStyle(fontSize: 12, color: AuthTokens.textMuted, height: 1.5);
  static const _link = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AuthTokens.textMuted,
      decoration: TextDecoration.underline,
      height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: c.toggleAgreed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 2, bottom: 2),
            child: Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: c.agreed.value ? AuthTokens.success : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: c.agreed.value
                            ? AuthTokens.success
                            : AuthTokens.border,
                        width: 1.5),
                  ),
                  child: c.agreed.value
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white)
                      : null,
                )),
          ),
        ),
        const Expanded(
          child: Text.rich(
            TextSpan(style: _base, children: [
              TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(text: 'privacy policies', style: _link),
              TextSpan(text: ' and '),
              TextSpan(text: 'Terms & Conditions.', style: _link),
            ]),
          ),
        ),
      ],
    );
  }
}
