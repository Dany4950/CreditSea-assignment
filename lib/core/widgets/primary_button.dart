import 'package:flutter/material.dart';
import '../../modules/auth/widgets/auth_tokens.dart';

/// Full-width button with soft blue glow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  static const _radius = BorderRadius.all(Radius.circular(8));
  static const _glow = [
    BoxShadow(color: Color(0x4D0075FF), blurRadius: 14, offset: Offset(0, 5)),
  ];

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: onPressed == null ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AuthTokens.actionBlue,
          borderRadius: _radius,
          boxShadow: onPressed == null ? null : _glow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
