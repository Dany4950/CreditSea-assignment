import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/pan_controller.dart';
import '../widgets/illustrations.dart';
import '../widgets/labeled_field.dart';
import '../widgets/onboarding_input.dart';
import '../widgets/onboarding_shell.dart';

class PanView extends GetView<PanController> {
  const PanView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return OnboardingShell(
      step: 0,
      title: 'Verify PAN Number',
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 1, hero: true),
      onBack: Navigator.canPop(context) ? () => Get.back() : null,
      body: _Body(c: c),
      footer: Obx(() => PrimaryButton(
            label: 'Verify',
            height: 48,
            loading: c.verifying.value,
            onPressed: c.canVerify.value ? c.verify : null,
          )),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c});
  final PanController c;

  static final _panFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
    const UpperCaseTextFormatter(),
    LengthLimitingTextInputFormatter(PanController.panLength),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: RepaintBoundary(child: PanCardIllustration())),
        const SizedBox(height: 26),
        LabeledField(
          label: 'Enter Your PAN Number*',
          error: c.error,
          child: OnboardingTextField(
            controller: c.pan,
            hint: 'e.g., ABCDE1234F',
            error: c.error,
            sensitive: true,
            capitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: _panFormatters,
            onSubmitted: (_) => c.verify(),
          ),
        ),
      ],
    );
  }
}
