import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/india_flag.dart';
import 'auth_input.dart';
import 'auth_tokens.dart';

class PhoneField extends StatelessWidget {
  const PhoneField({super.key, required this.controller, this.onSubmitted});
  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  static const _radius = BorderRadius.all(Radius.circular(AuthTokens.fieldRadius));
  static final _formatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _radius,
            border: Border.fromBorderSide(BorderSide(color: AuthTokens.border)),
          ),
          child: SizedBox(
            height: AuthTokens.fieldHeight,
            width: 84,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IndiaFlag(),
                SizedBox(width: 8),
                Text('+91', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: AuthTokens.fieldHeight,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: _formatters,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              onSubmitted: (_) => onSubmitted?.call(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: authInputDecoration(hint: 'Please enter your mobile no.'),
            ),
          ),
        ),
      ],
    );
  }
}
