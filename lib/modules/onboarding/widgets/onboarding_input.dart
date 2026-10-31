import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form/form_tokens.dart';
import '../../auth/widgets/auth_tokens.dart';

/// Kept for existing imports; values live in [FormTokens].
abstract final class OnboardingTokens {
  static const Color background = FormTokens.background;
  static const Color border = FormTokens.border;
  static const Color ink = FormTokens.ink;
  static const double fieldHeight = FormTokens.fieldHeight;
  static const double fieldRadius = FormTokens.fieldRadius;
  static const double pagePadding = FormTokens.pagePadding;
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(OnboardingTokens.fieldRadius),
      borderSide: BorderSide(color: c, width: w),
    );

InputDecoration onboardingDecoration(String hint, {bool error = false}) {
  final idle = error ? AuthTokens.error : OnboardingTokens.border;
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: AuthTokens.hint),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    border: _border(idle),
    enabledBorder: _border(idle),
    focusedBorder: _border(error ? AuthTokens.error : AuthTokens.actionBlue, 1.5),
  );
}

/// Forces upper case while typing (PAN).
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

/// 48dp text field. [error] drives only the border colour (scoped Obx).
class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.error,
    this.focusNode,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
    this.capitalization = TextCapitalization.words,
    this.onSubmitted,
    this.autofillHints,
    this.sensitive = false,
  });

  final TextEditingController controller;
  final String hint;
  final RxnString error;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  /// Disables autocorrect/suggestions so the keyboard never learns the value.
  final bool sensitive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: OnboardingTokens.fieldHeight,
      child: Obx(() => TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: capitalization,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: inputFormatters,
            autofillHints: autofillHints,
            autocorrect: !sensitive,
            enableSuggestions: !sensitive,
            onSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 15, color: OnboardingTokens.ink),
            decoration: onboardingDecoration(hint, error: error.value != null),
          )),
    );
  }
}
