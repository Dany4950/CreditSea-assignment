import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/form_skeleton.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/personal_details_controller.dart';
import '../widgets/docked_date_picker.dart';
import '../widgets/labeled_field.dart';
import '../widgets/onboarding_input.dart';
import '../widgets/onboarding_shell.dart';
import '../widgets/select_field.dart';

class PersonalDetailsView extends GetView<PersonalDetailsController> {
  const PersonalDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return OnboardingShell(
      step: 0,
      title: 'Personal Details',
      status: c.status,
      onRetry: c.load,
      skeleton: const FormSkeleton(fields: 4),
      // No arrow when this is the first route (right after sign-in).
      onBack: Navigator.canPop(context) ? () => Get.back() : null,
      body: _Body(c: c),
      footer: Obx(() => PrimaryButton(
            label: 'Continue',
            height: 48,
            loading: c.loading.value,
            onPressed: c.submit,
          )),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.c});
  final PersonalDetailsController c;

  static final _nameFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]")),
    LengthLimitingTextInputFormatter(30),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledField(
                label: 'First Name*',
                error: c.firstError,
                child: OnboardingTextField(
                  controller: c.firstName,
                  hint: 'Your first name',
                  error: c.firstError,
                  inputFormatters: _nameFormatters,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LabeledField(
                label: 'Last Name*',
                error: c.lastError,
                child: OnboardingTextField(
                  controller: c.lastName,
                  hint: 'Your last name',
                  error: c.lastError,
                  inputFormatters: _nameFormatters,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LabeledField(
          label: 'Gender*',
          error: c.genderError,
          child: Obx(() => SelectField(
                hint: 'Select your gender',
                value: c.gender.value,
                hasError: c.genderError.value != null,
                onTap: () async {
                  final v = await showOptionSheet(
                    title: 'Select your gender',
                    options: PersonalDetailsController.genders,
                    selected: c.gender.value,
                  );
                  if (v != null) c.setGender(v);
                },
              )),
        ),
        const SizedBox(height: 24),
        LabeledField(
          label: 'Date of Birth*',
          error: c.dobError,
          child: KeyedSubtree(
            key: c.dobKey, // anchor for the docked calendar
            child: Obx(() => SelectField(
                  hint: 'DD - MM - YYYY',
                  value: c.dobText,
                  icon: Icons.calendar_month_outlined,
                  hasError: c.dobError.value != null,
                  onTap: () => _pickDob(context, c),
                )),
          ),
        ),
        const SizedBox(height: 24),
        LabeledField(
          label: 'Your Marital Status *',
          error: c.maritalError,
          child: Obx(() => SelectField(
                hint: 'Select',
                value: c.marital.value,
                hasError: c.maritalError.value != null,
                onTap: () async {
                  final v = await showOptionSheet(
                    title: 'Marital status',
                    options: PersonalDetailsController.maritalOptions,
                    selected: c.marital.value,
                  );
                  if (v != null) c.setMarital(v);
                },
              )),
        ),
      ],
    );
  }
}

Future<void> _pickDob(BuildContext context, PersonalDetailsController c) async {
  // If the keyboard is open, let the layout settle before measuring the anchor.
  if (MediaQuery.viewInsetsOf(context).bottom > 0) {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!context.mounted) return;
  }
  final now = DateTime.now();
  final picked = await showDockedDatePicker(
    context: context,
    anchorKey: c.dobKey,
    firstDate: DateTime(now.year - 80, now.month, now.day),
    lastDate: now,
    selected: c.dob.value,
    initialView: DateTime(now.year - 25, now.month),
    onClear: c.clearDob,
  );
  if (picked != null) c.setDob(picked);
}
