import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/create_password_controller.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_sheet_title.dart';
import '../widgets/auth_tokens.dart';
import '../widgets/password_field.dart';

class CreatePasswordView extends GetView<CreatePasswordController> {
  const CreatePasswordView({super.key});

  @override
  Widget build(BuildContext context) =>
      AuthShell(page: 2, child: AutofillGroup(child: _Form(c: controller)));
}

class _Form extends StatelessWidget {
  const _Form({required this.c});
  final CreatePasswordController c;

  static const _label = TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthSheetTitle('Create a password', onBack: Get.back),
        const SizedBox(height: 12),
        const Text('Enter password', style: _label),
        const SizedBox(height: 8),
        Obx(() => PasswordField(
              controller: c.password,
              focusNode: c.passFocus,
              hint: 'Enter password',
              obscure: c.obscurePass,
              hasError: c.ruleError.value,
            )),
        const SizedBox(height: 18),
        const Text('Re enter password', style: _label),
        const SizedBox(height: 8),
        Obx(() => PasswordField(
              controller: c.confirm,
              focusNode: c.confirmFocus,
              hint: 'Re enter password',
              obscure: c.obscureConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: c.submit,
              hasError: c.confirmError.value != null,
            )),
        Obx(() {
          final e = c.confirmError.value;
          return e == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(e, style: const TextStyle(color: AuthTokens.error, fontSize: 12)),
                );
        }),
        const SizedBox(height: 14),
        Obx(() => Text(
              '*your password must include at least 8 characters, '
              'inclusive of at least 1 special character',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: c.ruleError.value ? AuthTokens.error : AuthTokens.hint,
              ),
            )),
        const SizedBox(height: 22),
        Obx(() => PrimaryButton(
              label: 'Proceed',
              loading: c.loading.value,
              onPressed: c.submit,
            )),
      ],
    );
  }
}
