import 'package:flutter/material.dart';
import '../../modules/auth/widgets/auth_tokens.dart';

/// Register / Offer / Approval header. [current] is 0..2.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.current});
  final int current;

  static const _labels = ['Register', 'Offer', 'Approval'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < _labels.length; i++)
            _Step(number: i + 1, label: _labels[i], active: i == current, done: i < current),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label, required this.active, required this.done});
  final int number;
  final String label;
  final bool active;
  final bool done;

  static const _grey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final Color circle = done
        ? AuthTokens.success
        : active
            ? AuthTokens.actionBlue
            : const Color(0xFFEDEFF3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : Text('$number',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _grey)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? AuthTokens.actionBlue : _grey)),
      ],
    );
  }
}
