import 'package:flutter/material.dart';
import '../../modules/auth/widgets/auth_tokens.dart';

/// Full-width outlined button (secondary action).
class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onPressed, this.height = 50});
  final String label;
  final VoidCallback? onPressed;
  final double height;

  static const _radius = BorderRadius.all(Radius.circular(8));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.all(color: AuthTokens.actionBlue, width: 1.5),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: SizedBox(
            height: height - 3,
            width: double.infinity,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}
