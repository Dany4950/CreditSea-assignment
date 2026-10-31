import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/state/view_status.dart';
import '../../../core/widgets/card_shell.dart';
import '../../../core/widgets/step_header.dart';

/// CardShell + StepHeader (Register step). Same API as before.
class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.step,
    required this.title,
    required this.body,
    required this.footer,
    this.onBack,
    this.status,
    this.onRetry,
    this.skeleton,
  });

  final int step;
  final String title;
  final Widget body;
  final Widget footer;
  final VoidCallback? onBack;
  final Rx<ViewStatus>? status;
  final VoidCallback? onRetry;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) => CardShell(
        header: StepHeader(current: step),
        title: title,
        onBack: onBack,
        body: body,
        footer: footer,
        status: status,
        onRetry: onRetry,
        skeleton: skeleton,
      );
}
