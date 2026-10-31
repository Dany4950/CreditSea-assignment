import 'package:flutter/material.dart' hide StepState;
import '../../auth/widgets/auth_tokens.dart';
import '../models/loan.dart';

/// Vertical 6-step tracker. Border/label colours animate between states.
class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.loan});
  final Loan loan;

  static const _connector = Color(0xFFC9CED6);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < Loan.stepLabels.length; i++) ...[
          if (i > 0)
            const Center(
              child: SizedBox(width: 1.5, height: 16, child: ColoredBox(color: _connector)),
            ),
          _StepTile(label: Loan.stepLabels[i], state: loan.stepState(i)),
        ],
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.label, required this.state});
  final String label;
  final StepState state;

  static const _green = Color(0xFF2E9E5B);
  static const _pendingBorder = Color(0xFFC9CED6);
  static const _pendingText = Color(0xFF6B7280);

  Color get _color => switch (state) {
        StepState.done => _green,
        StepState.current => AuthTokens.actionBlue,
        StepState.pending => _pendingText,
        StepState.error => AuthTokens.error,
      };

  Color get _border => state == StepState.pending ? _pendingBorder : _color;

  IconData get _icon => switch (state) {
        StepState.done => Icons.event_available_outlined,
        StepState.error => Icons.event_busy_outlined,
        _ => Icons.calendar_month_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _border, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(_icon, size: 22, color: _color),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _color),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
