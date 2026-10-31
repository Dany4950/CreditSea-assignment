import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/sign_in_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_sheet_title.dart';
import '../widgets/auth_tokens.dart';
import '../widgets/password_field.dart';
import '../widgets/phone_field.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) =>
      AuthShell(page: 2, child: AutofillGroup(child: _Form(c: controller)));
}

class _Form extends StatelessWidget {
  const _Form({required this.c});
  final SignInController c;

  static const _label = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthSheetTitle('Please enter your credentials'),
        const SizedBox(height: 12),
        const Text('Mobile Number', style: _label),
        const SizedBox(height: 8),
        PhoneField(controller: c.mobile, onSubmitted: c.passFocus.requestFocus),
        const SizedBox(height: 18),
        const Text('Enter password', style: _label),
        const SizedBox(height: 8),
        Obx(() => PasswordField(
              controller: c.password,
              focusNode: c.passFocus,
              hint: 'Enter password',
              obscure: c.obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: c.submit,
              hasError: c.error.value != null,
              autofillHint: AutofillHints.password,
            )),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final e = c.error.value;
                return e == null
                    ? const SizedBox.shrink()
                    : Text(e, style: const TextStyle(color: AuthTokens.error, fontSize: 12));
              }),
            ),
            TextButton(
              onPressed: c.forgotPassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              // Figma label reads "Enter password" (likely a typo for this).
              child: const Text('Forgot password?',
                  style: TextStyle(
                      color: AuthTokens.actionBlue, fontSize: 13.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() => PrimaryButton(
              label: 'Sign In',
              loading: c.loading.value,
              onPressed: c.canSubmit.value ? c.submit : null,
            )),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: c.goToCreateAccount,
            child: const Text('New to CreditSea? Create an account',
                style: TextStyle(
                    color: AuthTokens.primaryDark, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
