import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/auth/widgets/auth_tokens.dart';
import 'form_tokens.dart';

/// Label + field + inline error. Only the error line rebuilds.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.error, required this.child});
  final String label;
  final RxnString error;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: FormTokens.ink)),
        const SizedBox(height: 12),
        child,
        Obx(() {
          final e = error.value;
          return e == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(e, style: const TextStyle(color: AuthTokens.error, fontSize: 12)),
                );
        }),
      ],
    );
  }
}
