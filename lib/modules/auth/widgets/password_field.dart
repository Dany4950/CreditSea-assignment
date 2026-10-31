import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_input.dart';
import 'auth_tokens.dart';

/// Password input with eye toggle. Toggling rebuilds only this field.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.obscure,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.hasError = false,
    this.autofillHint = AutofillHints.newPassword,
  });

  final TextEditingController controller;
  final String hint;
  final RxBool obscure;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool hasError;
  final String autofillHint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthTokens.fieldHeight,
      child: Obx(() {
        final hidden = obscure.value;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: hidden,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: textInputAction,
          textAlignVertical: TextAlignVertical.center,
          autofillHints: [autofillHint],
          onSubmitted: (_) => onSubmitted?.call(),
          style: const TextStyle(fontSize: 16),
          decoration: authInputDecoration(
            hint: hint,
            error: hasError,
            suffix: IconButton(
              tooltip: hidden ? 'Show password' : 'Hide password',
              onPressed: obscure.toggle,
              icon: Icon(
                hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 22,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }),
    );
  }
}
