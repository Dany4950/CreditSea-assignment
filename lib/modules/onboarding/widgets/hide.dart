import 'package:flutter/material.dart';

/// Collapses [child] (illustrations) while the keyboard is open, so the form and
/// the pinned button keep breathing room on every screen height.
class HideOnKeyboard extends StatelessWidget {
  const HideOnKeyboard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final open = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: open ? const SizedBox(width: double.infinity) : child,
    );
  }
}
