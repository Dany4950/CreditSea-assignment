import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/state/view_status.dart';
import '../../../routes/app_routes.dart';
import '../models/personal_details.dart';
import '../repositories/onboarding_repository.dart';

class PersonalDetailsController extends GetxController {
  PersonalDetailsController(this._repo);
  final OnboardingRepository _repo;

  static const genders = ['Male', 'Female', 'Other'];
  static const maritalOptions = ['Single', 'Married', 'Divorced', 'Widowed'];
  static const minAge = 21;
  static const maxAge = 60;
  static final _dobFormat = DateFormat('dd - MM - yyyy');

  final firstName = TextEditingController();
  final lastName = TextEditingController();

  /// Anchor for the docked calendar popup.
  final dobKey = GlobalKey();

  final status = ViewStatus.loading.obs;
  final gender = RxnString();
  final marital = RxnString();
  final dob = Rxn<DateTime>();

  final firstError = RxnString();
  final lastError = RxnString();
  final genderError = RxnString();
  final dobError = RxnString();
  final maritalError = RxnString();
  final loading = false.obs;

  String? get dobText => dob.value == null ? null : _dobFormat.format(dob.value!);

  @override
  void onInit() {
    super.onInit();
    firstName.addListener(() => _clear(firstError));
    lastName.addListener(() => _clear(lastError));
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// GET /onboarding/personal -> prefill when the user comes back to this step.
  Future<void> load() async {
    status.value = ViewStatus.loading;
    try {
      final saved = await _repo.fetchPersonalDetails();
      if (saved != null) {
        firstName.text = saved.firstName;
        lastName.text = saved.lastName;
        gender.value = saved.gender;
        dob.value = saved.dob;
        marital.value = saved.maritalStatus;
      }
      status.value = ViewStatus.ready;
    } catch (_) {
      status.value = ViewStatus.error;
    }
  }

  void _clear(RxnString r) {
    if (r.value != null) r.value = null;
  }

  void setGender(String v) {
    gender.value = v;
    genderError.value = null;
  }

  void setMarital(String v) {
    marital.value = v;
    maritalError.value = null;
  }

  void setDob(DateTime d) {
    dob.value = d;
    dobError.value = null;
  }

  void clearDob() => dob.value = null;

  static int ageOn(DateTime dob, DateTime now) {
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  String? _nameError(String v, String label) {
    final t = v.trim();
    if (t.isEmpty) return 'Enter your $label';
    if (t.length < 2) return 'Your $label is too short';
    return null;
  }

  String? _dobError() {
    final d = dob.value;
    if (d == null) return 'Select your date of birth';
    final age = ageOn(d, DateTime.now());
    if (age < minAge || age > maxAge) {
      return 'You must be between $minAge and $maxAge years old';
    }
    return null;
  }

  Future<void> submit() async {
    if (loading.value) return;

    firstError.value = _nameError(firstName.text, 'first name');
    lastError.value = _nameError(lastName.text, 'last name');
    genderError.value = gender.value == null ? 'Select your gender' : null;
    dobError.value = _dobError();
    maritalError.value = marital.value == null ? 'Select your marital status' : null;

    final hasError = [firstError, lastError, genderError, dobError, maritalError]
        .any((e) => e.value != null);
    if (hasError) {
      HapticFeedback.mediumImpact();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await _repo.savePersonalDetails(PersonalDetails(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        gender: gender.value!,
        dob: dob.value!,
        maritalStatus: marital.value!,
      ));
      Get.toNamed(Routes.email);
    } on OnboardingException catch (e) {
      Get.snackbar('Could not save', e.message,
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } catch (_) {
      Get.snackbar('Could not save', 'Please check your connection and try again',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    super.onClose();
  }
}
